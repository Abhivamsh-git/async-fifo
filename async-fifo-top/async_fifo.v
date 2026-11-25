module async_fifo #(parameter DATA_WIDTH = 8,
                    parameter ADDR_WIDTH = 3,
                    parameter MEM_DEPTH = 8)
  (
    input wclk,
    input rclk,
    
    input wrstn,
    input rrstn,
    
    input w_en,
    input r_en,
    
    input [DATA_WIDTH-1:0] wdata,
    
    output [DATA_WIDTH-1:0] rdata,
    
    output full,
    output empty
  );
  
  wire [ADDR_WIDTH:0] wr_ptr_gray;
  wire [ADDR_WIDTH:0] sync_wr_ptr_gray;
  
  wire [ADDR_WIDTH:0] rd_ptr_gray;
  wire [ADDR_WIDTH:0] sync_rd_ptr_gray;
  
  wire [ADDR_WIDTH-1:0] wr_addr;
  wire [ADDR_WIDTH-1:0] rd_addr;
  
  write_control wc1(.wclk(wclk), .wrstn(wrstn), .w_en(w_en), .sync_rd_ptr_gray(sync_rd_ptr_gray), .full(full), .wr_addr(wr_addr), .wr_ptr_gray(wr_ptr_gray));
  
  read_control rc1(.rclk(rclk), .rrstn(rrstn), .r_en(r_en), .sync_wr_ptr_gray(sync_wr_ptr_gray), .empty(empty), .rd_addr(rd_addr), .rd_ptr_gray(rd_ptr_gray));
  
  ff_sync m1(.clk(rclk), .rstn(rrstn), .din(wr_ptr_gray), .dout(sync_wr_ptr_gray));

  ff_sync m2(.clk(wclk), .rstn(wrstn), .din(rd_ptr_gray), .dout(sync_rd_ptr_gray));
  
  dual_port_ram mem1(.wclk(wclk), .w_en(w_en), .wr_addr(wr_addr), .wdata(wdata), .rclk(rclk), .r_en(r_en), .rd_addr(rd_addr), .rdata(rdata), .full(full), .empty(empty));
  
endmodule
