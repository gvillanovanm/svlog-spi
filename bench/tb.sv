/**
 * testbench template
 *
 * @version: 0.1
 * @author : Gabriel Villanova N. M.
 */

module tb;
  localparam SYS_CLK_PERIOD = 10ns; // 100MHz

  // SPI signals
  logic sclk;
  logic cs_n;
  logic mosi;
  logic miso;
  logic sys_clk = 0;
  logic rstn = 0;

  // internals
  int i;
  logic rwb;
  logic [5:0] addr;
  logic [11:0] data; 
  logic [31:0] cmd_word;

  always #(SYS_CLK_PERIOD/2) sys_clk=~sys_clk;

  // dut instantiation
  spi_sl uu_spi_sl(
    .sclk   (sclk   ),
    .cs_n   (cs_n   ),
    .mosi   (mosi   ),
    .miso   (miso   ),

    .sys_clk(sys_clk),
    .rstn   (rstn   )
  );

  // main block
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;

    // codes here ...
    $display("Starting simulation...");

    // nothing
    #40us;

    // reset
    rstn = 1;
    #30us;
    rstn = 0;
    // reset must be applied in SPI
    cs_n = 1'b1; 
    sclk = 0;
    #50us;

   // ---------------------------------------------------------------------------------
   // ---------------------------------------------------------------------------------
   // ---------------------------------------------------------------------------------

    // dessert reset
    rstn = 1;
    #20us;

    // send an item
    data     = 12'h000; //ABC;
    addr     = 6'd59; // 0 to 64
    rwb      = 1'b1;
    cmd_word = {4'b0000, data, 2'b00, addr, 7'b0000000, rwb}; // 00AB _00AB_0001
    cs_n     = 0;
    i        = 0;
    repeat(32) begin
      send_bit(cmd_word[i]);
      i++;
    end
    cs_n = 1;
    #150us;
    
    // send an item
    data     = 12'h00C;
    addr     = 6'd12; // 0 to 64
    rwb      = 1'b0;
    cmd_word = {4'b0000, data, 2'b00, addr, 7'b0000000, rwb};
    cs_n     = 0;
    i        = 0;
    repeat(32) begin
      send_bit(cmd_word[i]);
      i++;
    end
    cs_n = 1;
    #150us;

   // ---------------------------------------------------------------------------------
   // ---------------------------------------------------------------------------------
   // ---------------------------------------------------------------------------------

    // prepare read N
    data     = 12'h000;
    addr     = 6'd23; // 0 to 64
    rwb      = 1'b1;
    cmd_word = {4'b0000, data, 2'b00, addr, 7'b0000000, rwb};
    cs_n     = 0;
    i        = 0;
    repeat(32) begin
      send_bit(cmd_word[i]);
      i++;
    end
    cs_n = 1;
    #20us;

    // read N
    data     = 12'h000;
    addr     = 6'd23; // 0 to 64
    rwb      = 1'b1;
    cmd_word = {4'b0000, data, 2'b00, addr, 7'b0000000, rwb};
    cs_n     = 0;
    i        = 0;
    repeat(32) begin
      send_bit(cmd_word[i]);
      i++;
    end
    cs_n = 1;
    #20us;

   // ---------------------------------------------------------------------------------
   // ---------------------------------------------------------------------------------
   // ---------------------------------------------------------------------------------

    // prepare read N
    data     = 12'h000;
    addr     = 6'd12; // 0 to 64
    rwb      = 1'b1;
    cmd_word = {4'b0000, data, 2'b00, addr, 7'b0000000, rwb};
    cs_n     = 0;
    i        = 0;
    repeat(32) begin
      send_bit(cmd_word[i]);
      i++;
    end
    cs_n = 1;
    #20us;


    // prepare read N
    data     = 12'h000;
    addr     = 6'd12; // 0 to 64
    rwb      = 1'b1;
    cmd_word = {4'b0000, data, 2'b00, addr, 7'b0000000, rwb};
    cs_n     = 0;
    i        = 0;
    repeat(32) begin
      send_bit(cmd_word[i]);
      i++;
    end
    cs_n = 1;
    #20us;

    // continue...

    #100ns;
    $finish();
  end
  
  // 25MHz
  task automatic send_bit(bit input_bit);
    mosi = input_bit;
    sclk = 0;
    #20ns;
    sclk = 1;
    #20ns;
  endtask


endmodule