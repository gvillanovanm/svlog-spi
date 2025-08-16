/**
 * SPI
 *
 * @version: 0.1
 * @author : Gabriel Villanova N. M.
 */

module spi_sl (
  // port_list
  input  logic sclk,
  input  logic cs_n,
  input  logic mosi,
  output logic miso,

  input  logic sys_clk,
  input  logic rstn,

  // output
  output logic [7:0] leds,
  output logic frame_done_sclk_dbg,
  output logic [31:0] cmd_word_dbg,
  output logic [31:0] cmd_word_sync_dbg
);

// format {4'b, 12'bDATA, 2'b0, 6'bADDR,	7'b0, RWb}
logic [31:0] cmd_word;
logic  [5:0] bitcnt;

// -----------------------------------
// MOSI (get cmd_word)
// -----------------------------------
(* ASYNC_REG="TRUE" *) logic frame_done_sclk;
assign frame_done_sclk_dbg = frame_done_sclk;

always_ff @(posedge sclk or posedge cs_n) begin
  if(cs_n) begin
    bitcnt   <= 0;
    frame_done_sclk <= 0;
  end else begin
    bitcnt <= bitcnt + 1'b1;
    cmd_word <= {mosi, cmd_word[31:1]};
    frame_done_sclk <= (bitcnt == 31);
  end
end

// -----------------------------------
// SYNCHRONIZER to read cmd_word
// -----------------------------------
logic sync1;
logic valid_sync;
logic [31:0] cmd_word_sync;

always_ff @(posedge sys_clk) begin
  if(!rstn) begin
    sync1         <= 0;
    valid_sync    <= 0;
    cmd_word_sync <= 0;
  end else begin
    sync1 <= frame_done_sclk;
    valid_sync <= sync1;
    
    if(valid_sync) begin
      cmd_word_sync <= cmd_word;
    end 
  end
end

assign cmd_word_dbg = cmd_word;
assign cmd_word_sync_dbg = cmd_word_sync;

// -----------------------------------
// RB
// -----------------------------------
logic [11:0] REGS[63];
logic [11:0] data_out;

// parser for write
logic rwb;
logic [5:0] addr;
logic [11:0] data_in;

assign rwb     = cmd_word_sync[0];
assign addr    = cmd_word_sync[13:8];
assign data_in = cmd_word_sync[27:16];

// register bank
always_ff @(posedge sys_clk) begin
  if(!rstn) begin
    leds     <= 0;
    data_out <= 0;
    for(int i=0; i<63; i++)
      REGS[i] <= 0; // mandatory because it will control de internal system
  end else begin
    if(valid_sync) begin
      // write
      if(!rwb) begin
        REGS[addr] <= data_in;
        leds       <= data_in[7:0];
      // read
      end else begin
        data_out <= REGS[addr]; // data done to be read in next frame
      end
    end
  end
end

// -----------------------------------
// MISO (send data)
// -----------------------------------
logic [31:0] dout_miso;
logic [4:0] bitcnt_miso;
assign dout_miso = {20'b0, data_out};

always_ff @(posedge sclk or posedge cs_n) begin
  if(cs_n) begin
    miso <= 0;
    bitcnt_miso <= 0;
  end else begin
    miso <= dout_miso[bitcnt_miso];
    bitcnt_miso <= bitcnt_miso + 1;
  end
end

endmodule