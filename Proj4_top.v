//-----------------------------------------------------------------------------
// Proj4_top.v
//-----------------------------------------------------------------------------

module Proj4_top
  (
    fpga_0_RS232_Uart_1_RX_pin,
    fpga_0_RS232_Uart_1_TX_pin,
    fpga_0_LEDs_8Bit_GPIO_IO_pin,
    fpga_0_Push_Buttons_5Bit_GPIO_IO_pin,
    fpga_0_DIP_Switches_8Bit_GPIO_IO_pin,
    fpga_0_SRAM_Mem_A_pin,
    fpga_0_SRAM_Mem_CEN_pin,
    fpga_0_SRAM_Mem_OEN_pin,
    fpga_0_SRAM_Mem_WEN_pin,
    fpga_0_SRAM_Mem_BEN_pin,
    fpga_0_SRAM_Mem_ADV_LDN_pin,
    fpga_0_SRAM_Mem_DQ_pin,
    fpga_0_SRAM_ZBT_CLK_OUT_pin,
    fpga_0_SRAM_ZBT_CLK_FB_pin,
    fpga_0_clk_1_sys_clk_pin,
    fpga_0_rst_1_sys_rst_pin
  );
  input fpga_0_RS232_Uart_1_RX_pin;
  output fpga_0_RS232_Uart_1_TX_pin;
  inout [0:7] fpga_0_LEDs_8Bit_GPIO_IO_pin;
  inout [0:4] fpga_0_Push_Buttons_5Bit_GPIO_IO_pin;
  inout [0:7] fpga_0_DIP_Switches_8Bit_GPIO_IO_pin;
  output [7:30] fpga_0_SRAM_Mem_A_pin;
  output fpga_0_SRAM_Mem_CEN_pin;
  output fpga_0_SRAM_Mem_OEN_pin;
  output fpga_0_SRAM_Mem_WEN_pin;
  output [0:3] fpga_0_SRAM_Mem_BEN_pin;
  output fpga_0_SRAM_Mem_ADV_LDN_pin;
  inout [0:31] fpga_0_SRAM_Mem_DQ_pin;
  output fpga_0_SRAM_ZBT_CLK_OUT_pin;
  input fpga_0_SRAM_ZBT_CLK_FB_pin;
  input fpga_0_clk_1_sys_clk_pin;
  input fpga_0_rst_1_sys_rst_pin;

  (* BOX_TYPE = "user_black_box" *)
  Proj4
    Proj4_i (
      .fpga_0_RS232_Uart_1_RX_pin ( fpga_0_RS232_Uart_1_RX_pin ),
      .fpga_0_RS232_Uart_1_TX_pin ( fpga_0_RS232_Uart_1_TX_pin ),
      .fpga_0_LEDs_8Bit_GPIO_IO_pin ( fpga_0_LEDs_8Bit_GPIO_IO_pin ),
      .fpga_0_Push_Buttons_5Bit_GPIO_IO_pin ( fpga_0_Push_Buttons_5Bit_GPIO_IO_pin ),
      .fpga_0_DIP_Switches_8Bit_GPIO_IO_pin ( fpga_0_DIP_Switches_8Bit_GPIO_IO_pin ),
      .fpga_0_SRAM_Mem_A_pin ( fpga_0_SRAM_Mem_A_pin ),
      .fpga_0_SRAM_Mem_CEN_pin ( fpga_0_SRAM_Mem_CEN_pin ),
      .fpga_0_SRAM_Mem_OEN_pin ( fpga_0_SRAM_Mem_OEN_pin ),
      .fpga_0_SRAM_Mem_WEN_pin ( fpga_0_SRAM_Mem_WEN_pin ),
      .fpga_0_SRAM_Mem_BEN_pin ( fpga_0_SRAM_Mem_BEN_pin ),
      .fpga_0_SRAM_Mem_ADV_LDN_pin ( fpga_0_SRAM_Mem_ADV_LDN_pin ),
      .fpga_0_SRAM_Mem_DQ_pin ( fpga_0_SRAM_Mem_DQ_pin ),
      .fpga_0_SRAM_ZBT_CLK_OUT_pin ( fpga_0_SRAM_ZBT_CLK_OUT_pin ),
      .fpga_0_SRAM_ZBT_CLK_FB_pin ( fpga_0_SRAM_ZBT_CLK_FB_pin ),
      .fpga_0_clk_1_sys_clk_pin ( fpga_0_clk_1_sys_clk_pin ),
      .fpga_0_rst_1_sys_rst_pin ( fpga_0_rst_1_sys_rst_pin )
    );

endmodule

