module read_control #(parameter ADDR_WIDTH = 3)
  (
    input rclk,
    input rrstn,
    input r_en,
    input [ADDR_WIDTH:0] sync_wr_ptr_gray,
    
    output empty,
    output [ADDR_WIDTH-1:0] rd_addr,
    output reg [ADDR_WIDTH:0] rd_ptr_gray
  );
  
  reg [ADDR_WIDTH:0] rd_ptr_bin;
  
  wire [ADDR_WIDTH:0] rd_ptr_bin_next;
  wire [ADDR_WIDTH:0] rd_ptr_gray_next;
  
  assign rd_ptr_bin_next  = rd_ptr_bin + (r_en && !empty);
  assign rd_ptr_gray_next = rd_ptr_bin_next ^ (rd_ptr_bin_next >> 1);
  
  assign rd_addr = rd_ptr_bin[ADDR_WIDTH-1:0];
  
  assign empty = (rd_ptr_gray == sync_wr_ptr_gray); 
  
  always @(posedge rclk or negedge rrstn) begin
    if(!rrstn) begin
      rd_ptr_bin <= 0;
      rd_ptr_gray <= 0;
    end
    else begin
      rd_ptr_bin <= rd_ptr_bin_next;
      rd_ptr_gray <= rd_ptr_gray_next;
    end
  end
  
endmodule
