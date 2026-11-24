module dual_port_ram #(parameter DATA_WIDTH = 8,
                       parameter ADDR_WIDTH = 3,
                       parameter MEM_DEPTH = 8)
  (
    input wclk,
    input w_en,
    input [ADDR_WIDTH-1:0] wr_addr,
    input [DATA_WIDTH-1:0] wdata,
    
    input rclk,
    input r_en,
    input [ADDR_WIDTH-1:0] rd_addr,
    
    output reg [DATA_WIDTH-1:0] rdata
  );
  
  reg [DATA_WIDTH-1:0] mem [MEM_DEPTH-1:0];
  
  always @(posedge wclk) begin
    if(w_en)
      mem[wr_addr] <= wdata;
  end
  
  always @(posedge rclk) begin
    if(r_en)
      rdata <= mem[rd_addr];
  end
  
endmodule
