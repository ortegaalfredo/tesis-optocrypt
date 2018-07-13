//----------------------------------------------------------------------------
// copro1 - module
//----------------------------------------------------------------------------
// IMPORTANT:
// DO NOT MODIFY THIS FILE EXCEPT IN THE DESIGNATED SECTIONS.
//
// SEARCH FOR --USER TO DETERMINE WHERE CHANGES ARE ALLOWED.
//
// TYPICALLY, THE ONLY ACCEPTABLE CHANGES INVOLVE ADDING NEW
// PORTS AND GENERICS THAT GET PASSED THROUGH TO THE INSTANTIATION
// OF THE USER_LOGIC ENTITY.
//----------------------------------------------------------------------------
//
// ***************************************************************************
// ** Copyright (c) 1995-2011 Xilinx, Inc.  All rights reserved.            **
// **                                                                       **
// ** Xilinx, Inc.                                                          **
// ** XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"         **
// ** AS A COURTESY TO YOU, SOLELY FOR USE IN DEVELOPING PROGRAMS AND       **
// ** SOLUTIONS FOR XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE,        **
// ** OR INFORMATION AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,        **
// ** APPLICATION OR STANDARD, XILINX IS MAKING NO REPRESENTATION           **
// ** THAT THIS IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,     **
// ** AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE      **
// ** FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY              **
// ** WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE               **
// ** IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR        **
// ** REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF       **
// ** INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS       **
// ** FOR A PARTICULAR PURPOSE.                                             **
// **                                                                       **
// ***************************************************************************
//
//----------------------------------------------------------------------------
// Filename:          copro1
// Version:           1.00.a
// Description:       Example FSL core (Verilog).
// Date:              Mon Nov 14 17:33:42 2011 (by Create and Import Peripheral Wizard)
// Verilog Standard:  Verilog-2001
//----------------------------------------------------------------------------
// Naming Conventions:
//   active low signals:                    "*_n"
//   clock signals:                         "clk", "clk_div#", "clk_#x"
//   reset signals:                         "rst", "rst_n"
//   generics:                              "C_*"
//   user defined types:                    "*_TYPE"
//   state machine next state:              "*_ns"
//   state machine current state:           "*_cs"
//   combinatorial signals:                 "*_com"
//   pipelined or register delay signals:   "*_d#"
//   counter signals:                       "*cnt*"
//   clock enable signals:                  "*_ce"
//   internal version of output port:       "*_i"
//   device pins:                           "*_pin"
//   ports:                                 "- Names begin with Uppercase"
//   processes:                             "*_PROCESS"
//   component instantiations:              "<ENTITY_>I_<#|FUNC>"
//----------------------------------------------------------------------------

////////////////////////////////////////////////////////////////////////////////
//
//
// Definition of Ports
// FSL_Clk             : Synchronous clock
// FSL_Rst           : System reset, should always come from FSL bus
// FSL_S_Clk       : Slave asynchronous clock
// FSL_S_Read      : Read signal, requiring next available input to be read
// FSL_S_Data      : Input data
// FSL_S_Control   : Control Bit, indicating the input data are control word
// FSL_S_Exists    : Data Exist Bit, indicating data exist in the input FSL bus
// FSL_M_Clk       : Master asynchronous clock
// FSL_M_Write     : Write signal, enabling writing to output FSL bus
// FSL_M_Data      : Output data
// FSL_M_Control   : Control Bit, indicating the output data are contol word
// FSL_M_Full      : Full Bit, indicating output FSL bus is full
//
////////////////////////////////////////////////////////////////////////////////

//`include "v5_gtxwizard_v1_7_tile.v"
//`include "mgt_usrclk_source_pll.v"
//`include "frame_gen.v"
//`include "frame_dec.v"

//----------------------------------------
// Module Section
//----------------------------------------
module copro1 #
(
	parameter EXAMPLE_USE_CHIPSCOPE                     =   0    // Set to 1 to use
)
	(
		// ADD USER PORTS BELOW THIS LINE 
		// -- USER ports added here 
		TILE1_REFCLK_PAD_P_IN, 
		TILE1_REFCLK_PAD_N_IN,
		// ADD USER PORTS ABOVE THIS LINE 
		// DO NOT EDIT BELOW THIS LINE ////////////////////
		// Bus protocol ports, do not add or delete. 
		FSL_Clk,
		FSL_Rst,
		FSL_S_Clk,
		FSL_S_Read,
		FSL_S_Data,
		FSL_S_Control,
		FSL_S_Exists,
		FSL_M_Clk,
		FSL_M_Write,
		FSL_M_Data,
		FSL_M_Control,
		FSL_M_Full
		// DO NOT EDIT ABOVE THIS LINE ////////////////////
	);

// ADD USER PORTS BELOW THIS LINE 
// -- USER ports added here 
input TILE1_REFCLK_PAD_P_IN;
input TILE1_REFCLK_PAD_N_IN;
// ADD USER PORTS ABOVE THIS LINE 

