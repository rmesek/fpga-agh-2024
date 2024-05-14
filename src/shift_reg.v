module shift_reg #(parameter INIT_REG = 8'b00000011, parameter INIT_LED_SIZE = 8) (
    input clk, reset_n,
    input timer_done, direction_level,
    output [INIT_LED_SIZE - 1:0] out_reg
  );

  reg [INIT_LED_SIZE - 1:0] local_reg = INIT_REG;

  always @(posedge clk, negedge reset_n)
  begin
    if (~reset_n)
      local_reg <= INIT_REG;
    else if (timer_done)
        if (direction_level == 'b0)
          local_reg <= {local_reg[INIT_LED_SIZE - 2:0], local_reg[INIT_LED_SIZE - 1]};
        else
          local_reg <= {local_reg[0], local_reg[INIT_LED_SIZE - 1:1]};
    else
      local_reg <= local_reg;
  end

  // Output logic
  assign out_reg = local_reg;

endmodule