module snake_led #(parameter INIT_LED = 8'b00000011, parameter INIT_LED_SIZE = 8) (
    input sys_clk,                            // hardware clock
    input sys_btn_1,                          // hardware btn1
    input sys_btn_2,                          // hardware btn2
    output wire [INIT_LED_SIZE - 1:0] led    // 8 LEDS pin
  );

  // Button 1 with debouncer and positive edge detector
  wire debounced_tick_1;
  wire debounced_1;
  button DEBOUNCED_BUTTON_1 (
    .clk(sys_clk),
    .reset_n('b1),
    .noisy(!sys_btn_1),
    .debounced(debounced_1),
    .p_edge(debounced_tick_1),
    .n_edge(),
    ._edge()
  );

  // Selected speed [0, 1]
  wire speed_level;
  t_ff TFF_1 (
    .clk(sys_clk),
    .reset_n('b1),
    .t(debounced_tick_1),
    .q(speed_level)
  );

  // Button 2 with debouncer and positive edge detector
  wire debounced_tick_2;
  wire debounced_2;
  button DEBOUNCED_BUTTON_2 (
    .clk(sys_clk),
    .reset_n('b1),
    .noisy(!sys_btn_2),
    .debounced(debounced_2),
    .p_edge(debounced_tick_2),
    .n_edge(),
    ._edge()
  );

  // Selected direction [0, 1]
  wire direction_level;
  t_ff TFF_2 (
    .clk(sys_clk),
    .reset_n('b1),
    .t(debounced_tick_2),
    .q(direction_level)
  );

  // Fast and slow timers
  wire timer_fast_done;
  timer_parameter #(.FINAL_VALUE(1_999_999)) T_FAST(
    .clk(sys_clk),
    .reset_n('b1),
    .enable('b1),
    .done(timer_fast_done)
  );

  wire timer_slow_done;
  timer_parameter #(.FINAL_VALUE(19_999_999)) T_SLOW(
    .clk(sys_clk),
    .reset_n('b1),
    .enable('b1),
    .done(timer_slow_done)
  );

  // Rotating shift register
  reg timer_done;
  wire [INIT_LED_SIZE - 1:0] led_reg;
  shift_reg #(.INIT_REG(INIT_LED)) SHIFT_REG (
    .clk(sys_clk),
    .reset_n('b1),
    .timer_done(timer_done),
    .direction_level(direction_level),
    .out_reg(led_reg)
  );

  // Selecting timer
  always @(posedge sys_clk) begin
      if (speed_level == 'b0)
        timer_done <= timer_slow_done;
      else
        timer_done <= timer_fast_done;
  end

  // Output logic
  assign led = ~led_reg;

endmodule