input                                     FSL_Clk;
input                                     FSL_Rst;
input                                     FSL_S_Clk;
output                                    FSL_S_Read;
input      [0 : 31]                       FSL_S_Data;
input                                     FSL_S_Control;
input                                     FSL_S_Exists;
input                                     FSL_M_Clk;
output                                    FSL_M_Write;
output     [0 : 31]                       FSL_M_Data;
output                                    FSL_M_Control;
input                                     FSL_M_Full;

// ADD USER PARAMETERS BELOW THIS LINE 
// --USER parameters added here 
// ADD USER PARAMETERS ABOVE THIS LINE

//*******************************************************************************
//**************************------------- GTX TILE -----------------*************
//*******************************************************************************


    
//************************** Register Declarations ****************************

    reg     [84:0]  ila_in0_r;
    reg     [84:0]  ila_in1_r;
    reg             tile1_tx_resetdone0_r;
    reg             tile1_tx_resetdone0_r2;
    reg             tile1_rx_resetdone0_r;
    reg             tile1_rx_resetdone0_r2;
    reg             tile1_tx_resetdone1_r;
    reg             tile1_tx_resetdone1_r2;
    reg             tile1_rx_resetdone1_r;
    reg             tile1_rx_resetdone1_r2;
    reg             async_mux0_sel_i;
    reg             async_mux1_sel_i;

    wire  [3:0] RXN_IN;
    wire  [3:0] RXP_IN;
    wire  [3:0] TXN_OUT;
    wire  [3:0] TXP_OUT;
	 
	 // LOOPBACK ************* DEBUG **************
//	 assign TXN_OUT = RXN_IN;
//	 assign TXP_OUT = RXP_IN;
    assign FSL_M_Control = 0;
