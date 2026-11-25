`timescale 1ns/1ps

module tb_async_fifo;

  parameter DATA_WIDTH = 8;
  parameter ADDR_WIDTH = 3;
  parameter MEM_DEPTH  = 8;      // FIFO depth

  // ---------------- DUT signals ----------------
  reg                   wclk, rclk, wrstn, rrstn;
  reg                   w_en, r_en;
  reg  [DATA_WIDTH-1:0] wdata;
  wire [DATA_WIDTH-1:0] rdata;
  wire                  full, empty;

  // ---------------- DUT ----------------
  async_fifo #(DATA_WIDTH, ADDR_WIDTH, MEM_DEPTH) dut (
    .wclk(wclk), .rclk(rclk),
    .wrstn(wrstn), .rrstn(rrstn),
    .w_en(w_en), .r_en(r_en),
    .wdata(wdata), .rdata(rdata),
    .full(full), .empty(empty)
  );

  // ---------------- Clocks (independent, tunable) ----------------
  real WCLK_PERIOD = 10.0;   // 100 MHz
  real RCLK_PERIOD = 14.0;   // ~71 MHz
  
  initial wclk = 0;  
  always #(WCLK_PERIOD/2) wclk = ~wclk;
  
  initial rclk = 0;  
  always #(RCLK_PERIOD/2) rclk = ~rclk;

  // ---------------- Scoreboard ----------------
  reg [DATA_WIDTH-1:0] ref_mem [0:65535];
  integer wr_idx, rd_idx;          // accepted writes / accepted reads
  integer errors, checks;

  reg                  rd_pending;  // a read was accepted on the previous rclk edge
  reg [DATA_WIDTH-1:0] exp_data;    // data we expect to appear on rdata now

  // Record a write only if it is actually accepted
  always @(posedge wclk) begin
    if (wrstn && w_en && !full) begin
      ref_mem[wr_idx % 65536] = wdata;
      wr_idx = wr_idx + 1;
    end
  end

  // rdata is REGISTERED: data for a read accepted at edge N is visible at edge N+1.
  // At each edge, first check the previous read, then register the new one.
  always @(posedge rclk) begin
    if (rd_pending) begin
      checks = checks + 1;
      if (rdata !== exp_data) begin
        errors = errors + 1;
        $display("[%0t] ERROR: read #%0d got %h, expected %h",
                 $time, rd_idx-1, rdata, exp_data);
      end
    end
    rd_pending = rrstn && r_en && !empty;
    if (rd_pending) begin
      exp_data = ref_mem[rd_idx % 65536];
      rd_idx   = rd_idx + 1;
    end
  end

  // ---------------- Tasks ----------------
  task do_reset;
    begin
      wrstn = 0; rrstn = 0; w_en = 0; r_en = 0; wdata = 0;
      wr_idx = 0; rd_idx = 0; rd_pending = 0;
      repeat (5) @(posedge wclk);
      wrstn = 1; rrstn = 1;
      repeat (3) @(posedge wclk);
    end
  endtask

  task write_one(input [DATA_WIDTH-1:0] d);
    begin
      @(posedge wclk); #1;
      w_en = 1; wdata = d;
      @(posedge wclk); #1;
      w_en = 0;
    end
  endtask

  task read_one;
    begin
      @(posedge rclk); #1;
      r_en = 1;
      @(posedge rclk); #1;
      r_en = 0;
    end
  endtask

  task check(input cond, input [255:0] msg);
    begin
      checks = checks + 1;
      if (!cond) begin
        errors = errors + 1;
        $display("[%0t] FAIL: %0s", $time, msg);
      end else
        $display("[%0t] PASS: %0s", $time, msg);
    end
  endtask

  integer e0;

  // ---------------- Main sequence ----------------
  initial begin
    errors = 0; checks = 0;
    $dumpfile("async_fifo.vcd");
    $dumpvars(0, tb_async_fifo);

    do_reset;

    // ===== TEST 1: Reset =====
    $display("\n--- TEST 1: Reset ---");
    check(empty === 1'b1, "empty is 1 after reset");
    check(full  === 1'b0, "full is 0 after reset");

    // ===== TEST 2: Single write, single read =====
    $display("\n--- TEST 2: Single write / single read ---");
    e0 = errors;
    write_one(8'hA5);
    repeat (5) @(posedge rclk);          // let write pointer cross to read domain
    check(empty === 1'b0, "empty deasserts after one write");
    read_one;
    #1;
    check(empty === 1'b1, "empty reasserts after reading the only entry");
    repeat (3) @(posedge rclk);          // let the registered rdata get checked
    check(errors == e0, "read data matches written data (A5)");

    // ===== Further tests go here =====

    #200;
    $display("\n==== DONE: %0d checks, %0d errors ====", checks, errors);
    if (errors == 0) $display("ALL TESTS PASSED");
    $finish;
  end

endmodule
