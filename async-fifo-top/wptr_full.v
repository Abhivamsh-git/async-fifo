module write_control #(parameter ADDR_WIDTH = 3)
  (
    input wclk,
    input wrstn,
    input w_en,
    input [ADDR_WIDTH:0] sync_rd_ptr_gray,
    
    output reg full,
    output [ADDR_WIDTH-1:0] wr_addr,
    output reg [ADDR_WIDTH:0] wr_ptr_gray
  );
  
  reg [ADDR_WIDTH:0] wr_ptr_bin;
  
  wire [ADDR_WIDTH:0] wr_ptr_bin_next;
  wire [ADDR_WIDTH:0] wr_ptr_gray_next;
  wire full_val;
  
  assign wr_ptr_bin_next  = wr_ptr_bin + (w_en && !full);
  assign wr_ptr_gray_next = wr_ptr_bin_next ^ (wr_ptr_bin_next >> 1);
  
  assign wr_addr = wr_ptr_bin[ADDR_WIDTH-1:0];
  
  assign full_val = (wr_ptr_gray_next[ADDR_WIDTH] != sync_rd_ptr_gray[ADDR_WIDTH]) && 
    (wr_ptr_gray_next[ADDR_WIDTH-1] != sync_rd_ptr_gray[ADDR_WIDTH-1]) && 
    (wr_ptr_gray_next[ADDR_WIDTH-2:0] == sync_rd_ptr_gray[ADDR_WIDTH-2:0]);
  
  always @(posedge wclk or negedge wrstn) begin
    if(!wrstn) begin
      wr_ptr_bin <= 0;
      wr_ptr_gray <= 0;
      full <= 0;
    end
    else begin
      wr_ptr_bin <= wr_ptr_bin_next;
      wr_ptr_gray <= wr_ptr_gray_next;
      full <= full_val;
    end
  end
  
endmodule