//**************************** Wire Declarations ******************************

    //------------------------ MGT Wrapper Wires ------------------------------
    //________________________________________________________________________
    //________________________________________________________________________
    //TILE1   (X0Y5)

    //---------------------- Loopback and Powerdown Ports ----------------------
    wire    [2:0]   tile1_loopback0_i;
    wire    [2:0]   tile1_loopback1_i;
    //----------------- Receive Ports - RX Data Path interface -----------------
    wire    [31:0]  tile1_rxdata0_i;
    wire    [31:0]  tile1_rxdata1_i;
    //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    wire    [1:0]   tile1_rxeqmix0_i;
    wire    [1:0]   tile1_rxeqmix1_i;
    //------------------- Shared Ports - Tile and PLL Ports --------------------
    wire            tile1_gtxreset_i;
    wire            tile1_plllkdet_i;
    wire            tile1_refclkout_i;
    wire            tile1_resetdone0_i;
    wire            tile1_resetdone1_i;
    //---------------- Transmit Ports - TX Data Path interface -----------------
    wire    [31:0]  tile1_txdata0_i;
    wire    [31:0]  tile1_txdata1_i;
    //------------- Transmit Ports - TX Driver and OOB signalling --------------
    wire    [2:0]   tile1_txdiffctrl0_i;
    wire    [2:0]   tile1_txdiffctrl1_i;
    wire    [2:0]   tile1_txpreemphasis0_i;
    wire    [2:0]   tile1_txpreemphasis1_i;
    //------------------- Transmit Ports - TX PRBS Generator -------------------
    wire    [1:0]   tile1_txenprbstst0_i;
    wire    [1:0]   tile1_txenprbstst1_i;


    //----------------------------- Global Signals -----------------------------
    wire            tile1_tx_system_reset0_c;
    wire            tile1_rx_system_reset0_c;
    wire            tile1_tx_system_reset1_c;
    wire            tile1_rx_system_reset1_c;
    wire            tied_to_ground_i;
    wire    [63:0]  tied_to_ground_vec_i;
    wire            tied_to_vcc_i;
    wire    [7:0]   tied_to_vcc_vec_i;
    wire            drp_clk_in_i;
    
    wire            tile0_refclkout_bufg_i;
    
    
    //--------------------------- User Clocks ---------------------------------
    wire            tile1_txusrclk0_i;
    wire            tile1_txusrclk20_i;
    wire            refclkout_pll0_locked_i;
    wire            refclkout_pll0_reset_i;
    wire            refclkout_pll1_locked_i;
    wire            refclkout_pll1_reset_i;
    wire            tile1_refclkout_to_cmt_i;


    //--------------------- Frame check/gen Module Signals --------------------
    wire            tile1_refclk_i;
    wire            tile1_matchn0_i;
    
    wire    [7:0]   tile1_txdata0_float_i;
    
    
    wire            tile1_block_sync0_reset_i;
    wire            tile1_track_data0_i;
    wire    [7:0]   tile1_error_count0_i;
    wire            tile1_frame_check0_reset_i;
    wire            tile1_inc_in0_i;
    wire            tile1_inc_out0_i;
    wire    [31:0]  tile1_unscrambled_data0_i;
    wire            tile1_matchn1_i;
    
    wire    [7:0]   tile1_txdata1_float_i;
    
    
    wire            tile1_block_sync1_reset_i;
    wire            tile1_track_data1_i;
    wire    [7:0]   tile1_error_count1_i;
    wire            tile1_frame_check1_reset_i;
    wire            tile1_inc_in1_i;
    wire            tile1_inc_out1_i;
    wire    [31:0]  tile1_unscrambled_data1_i;

    wire            reset_on_data_error_i;
    wire            track_data_out_i;


    //--------------------- Chipscope Signals ---------------------------------

    wire    [35:0]  shared_vio_control_i;
    wire    [35:0]  tx_data_vio_control0_i;
    wire    [35:0]  tx_data_vio_control1_i;
    wire    [35:0]  rx_data_vio_control0_i;
    wire    [35:0]  rx_data_vio_control1_i;
    wire    [35:0]  ila_control0_i;
    wire    [35:0]  ila_control1_i;
    wire    [31:0]  shared_vio_in_i;
    wire    [31:0]  shared_vio_out_i;
    wire    [31:0]  tx_data_vio_in0_i;
    wire    [31:0]  tx_data_vio_out0_i;
    wire    [31:0]  tx_data_vio_in1_i;
    wire    [31:0]  tx_data_vio_out1_i;
    wire    [31:0]  rx_data_vio_in0_i;
    wire    [31:0]  rx_data_vio_out0_i;
    wire    [31:0]  rx_data_vio_in1_i;
    wire    [31:0]  rx_data_vio_out1_i;
    wire    [84:0]  ila_in0_i;
    wire    [84:0]  ila_in1_i;


    wire    [31:0]  tile1_tx_data_vio_in0_i;
    wire    [31:0]  tile1_tx_data_vio_out0_i;
    wire    [31:0]  tile1_tx_data_vio_in1_i;
    wire    [31:0]  tile1_tx_data_vio_out1_i;
    wire    [31:0]  tile1_rx_data_vio_in0_i;
    wire    [31:0]  tile1_rx_data_vio_out0_i;
    wire    [31:0]  tile1_rx_data_vio_in1_i;
    wire    [31:0]  tile1_rx_data_vio_out1_i;
    wire    [84:0]  tile1_ila_in0_i;
    wire    [84:0]  tile1_ila_in1_i;

    // Wires de input para deteccion de comma
    wire tile1_rxslide0_i;
    wire tile1_rxslide1_i;

    wire tile1_rxcommadetuse0_i;
    wire tile1_rxcommadetuse1_i;

    wire tile1_rxenpcommaalign0_in;
    wire tile1_rxenpcommaalign1_in;

    wire [1:0] tile1_txbufstatus0_o;
    wire [2:0] tile1_rxbufstatus0_o;

    wire            user_tx_reset_i;
    wire            user_rx_reset_i;
    wire            ila_clk0_i;
    wire            ila_clk1_i;

	// Switch loopback
    reg		[2:0] reg_loopback;


    //-------------------------  Static signal Assigments ---------------------   

    assign tied_to_ground_i             = 1'b0;
    assign tied_to_ground_vec_i         = 64'h0000000000000000;
    assign tied_to_vcc_i                = 1'b1;
    assign tied_to_vcc_vec_i            = 64'hffffffffffffffff;

    //---------------------Dedicated GTX Reference Clock Inputs ---------------
    // The dedicated reference clock inputs you selected in the GUI are implemented using
    // IBUFDS instances.
    //
    // In the UCF file for this example design, you will see that each of
    // these IBUFDS instances has been LOCed to a particular set of pins. By LOCing to these
    // locations, we tell the tools to use the dedicated input buffers to the GTX reference
    // clock network, rather than general purpose IOs. To select other pins, consult the 
    // Implementation chapter of UG196, or rerun the wizard.
    //
    // This network is the highest performace (lowest jitter) option for providing clocks
    // to the GTX transceivers.
	 
	 /*
	 parameter   REFCLK_PERIOD   =   10.24;
	 
    reg             refclk_n_r;
	 wire            refclk_p_r;
    initial begin
        refclk_n_r = 1'b1;
    end

    always  
        #(REFCLK_PERIOD/2) refclk_n_r = !refclk_n_r;

    assign refclk_p_r = !refclk_n_r;
	 */
	// assign tile1_refclk_i = FSL_Clk;

	

