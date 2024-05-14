module t_ff (
    input clk, reset_n,
    input t,
    output reg q
  );

  always @(posedge clk, negedge reset_n)
  begin
    if (~reset_n) q <= 1'b0;
    else if (t) q <= ~q;
      else q <= q;
  end

endmodule