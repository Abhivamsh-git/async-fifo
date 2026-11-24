module ff_sync #(parameter ADDR_WIDTH = 3)(
    input clk,
    input rstn,
    input [ADDR_WIDTH:0] din,
    
    output reg [ADDR_WIDTH:0] dout
  );
  
  reg [ADDR_WIDTH:0] q1;
  
  always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
      q1 <= 0;
      dout <= 0;
    end
    else begin
      q1 <= din;
      dout <= q1;
    end
  end
  
endmodule
