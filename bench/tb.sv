/**
 * testbench SPI
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
  logic rstn;

  // internals
  int i;
  logic rwb;
  logic [5:0] addr;
  logic [11:0] data; 

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

    // start
    $display("Starting simulation...");

    // nothing
    #40ns;

    // init + reset deassert
    rstn = 1;
    #30ns;

    // reset assert and "applied" in SPI
    rstn = 0;
    cs_n = 1'b1; 
    sclk = 0;
    #50ns;

    // dessert reset
    rstn = 1;
    #20ns;

    // write transaction
    send_cmd(6'd12, 12'hABC, 0);

    // read
    send_cmd(6'd12, 12'h???, 1); // load data[addr] on registers
    send_cmd(6'd12, 12'h???, 1); // mosi transmit

    // end
    #100ns;
    $finish();
  end
  
  // send word
  task automatic send_cmd(logic [5:0] addr, logic [11:0] data, logic rwb);
    int i = 0;
    logic [31:0] cmd_word;

    #100ns;
    cmd_word = {4'b0000, data, 2'b00, addr, 7'b0000000, rwb};
    cs_n     = 0;
    repeat(32) begin
      send_bit(cmd_word[i]);
      i++;
    end
    cs_n = 1;
  endtask

  // send bit
  task automatic send_bit(bit input_bit);
    mosi = input_bit;
    sclk = 0;
    #20ns;
    sclk = 1;
    #20ns;
  endtask


endmodule