// Usa ext. CLK
    IBUFDS tile1_refclk_ibufds_iaaa
    (
        .O                              (tile1_refclk_i), 
        .I                              (TILE1_REFCLK_PAD_P_IN),
        .IB                             (TILE1_REFCLK_PAD_N_IN)
    );
 
    //--------------------------------- User Clocks ---------------------------
    
    // The clock resources in this section were added based on userclk source selections on
    // the Latency, Buffering, and Clocking page of the GUI. A few notes about user clocks:
    // * The userclk and userclk2 for each GTX datapath (TX and RX) must be phase aligned to 
    //   avoid data errors in the fabric interface whenever the datapath is wider than 10 bits
    // * To minimize clock resources, you can share clocks between GTXs. GTXs using the same frequency
    //   or multiples of the same frequency can be accomadated using DCMs and PLLs. Use caution when
    //   using RXRECCLK as a clock source, however - these clocks can typically only be shared if all
    //   the channels using the clock are receiving data from TX channels that share a reference clock 
    //   source with each other.


    BUFG refclkout_pll1_bufg_i
    (
        .I                              (tile1_refclkout_i),
        .O                              (tile1_refclkout_to_cmt_i)
    );

    assign  refclkout_pll1_reset_i          =  !tile1_plllkdet_i;
	 
    MGT_USRCLK_SOURCE_PLL #
    (
        .MULT                           (6),
        .DIVIDE                         (1),
        .CLK_PERIOD                     (10),
        .OUT0_DIVIDE                    (12),
        .OUT1_DIVIDE                    (6),
        .OUT2_DIVIDE                    (1),
        .OUT3_DIVIDE                    (1),
        .SIMULATION_P                   (EXAMPLE_USE_CHIPSCOPE),
        .LOCK_WAIT_COUNT                (16'b0010011000100101)
    )
    refclkout_pll1_i
    (
        .CLK0_OUT                       (tile1_txusrclk20_i),
        .CLK1_OUT                       (tile1_txusrclk0_i),
        .CLK2_OUT                       (),
        .CLK3_OUT                       (),
        .CLK_IN                         (tile1_refclkout_to_cmt_i),
        .PLL_LOCKED_OUT                 (refclkout_pll1_locked_i),
        .PLL_RESET_IN                   (refclkout_pll1_reset_i)
    );





   // ---- NO CHIPSCOPE
	  // If Chipscope is not being used, drive GTX reset signal
    // from the top level ports
	 wire    GTXRESET_IN;
	 assign  GTXRESET_IN = FSL_Rst;
    assign  tile1_gtxreset_i = GTXRESET_IN;

    // assign resets for frame_gen modules
    assign  tile1_tx_system_reset0_c = !tile1_tx_resetdone0_r2;
    assign  tile1_tx_system_reset1_c = !tile1_tx_resetdone1_r2;

    // assign resets for frame_check modules
    assign  tile1_rx_system_reset0_c = !tile1_rx_resetdone0_r2;
    assign  tile1_rx_system_reset1_c = !tile1_rx_resetdone1_r2;

    assign  user_tx_reset_i                 =  tied_to_ground_i;
    assign  user_rx_reset_i                 =  tied_to_ground_i;
    assign  tile1_txdiffctrl0_i             =  tied_to_ground_vec_i[2:0];
    assign  tile1_txpreemphasis0_i          =  tied_to_ground_vec_i[2:0];
    assign  tile1_rxeqmix0_i                =  tied_to_ground_vec_i[1:0];
    assign  tile1_loopback0_i               =  reg_loopback;//3'b010;// Near-end PMA: 010   Near-end PCS: 001   Normal: 000
    assign  tile1_loopback1_i               =  tied_to_ground_vec_i[2:0];
    assign  tile1_txdiffctrl1_i             =  tied_to_ground_vec_i[2:0];
    assign  tile1_txpreemphasis1_i          =  tied_to_ground_vec_i[2:0];
    assign  tile1_txenprbstst0_i            =  tied_to_ground_vec_i[1:0];
    assign  tile1_txenprbstst1_i            =  tied_to_ground_vec_i[1:0];
    assign  tile1_rxeqmix1_i                =  tied_to_ground_vec_i[1:0];

    assign  tile1_rxslide0_i = tied_to_ground_i;
    assign  tile1_rxslide1_i = tied_to_ground_i;

    assign tile1_rxcommadetuse0_i = 1;//tied_to_ground_i;
    assign tile1_rxcommadetuse1_i = 1;//tied_to_ground_i;

localparam EXAMPLE_SIM_MODE                          =   "FAST";  // Set to Fast Functional Simulation Model
localparam EXAMPLE_SIM_GTXRESET_SPEEDUP              =   1;   // simulation setting for MGT smartmodel
localparam EXAMPLE_SIM_PLL_PERDIV2                   =   9'hD0; // simulation setting for MGT smartmodel

V5_GTXWIZARD_V1_7_TILE #
	(
//	 .SIM_MODE (EXAMPLE_SIM_MODE),
//	 .SIM_GTXRESET_SPEEDUP (EXAMPLE_SIM_GTXRESET_SPEEDUP),
//	 .SIM_PLL_PERDIV2 (EXAMPLE_SIM_PLL_PERDIV2)
	)
	tile(
    //---------------------- Loopback and Powerdown Ports ----------------------
    .LOOPBACK0_IN(tile1_loopback0_i),
    .LOOPBACK1_IN(tile1_loopback1_i),
    //----------------- Receive Ports - RX Data Path interface -----------------
    .RXDATA0_OUT(tile1_rxdata0_i),
    .RXDATA1_OUT(tile1_rxdata1_i),
    .RXRESET0_IN(!refclkout_pll1_locked_i),
    .RXRESET1_IN(!refclkout_pll1_locked_i),
    .RXUSRCLK0_IN(tile1_txusrclk0_i),
    .RXUSRCLK1_IN(tile1_txusrclk0_i),
    .RXUSRCLK20_IN(tile1_txusrclk20_i),
    .RXUSRCLK21_IN(tile1_txusrclk20_i),
    //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    .RXEQMIX0_IN(tile1_rxeqmix0_i),
    .RXEQMIX1_IN(tile1_rxeqmix1_i),
    .RXN0_IN(RXN_IN[2]),
    .RXN1_IN(RXN_IN[3]),
    .RXP0_IN(RXP_IN[2]),
    .RXP1_IN(RXP_IN[3]),
    //------------------- Shared Ports - Tile and PLL Ports --------------------

    .CLKIN_IN(tile1_refclk_i),
    .GTXRESET_IN(tile1_gtxreset_i),
    .PLLLKDET_OUT(tile1_plllkdet_i),
    .REFCLKOUT_OUT(tile1_refclkout_i),
    .RESETDONE0_OUT(tile1_resetdone0_i),
    .RESETDONE1_OUT(tile1_resetdone1_i),
    //---------------- Transmit Ports - TX Data Path interface -----------------
    .TXDATA0_IN(tile1_txdata0_i),
    .TXDATA1_IN(tile1_txdata1_i),
    .TXUSRCLK0_IN(tile1_txusrclk0_i),
    .TXUSRCLK1_IN(tile1_txusrclk0_i),
    .TXUSRCLK20_IN(tile1_txusrclk20_i),
    .TXUSRCLK21_IN(tile1_txusrclk20_i),
    //------------- Transmit Ports - TX Driver and OOB signalling --------------
    .TXDIFFCTRL0_IN(tile1_txdiffctrl0_i),
    .TXDIFFCTRL1_IN(tile1_txdiffctrl1_i),
    .TXN0_OUT(TXN_OUT[2]),
    .TXN1_OUT(TXN_OUT[3]),
    .TXP0_OUT(TXP_OUT[2]),
    .TXP1_OUT(TXP_OUT[3]),
    .TXPREEMPHASIS0_IN(tile1_txpreemphasis0_i),
    .TXPREEMPHASIS1_IN(tile1_txpreemphasis1_i),
    // A partir de aca, puertos agregados por mi
    //------------------- Transmit Ports - TX PRBS Generator -------------------
    .TXENPRBSTST0_IN(tile1_txenprbstst0_i),
    .TXENPRBSTST1_IN(tile1_txenprbstst1_i),
    //Control del slide de RX
    .RXSLIDE0_IN(tile1_rxslide0_i),
    .RXSLIDE1_IN(tile1_rxslide1_i),
    // Habilitar/deshabilitar deteccion de coma
    .RXCOMMADETUSE0_IN(tile1_rxcommadetuse0_i),
    .RXCOMMADETUSE1_IN(tile1_rxcommadetuse1_i),
    .RXENPCOMMAALIGN0_IN(tile1_rxenpcommaalign0_in),
    .RXENPCOMMAALIGN1_IN(tile1_rxenpcommaalign1_in),
    // Status del buffer elastico
    .TXBUFSTATUS0_OUT(tile1_txbufstatus0_o),
    .RXBUFSTATUS0_OUT(tile1_rxbufstatus0_o)
	);

V5_GTXWIZARD_V1_7_TILE #
	(
//	 .SIM_MODE (EXAMPLE_SIM_MODE),
//	 .SIM_GTXRESET_SPEEDUP (EXAMPLE_SIM_GTXRESET_SPEEDUP),
//	 .SIM_PLL_PERDIV2 (EXAMPLE_SIM_PLL_PERDIV2)
	)
	unused_tile(
    //---------------------- Loopback and Powerdown Ports ----------------------
    .LOOPBACK0_IN(tile1_loopback0_i),
    .LOOPBACK1_IN(tile1_loopback1_i),
    //----------------- Receive Ports - RX Data Path interface -----------------
    .RXDATA0_OUT(),
    .RXDATA1_OUT(),
    .RXRESET0_IN(!refclkout_pll1_locked_i),
    .RXRESET1_IN(!refclkout_pll1_locked_i),
    .RXUSRCLK0_IN(tile1_txusrclk0_i),
    .RXUSRCLK1_IN(tile1_txusrclk0_i),
    .RXUSRCLK20_IN(tile1_txusrclk20_i),
    .RXUSRCLK21_IN(tile1_txusrclk20_i),
    //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    .RXEQMIX0_IN(),
    .RXEQMIX1_IN(),
    .RXN0_IN(),
    .RXN1_IN(),
    .RXP0_IN(),
    .RXP1_IN(),
    //------------------- Shared Ports - Tile and PLL Ports --------------------

    .CLKIN_IN(tile1_refclk_i),
    .GTXRESET_IN(tile1_gtxreset_i),
    .PLLLKDET_OUT(),
    .REFCLKOUT_OUT(),
    .RESETDONE0_OUT(),
    .RESETDONE1_OUT(),
    //---------------- Transmit Ports - TX Data Path interface -----------------
    .TXDATA0_IN(),
    .TXDATA1_IN(),
    .TXUSRCLK0_IN(tile1_txusrclk0_i),
    .TXUSRCLK1_IN(tile1_txusrclk0_i),
    .TXUSRCLK20_IN(tile1_txusrclk20_i),
    .TXUSRCLK21_IN(tile1_txusrclk20_i),
    //------------- Transmit Ports - TX Driver and OOB signalling --------------
    .TXDIFFCTRL0_IN(tile1_txdiffctrl0_i),
    .TXDIFFCTRL1_IN(tile1_txdiffctrl1_i),
    .TXN0_OUT(TXN_OUT[0]),
    .TXN1_OUT(TXN_OUT[1]),
    .TXP0_OUT(TXP_OUT[0]),
    .TXP1_OUT(TXP_OUT[1]),
    .TXPREEMPHASIS0_IN(),
    .TXPREEMPHASIS1_IN(),
    // A partir de aca, puertos agregados por mi
    //------------------- Transmit Ports - TX PRBS Generator -------------------
    .TXENPRBSTST0_IN(),
    .TXENPRBSTST1_IN(),
    //Control del slide de RX
    .RXSLIDE0_IN(),
    .RXSLIDE1_IN(),
    // Habilitar/deshabilitar deteccion de coma
    .RXCOMMADETUSE0_IN(),
    .RXCOMMADETUSE1_IN(),
    .RXENPCOMMAALIGN0_IN(tile1_rxenpcommaalign0_in),
    .RXENPCOMMAALIGN1_IN(tile1_rxenpcommaalign1_in),
    // Status del buffer elastico
    .TXBUFSTATUS0_OUT(),
    .RXBUFSTATUS0_OUT()
	);

//------------- GTX TILE -----------------


//----------------------------------------
// Implementation Section
//----------------------------------------
// In this section, we povide an example implementation of MODULE copro1
// that does the following:
//
// 1. Read all inputs
// 2. Add each input to the contents of register 'sum' which
//    acts as an accumulator
// 3. After all the inputs have been read, write out the
//    content of 'sum' into the output FSL bus NUMBER_OF_OUTPUT_WORDS times
//
// You will need to modify this example for
// MODULE copro1 to implement your coprocessor

   // Total number of input data.
   localparam NUMBER_OF_INPUT_WORDS  = 1;

   // Total number of output data
   localparam NUMBER_OF_OUTPUT_WORDS = 1;

   // Define the states of state machine
   localparam Idle  = 3'b100;
   localparam Read_Inputs = 3'b010;
   localparam Write_Outputs  = 3'b001;

   reg [0:2] state;

   // Accumulator to hold sum of inputs read at any point in time
   reg [0:31] sum;
	
   // Counters to store the number inputs read & outputs written
   reg [0:NUMBER_OF_INPUT_WORDS - 1] nr_of_reads;
   reg [0:NUMBER_OF_OUTPUT_WORDS - 1] nr_of_writes;

   // CAUTION:
   // The sequence in which data are read in should be
   // consistent with the sequence they are written in the
   // driver's copro1.c file

   assign FSL_S_Read  = (state == Read_Inputs) ? FSL_S_Exists : 0;
   assign FSL_M_Write = (state == Write_Outputs) ? ~FSL_M_Full : 0;

	 assign FSL_M_Data = sum;
    wire    [7:0]   tile0_txdata0_float_i; // Esto no es utilizado, siempre es cero
  
	// Reset independiente de Frame gen/Frame dec
	reg CODEC_Rst;	 
	 // Generador de Frame
	 // Aqui se encuentra toda la logica de codificacion
	 wire [31:0] frame_gen_count;
	 // Decodificador ocupado (busy)
	 wire frame_gen_busy;
	 // Chip select del decodificador
	 reg frame_gen_cs;
	 // Generador en modo Sync
	 reg frame_gen_sync;
	 // Numero de clientes de ruido
	 reg [9:0] frame_gen_noise_clients;
	 // Modo solo-ruido
	 reg frame_gen_noise_mode;
	 // Registro de Debug  (Estado de FSM interna)
	 wire [31:0] frame_gen_debug;
	 
    FRAME_GEN tile0_frame_gen0
    (
        // User Interface
        .TX_DATA         (tile1_txdata0_i),
        .TX_CHARISK      ( ),
        .FRAME_COUNT	 (frame_gen_count),
        // System Interface
        .USER_CLK       (tile1_txusrclk20_i),
        .SYSTEM_RESET   ( (FSL_Rst || (~tile1_resetdone0_i)) || CODEC_Rst  ),
        .SYNC           (frame_gen_sync),
	.BUSY		(frame_gen_busy),
	.NOISE_CLIENTS	(frame_gen_noise_clients),
	.NOISE_MODE	(frame_gen_noise_mode),
	.DEBUG		(frame_gen_debug),
	.CS		(frame_gen_cs)
    );

// Contador de bloques transmitidos
wire [31:0] frame_dec_GoodBlockCount;
wire [31:0] frame_dec_BadBlockCount;
// Contador de bits de error
wire [31:0] frame_dec_BERCounter;
// Contador de frames individuales (bloomfilters)
wire [31:0] frame_dec_count;
// Decodificador ocupado (busy)
wire frame_dec_busy;
// Chip select del decodificador
reg frame_dec_cs;
// BITS de sincronizacion
reg  [8:0] sync_bits;
reg  frame_dec_sync;
wire frame_dec_synched;
wire  [31:0] frame_dec_debug;
	// Decodificador de Frame
    FRAME_DEC tile0_frame_dec0
    (
        // User Interface
        .RX_DATA                        (tile1_rxdata0_i),
        .RX_CHARISK                     ( ),
        // System Interface
	.SYNC_BITS	(sync_bits),
	.SYNC		(frame_dec_sync),
	.SYNCHED	(frame_dec_synched),
	.BUSY		(frame_dec_busy),
	.CS		(frame_dec_cs),
        .USER_CLK                       (tile1_txusrclk20_i),
        .SYSTEM_RESET                   ( (FSL_Rst || (~tile1_resetdone0_i)) ||  CODEC_Rst ),
	.FRAME_COUNT	(frame_dec_count),
	.GOOD_BLOCK_COUNT	(frame_dec_GoodBlockCount),
	.BAD_BLOCK_COUNT	(frame_dec_BadBlockCount),
	.BER_COUNT	(frame_dec_BERCounter),
	.DEBUG		(frame_dec_debug)
    );
	 
// Deshabilitamos comma si estamos sincronizados		
assign tile1_rxenpcommaalign0_in = 1;//~frame_dec_synched;
assign tile1_rxenpcommaalign1_in = 1;//~frame_dec_synched;

// Bloque de sincronizacion entre coder/decoder
// (Apaga el decoder mientras este prendido el coder)
// Frame State Machine State
`define SYNC_ENCODE    		3'h0
`define SYNC_DECODE  		3'h1
`define SYNC_DECODE2  		3'h2
`define SYNC_ENCODE2  		3'h4

`define WAIT1    		3'h5
`define SYNC_2    		3'h6
`define SYNC_3    		3'h7

reg [2:0] sync_state;
reg [20:0] sync_counter;
always @(posedge FSL_Clk) 
   begin  
      if (FSL_Rst || CODEC_Rst)               // Synchronous reset (active high)
        begin
	  frame_dec_cs<=0; // Desactivamos decoder
	  frame_gen_cs<=0; // Desactivamos encoder
	  sync_state<=`SYNC_ENCODE;
 	  //frame_gen_sync <=0;
 	  frame_dec_sync <=0;
   	  sync_bits <= 0; // Sincronia inicial
	  sync_counter<=0;
	  end
	else
		begin

	 	if (frame_gen_noise_mode==1) // Si estamos en modo de solo-ruido
			begin
			frame_gen_cs<=1; // Activamos encoder
			frame_dec_cs<=0;
			sync_state<=`SYNC_ENCODE;
			end
		// Maquina de estados de sincronizacion
		else 	begin
			case (sync_state)
				`SYNC_ENCODE: // Esperando que se active encoder
						begin
						frame_gen_cs<=1; // Activamos encoder
						frame_dec_cs<=0;
						if (frame_gen_busy==1)
							sync_state<=`SYNC_ENCODE2;
						end
				`SYNC_ENCODE2: // Encodeando
						begin
						if (frame_gen_busy==0)
							begin
							sync_state<=`WAIT1;
							sync_counter<=0;
							end
						end
				`WAIT1:	// Espera algunos clocks para que se vacie la cola y no sincronize con datos viejos
						begin
						if (sync_counter>100)
							sync_state<=`SYNC_DECODE;
						else	sync_counter<=sync_counter+1;
						end
				`SYNC_DECODE: // Esperando que se active decoder
						begin
						frame_gen_cs<=0;
						frame_dec_cs<=1;
						if (frame_dec_busy==1)
							sync_state<=`SYNC_DECODE2;
						end
				`SYNC_DECODE2: // Decodificando
						begin
						if (frame_dec_busy==0)
							sync_state<=`SYNC_ENCODE;
						end
			endcase
			end
		end
	end



/*
   // DEBUG: transmite pattern de 32 bits fijo
	reg [31:0] TXDATA;
	assign tile1_txdata0_i = TXDATA;	
	always @(posedge tile1_txusrclk20_i or posedge FSL_Rst)
	begin
	if (FSL_Rst)
		begin
		TXDATA			<= 32'b00000000000000000000001100110101;
		end
	else
		begin
		TXDATA <= 32'b01010101010000000000001100110101;
		end
	end
*/


	
   always @(posedge FSL_Clk) 
   begin  // process The_SW_accelerator
      if (FSL_Rst)               // Synchronous reset (active high)
        begin
           // CAUTION: make sure your reset polarity is consistent with the
           // system reset polarity
           state        <= Idle;
           nr_of_reads  <= 0;
           nr_of_writes <= 0;
           sum          <= 0;
	   reg_loopback <= 3'b000; // Near-end PMA: 010    Near-end PCS: 001     Normal: 000
	   frame_gen_sync <=0;
	   CODEC_Rst      <=0;
	   // Modo ruido apagado
	   frame_gen_noise_clients<=0;
	   frame_gen_noise_mode <=0;

        end
      else
        case (state)
          Idle: 
            if (FSL_S_Exists == 1)
            begin
              state       <= Read_Inputs;
              nr_of_reads <= NUMBER_OF_INPUT_WORDS - 1;
              sum         <= 0;
            end

          Read_Inputs: 
            if (FSL_S_Exists == 1) 
            begin
              // Coprocessor function (Managing GTX) happens here
				  if (FSL_S_Data==1) // Remove loopback
						begin
	   					reg_loopback <= 3'b000;
						sum <= 3'b000;
						nr_of_writes<=1;
						end
				  if (FSL_S_Data==2) // PMA loopback
						begin
	   					reg_loopback <= 3'b010;
						sum <= 3'b010;
						nr_of_writes<=1;
						end
				  if (FSL_S_Data==3) // PCS loopback
						begin
	   					reg_loopback <= 3'b001;
						sum <= 3'b001;
						nr_of_writes<=1;
						end
				  if (FSL_S_Data==4) // Decoder Block received Counter
						begin
						sum <= frame_dec_GoodBlockCount;
						nr_of_writes<=1;
						end
				  if (FSL_S_Data==5) // Decoder Bit Error Rate Counter
						begin
						sum <= frame_dec_BERCounter;
						nr_of_writes<=1;
						end
				  if (FSL_S_Data==6) // Decoder frame Counter
						begin
						sum <= frame_dec_count;
						nr_of_writes<=1;
						end
				  if (FSL_S_Data==7) // Generator frame Counter
						begin
						sum <= frame_gen_count;
						nr_of_writes<=1;
						end
				  if (FSL_S_Data==8) // Reset Coder/Decoder
						begin
						sum <= CODEC_Rst;
						nr_of_writes<=1;
						CODEC_Rst <= 1-CODEC_Rst;
						end
				  if (FSL_S_Data==9) // Buffer status
						begin
						sum <= tile1_txbufstatus0_o<<8+tile1_rxbufstatus0_o;
						nr_of_writes<=1;
						end
				  if (FSL_S_Data==10) //sync_state 
						begin
						sum <= sync_state;
						nr_of_writes<=1;
						end
				  if (FSL_S_Data==11) // SYNC Pattern
				  		begin
	 					sum <= frame_gen_sync;
						nr_of_writes<=1;
						frame_gen_sync <= 1-frame_gen_sync;
						end
				  if (FSL_S_Data==0) // Debug
						begin
						sum <=frame_dec_debug;
						//sum <=frame_dec_debug<<8+frame_gen_debug;
						nr_of_writes<=1;
						end
				  if (FSL_S_Data==12) // Increase Client Noise
				  		begin
	 					frame_gen_noise_mode<=1;
	 					frame_gen_noise_clients<=frame_gen_noise_clients+1;
	 					sum <= frame_gen_noise_clients+1;
						nr_of_writes<=1;
						end
				  if (FSL_S_Data==13) // Decrease Client Noise
				  		begin
	 					frame_gen_noise_mode<=1;
	 					frame_gen_noise_clients<=frame_gen_noise_clients-1;
	 					sum <= frame_gen_noise_clients-1;
						nr_of_writes<=1;
						end
				  if (FSL_S_Data==14) // Decoder Bad Block received Counter
						begin
						sum <= frame_dec_BadBlockCount;
						nr_of_writes<=1;
						end
				  if (FSL_S_Data==15) // Switchea modo de solo-ruido OFF
						begin
	 					frame_gen_noise_mode<=0;
	 					frame_gen_noise_clients<=0;
						sum <= frame_gen_noise_mode;
						nr_of_writes<=1;
						end
				
				
              if (nr_of_reads == 0)
                begin
                  state        <= Write_Outputs;
                  nr_of_writes <= NUMBER_OF_OUTPUT_WORDS - 1;
                end
              else
                nr_of_reads <= nr_of_reads - 1;
	  end
								
          Write_Outputs: 
            if (nr_of_writes == 0) 
              state <= Idle;
            else
              if (FSL_M_Full == 0)  nr_of_writes <= nr_of_writes - 1;
        endcase
   end

endmodule
