////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /
// \   \   \/     Vendor : Xilinx
//  \   \         Version : 1.7
//  /   /         Application : GTX Transceiver Wizard
// /___/   /\     Filename : frame_dec.v
// \   \  /  \
//  \___\/\___\
//
//
// Module FRAME_DEC
// 
// Decodificador de Frame

//`include "./ipcores/rs_decoder_v7_1.v"
`include "rc4.inc"

`timescale 1ns / 1ps
`define DLY #1

//***********************************Entity Declaration*******************************

module FRAME_DEC

(
    // ----- User Interface
    RX_DATA,
    RX_CHARISK, // Unused
    // ----- System Interface
    // Clock
    USER_CLK,
    // Reset
    SYSTEM_RESET,
    // Amount of bits to shift for synchronization
    SYNC_BITS,
    // Work in synchronization mode
    SYNC,
    // We could successfuly locate the sync word
    SYNCHED,
    // We are busy decrypting
    BUSY,
    // chip select
    CS,
    // ----- Counters
    // Received frame counter
    FRAME_COUNT,
    // Received block (255 frames) counter
    GOOD_BLOCK_COUNT,
    // Received bad block (Failed Error correction)
    BAD_BLOCK_COUNT,
    // Bit errors detected by RS
    BER_COUNT,
    // Debug (FSM state)
    DEBUG
); 


//***********************************Port Declarations*******************************

   // User Interface
    input  [31:0]  RX_DATA;
    input  [3:0]   RX_CHARISK;

      // System Interface
    input           USER_CLK;
    input           SYSTEM_RESET; 
    input  [8:0]    SYNC_BITS;
    output	    BUSY;
    input	    SYNC;
    output	    SYNCHED;
    input       CS; 
    output [31:0]   DEBUG;
      // counters
    output	    FRAME_COUNT;
    output	    GOOD_BLOCK_COUNT;
    output	    BAD_BLOCK_COUNT;
    output	    BER_COUNT;

//********************************* Wire Declarations********************************* 

    wire            tied_to_ground_i;
    wire    [31:0]  tied_to_ground_vec_i;
    wire    [31:0]  tx_data_bram_i;
    wire    [3:0]   tx_charisk_i;
    wire    [3:0]   tx_charisk_float_i;

    wire    [3:0]   RX_CHARISK;    
    wire    [31:0]  RX_DATA;        
	
    reg    BUSY;
    wire   SYNC;
    reg    SYNCHED;
    wire   CS;
// Bits de sincronizacion
    wire    [8:0]    SYNC_BITS;

// Contador de frames recibidos
    reg    [31:0]  FRAME_COUNT;
// Contador de bloques transmitidos
    reg    [31:0]  GOOD_BLOCK_COUNT;
    reg    [31:0]  BAD_BLOCK_COUNT;
// Contador de bits de error	 
    reg    [31:0]  BER_COUNT;
// Debug (FSM state)
    reg    [31:0]    DEBUG;
//***************************Internal Register Declarations*************************** 

    reg     [8:0]   read_counter_i;    

//*********************************Main Body of Code**********************************

    assign tied_to_ground_vec_i  =   32'h00000000;
    assign tied_to_ground_i      =   1'b0;
    assign tied_to_vcc_i         =   1'b1;
    
    //____________________________ Counter to read from BRAM __________________________    

//---------------------------------------------------
/* RAM/ROM instantiations */
//---------------------------------------------------

// Tamanio bloomfilter
`define M 1024
// Numero de bloomfilter buffers, 256 es el minimo para decodear RS 255/232
`define numUserBytes 256

// Declaramos Bloomfilter
// Por conveniencia tenemos todos los bloomfilters a transmitir en memoria
// el minimo es 128K (4096*256)
// TODO: Reemplazar por buffer circular
reg [`M-1:0] bloomfilter [`numUserBytes:0]; 


wire [7:0] sigdigit_addr;
wire [23:0] sigdigit_out;

sigdigit_ROM_276x24 sigdigit_ROM2 (
  .clka(USER_CLK), // input clka
  .addra(sigdigit_addr), // input [11 : 0] addra
  .douta(sigdigit_out) // output [1 : 0] douta
);

reg [7:0] decoded_byte;

assign sigdigit_addr = decoded_byte;

//---------------------------------------------------
/* reed solomon decoder module instantiation */
//---------------------------------------------------
reg [7:0] rs_encoded_data [0:255];
reg [7:0] rs_decoded_data [0:255];
reg [7:0] frame_counter;
reg [7:0] framed_counter;


reg rsd_ce;
wire rsd_rdy;
wire rsd_fail;
wire [7:0] rsd_data_out;
wire [7:0] rsd_data_in;
reg rsd_start;
wire rsd_blk_strt;
wire rsd_blk_end;
wire rsd_error_found;
wire [5:0] rsd_err_cnt;
wire rsd_sync;
reg rsdsync;
assign rsd_sync = rsdsync;

assign rsd_data_in = rs_encoded_data[frame_counter];


rs_decoder_v7_1 rs_decoder (
        .data_in(rsd_data_in), // input [7 : 0] data_in
        .sync(rsd_sync), // input sync
        .clk(USER_CLK), // input clk
        .ce(rsd_ce), // input ce
        .data_out(rsd_data_out), // ouput [7 : 0] data_out
        .blk_strt(rsd_blk_strt), // ouput blk_strt
        .blk_end(rsd_blk_end), // ouput blk_end
        .err_found(rsd_error_found), // ouput err_found
        .err_cnt(rsd_err_cnt), // ouput [5 : 0] err_cnt
        .fail(rsd_fail), // ouput fail
        .ready(rsd_rdy), // ouput ready
        .rffd(rffd)); // ouput rffd

//----------------------------
/* rc4 module instantiation */
//----------------------------

reg [7:0] password[0:`KEY_SIZE-1];
wire rc4_output_ready2; // output ready (valid)
reg [7:0] password_input; //input


wire [9:0] rc4_out2; // output
reg rc4_ce2;
reg rc4_rst2;
wire rc4_clk2;
assign rc4_clk2 = USER_CLK & rc4_ce2;

rc4 rc4mod_2(
	.clk(rc4_clk2),
	.rst(rc4_rst2),
	.password_input(password_input),
	.output_ready(rc4_output_ready2),
	.K(rc4_out2)
);


// Frame State Machine State
`define FSMSD_CRYPTO_INIT    		5'h0
`define FSMSD_CRYPTO_INIT2    		5'hA
`define FSMSD_CRYPTO_KEXPAND 		5'h1
`define FSMSD_RS_DECODER_START		5'h2
`define FSMSD_RS_DECODER_DATAOUT	5'h3
`define FSMSD_RS_DECODER_WAIT           5'hB
`define FSMSD_RS_DECODER_OUT            5'hC
`define FSMSD_BLOOMDEC			5'h4
`define FSMSD_BLOOMDEC_KLOOP		5'h5
`define FSMSD_END			5'h6
`define FSMSD_WAIT_FOR_FRAME		5'h7
`define FSMSD_COMPRESS_SYMBOL		5'h8
`define FSMSD_COMPRESS_SYMBOL2		5'h9
// Debug states
`define FSMSD_BIT_COUNT			5'hD

// --------------------------------------------------------------------------
// ----------------------------------  Bloomfilter reception state machine
// Recibe continuamente de RX_DATA al buffer inputFrame

// Contador de bits totales recibidos
reg [64:0] ReceivedWordCounter; 
// Contador de bits recibidos adentro del frame
reg [16:0] framePosCounter; 
// Frame recibido completo
reg [`M-1:0] inputFrame;
// Flag indicador que un frame fue leido
reg frameReady;

reg frameSinchronized;

`define SYNCStartFrame 32'h1234807F

   // Define the states of state machine
   localparam SYNCHRO_BIT  = 3'b100;
   localparam Read_Inputs = 3'b010;
   localparam Write_Outputs  = 3'b001;

   reg [63:0] sync_buf;
   reg [7:0] bits_slide;
   reg [31:0] sync_data;
   reg [8:0] sync_counter; // Contador de palabras de sincronizacion.

// --------------------------------------------------------------------------
// ----------------------------------  Main State machine
// Encodea 223 bytes en user_data_ROM a BloomFilter[256][4096]

reg [4:0] FSMState;
reg [14:0] clkcounter; // Multi-use counter (same width as user_data_ROM)
reg [4:0]  WORDLENCount;
reg [4:0] K; //bloomfilter K

reg [31:0] DEBUGCounter;
reg [31:0] DEBUGCounter2;
`define KMAX 8'h5
`define WORDLENMAX 8'h18 // 24

reg [`WORDLENMAX-1:0] ExpandedSymbol;

always @(posedge USER_CLK)
	begin
        if(SYSTEM_RESET) // RESET: Inicializaciones de FSM, password, etc.
					begin
					sync_buf <= 64'h0000000000000000;
					clkcounter <= 14'h0000;
					FSMState <= `FSMSD_CRYPTO_INIT;
					password[0] <= 0;
					password[1] <= 1;
					password[2] <= 2;
					password[3] <= 3;
					password[4] <= 4;
					password[5] <= 5;
					password[6] <= 6;
					password[7] <= 255;
					rc4_rst2 <= 1;
					frame_counter <= 0; // Internal frame counter
					GOOD_BLOCK_COUNT<=0;
					BAD_BLOCK_COUNT<=0;
					BER_COUNT<=0;
					FRAME_COUNT<=0; // Total frame counter
					BUSY <=0;

					// Inicializaciones de maquina de estados de recepcion de frame (mezclada)
					ReceivedWordCounter <= 0;
					framePosCounter <= 0;
					frameReady <= 0;
					frameSinchronized <=0;
					bits_slide <= 31;
					rsd_ce <= 0;
					inputFrame<=0;
					sync_counter<=0;
					SYNCHED<=0;
					end
        else    if (CS == 1)
		begin
					// Maquina de estados de recepcion de frame (incrustada aca)
					if (frameReady==0) // Si esta listo para aceptar otro frame...
						begin
						//DEBUG<=RX_DATA[31:0]; // Output state signal for debug
						ReceivedWordCounter <= ReceivedWordCounter+1;
						sync_buf[63:32] <= RX_DATA[31:0];
						sync_buf[31:0]  <= sync_buf[63:32];
						//if (sync_buf[31:0] == `SYNCStartFrame)
						//	begin
						//	frameSinchronized <=1;
						//	framePosCounter <= 0;
						//	inputFrame<=0;
						//	bits_slide<=31;
							//DEBUG<=31;
						//	end
						//else	
						if (sync_buf[39:8] == `SYNCStartFrame)
							begin
							frameSinchronized <=1;
							framePosCounter <= 0;
							inputFrame<=0;
							bits_slide<=39;
							//DEBUG<=39;
							end
						else	if (sync_buf[47:16] == `SYNCStartFrame)
							begin
							frameSinchronized <=1;
							framePosCounter <= 0;
							inputFrame<=0;
							bits_slide<=47;
							//DEBUG<=47;
							end
						else	if (sync_buf[55:24] == `SYNCStartFrame)
							begin
							frameSinchronized <=1;
							framePosCounter <= 0;
							inputFrame<=0;
							bits_slide<=55;
							//DEBUG<=55;
							end
						else	if (sync_buf[63:32] == `SYNCStartFrame)
							begin
							frameSinchronized <=1;
							framePosCounter <= 0;
							inputFrame<=0;
							bits_slide<=63;
							//DEBUG<=63;
							end
						//else
						//	DEBUG<=sync_buf[31:0];

						sync_data<=sync_buf[bits_slide -: 32];
						if (frameSinchronized == 0)
							begin
							SYNCHED<=0;
							$display ("bits_slide= %04X Recevied == %08X sync_buf=%016X RX_DATA=%08X",bits_slide,sync_data,sync_buf,RX_DATA);
							end
						else
							begin // Frame is sinchronized
							SYNCHED<=1;
								if ((framePosCounter == `M+32))
									begin
									framePosCounter <= 32;
									$display(" Input frame: %x",inputFrame);
									frameReady <= 1;
									frameSinchronized <=0;
									end
								else  begin
									framePosCounter <= framePosCounter + 32;
									inputFrame <= (inputFrame >> 32);
									inputFrame[`M-1:`M-32] <= sync_data[31:0];
						$display ("Loading frame: SYNCHED=%d RX_DATA=%08X",SYNCHED,RX_DATA);
									end
								end
						end

					clkcounter<=clkcounter+1;
					//DEBUG<=FSMState; // Output state signal for debug

					case (FSMState)
						// Inicializo modulo crypto (Introduzco password)
						`FSMSD_CRYPTO_INIT:	begin // Enable rc4
									rc4_ce2 <= 1;
									clkcounter<=0;
									FSMState<=`FSMSD_CRYPTO_INIT2;
									end
						`FSMSD_CRYPTO_INIT2:	begin // Send rc4 key
									rc4_rst2<=0; // Libera de reset
									if (clkcounter<`KEY_SIZE) //Primeros KEY_SIZE clocks se usan para enviar el password a RC4.v
										password_input <= password[clkcounter];
									else	begin // Pasword enviado, pasamos al proximo estado
										FSMState<=`FSMSD_CRYPTO_KEXPAND;
										clkcounter<=14'h0000;
										end
									end
						// Espero a que el modulo de crypto termine de inicializar
						`FSMSD_CRYPTO_KEXPAND:begin // Expand rc4 Key
									if (rc4_output_ready2==1) // Tenemos que esperar 750 clocks a que RC4 expanda la key
										begin
										FSMState<=`FSMSD_WAIT_FOR_FRAME;
										rc4_ce2 <=0;
										end
									end
						// Espero a que un frame alineado haya ingresado al buffer
						`FSMSD_WAIT_FOR_FRAME:begin 
									BUSY <=0;
									if (frameReady == 1)
										begin
										//FSMState<=`FSMSD_BLOOMDEC;
										FSMState<=`FSMSD_BIT_COUNT;
										$display("***%dns*** Decoding Bloomfilter start",$time);
										DEBUGCounter <= 0;
										DEBUGCounter2 <= 0;
										ExpandedSymbol<=32'hFFFFFFFF;
										WORDLENCount<=0;
										BUSY <=1;
										end
									else FSMState<=`FSMSD_WAIT_FOR_FRAME;
									end
						// Contamos bits en '1' en el frame (SOLO DEBUG!)
						`FSMSD_BIT_COUNT:	begin
									if (inputFrame[DEBUGCounter]==1)
										DEBUGCounter2<=DEBUGCounter2+1;
									if (DEBUGCounter>1024)
										begin
										FSMState<=`FSMSD_BLOOMDEC;
										DEBUGCounter<=0;
										DEBUG<=DEBUGCounter2+10;
										end
									else	DEBUGCounter<=DEBUGCounter+1;
									end
						// Inicio del decodificador de bloomfilter
						`FSMSD_BLOOMDEC:	begin
									if (WORDLENCount == `WORDLENMAX) // Si decodie todos los bits
										begin
										WORDLENCount<=0;
										// Ahora debo buscar el simbolo real que corresponde al expandido.
										FSMState <= `FSMSD_COMPRESS_SYMBOL;
										rc4_ce2 <=0; // Apago rc4, no se necesita hasta el proximo frame
										decoded_byte <= 0;
										// BTW ya termine de procesar el frame, solamente hay un simbolo por frame.
										end
									else	begin
										K <= 0; // Init K
										FSMState <= `FSMSD_BLOOMDEC_KLOOP; // Proximo estado, a recorrer las K copias
										rc4_ce2 <=1; // Prendo RC4
										end
									end
						// Loop por cada K dentro del bloomfilter y decodifico
						`FSMSD_BLOOMDEC_KLOOP:	begin
									if (K==`KMAX) // Si llegue al final
										begin
										rc4_ce2 <=0; // Apago RC4
										FSMState <= `FSMSD_BLOOMDEC;
										WORDLENCount<=WORDLENCount+1; // Si no, incremento WORDLENCount que es el bit a mandar
										end
									else	begin
										if (rc4_output_ready2==1)
											begin
											// Docodificacion de bloomfilter al simbolo expandido
											ExpandedSymbol[WORDLENCount] <= ExpandedSymbol[WORDLENCount] && inputFrame[rc4_out2[9:0]];
											K<=K+1; // Realizo esto K veces
											if ((DEBUGCounter<200) && (frame_counter==4))
												begin
												$display("Frame DEC RC4: %d: K=%d rnd=%04X WordLenCount: %d ExpandedSymbol: %b inputbit: %b",DEBUGCounter,K,rc4_out2[9:0],WORDLENCount,ExpandedSymbol,inputFrame[rc4_out2[9:0]]);
												DEBUGCounter<=DEBUGCounter+1;
												end
											end
										
										end
									end
						// Doy tiempo al block_mem sigdigits_out para cargar el byte a testear
						`FSMSD_COMPRESS_SYMBOL:  begin
									 FSMState <=`FSMSD_COMPRESS_SYMBOL2;
									 end 
						// Con el simbolo expandido, busco inversamente el byte original correspondiente
						`FSMSD_COMPRESS_SYMBOL2:  begin
									if ((sigdigit_out == ExpandedSymbol) || (decoded_byte==255))
										begin
										rs_encoded_data[frame_counter] <= decoded_byte;
										$display("%dns: Frame: %x Decoded byte: %x",$time,frame_counter,decoded_byte);
										if (frame_counter==255)
											begin
											//rs_encoded_data --- DEBUG!!--
											/*
rs_encoded_data[  0] <= 8'h00;rs_encoded_data[  1] <= 8'h00;rs_encoded_data[  2] <= 8'h01;rs_encoded_data[  3] <= 8'h02;rs_encoded_data[  4] <= 8'h03;rs_encoded_data[  5] <= 8'h04;rs_encoded_data[  6] <= 8'h05;
rs_encoded_data[  7] <= 8'h06;rs_encoded_data[  8] <= 8'h07;rs_encoded_data[  9] <= 8'h08;rs_encoded_data[ 10] <= 8'h09;rs_encoded_data[ 11] <= 8'h0a;rs_encoded_data[ 12] <= 8'h0b;
rs_encoded_data[ 13] <= 8'h0c;rs_encoded_data[ 14] <= 8'h0d;rs_encoded_data[ 15] <= 8'h0e;rs_encoded_data[ 16] <= 8'h0f;rs_encoded_data[ 17] <= 8'h10;rs_encoded_data[ 18] <= 8'h11;
rs_encoded_data[ 19] <= 8'h12;rs_encoded_data[ 20] <= 8'h13;rs_encoded_data[ 21] <= 8'h14;rs_encoded_data[ 22] <= 8'h15;rs_encoded_data[ 23] <= 8'h16;rs_encoded_data[ 24] <= 8'h17;
rs_encoded_data[ 25] <= 8'h18;rs_encoded_data[ 26] <= 8'h19;rs_encoded_data[ 27] <= 8'h1a;rs_encoded_data[ 28] <= 8'h1b;rs_encoded_data[ 29] <= 8'h1c;rs_encoded_data[ 30] <= 8'h1d;
rs_encoded_data[ 31] <= 8'h1e;rs_encoded_data[ 32] <= 8'h1f;rs_encoded_data[ 33] <= 8'h20;rs_encoded_data[ 34] <= 8'h21;rs_encoded_data[ 35] <= 8'h22;rs_encoded_data[ 36] <= 8'h23;
rs_encoded_data[ 37] <= 8'h24;rs_encoded_data[ 38] <= 8'h25;rs_encoded_data[ 39] <= 8'h26;rs_encoded_data[ 40] <= 8'h27;rs_encoded_data[ 41] <= 8'h28;rs_encoded_data[ 42] <= 8'h29;
rs_encoded_data[ 43] <= 8'h2a;rs_encoded_data[ 44] <= 8'h2b;rs_encoded_data[ 45] <= 8'h2c;rs_encoded_data[ 46] <= 8'h2d;rs_encoded_data[ 47] <= 8'h2e;rs_encoded_data[ 48] <= 8'h2f;
rs_encoded_data[ 49] <= 8'h30;rs_encoded_data[ 50] <= 8'h31;rs_encoded_data[ 51] <= 8'h32;rs_encoded_data[ 52] <= 8'h33;rs_encoded_data[ 53] <= 8'h34;rs_encoded_data[ 54] <= 8'h35;
rs_encoded_data[ 55] <= 8'h36;rs_encoded_data[ 56] <= 8'h37;rs_encoded_data[ 57] <= 8'h38;rs_encoded_data[ 58] <= 8'h39;rs_encoded_data[ 59] <= 8'h3a;rs_encoded_data[ 60] <= 8'h3b;
rs_encoded_data[ 61] <= 8'h3c;rs_encoded_data[ 62] <= 8'h3d;rs_encoded_data[ 63] <= 8'h3e;rs_encoded_data[ 64] <= 8'h3f;rs_encoded_data[ 65] <= 8'h40;rs_encoded_data[ 66] <= 8'h41;
rs_encoded_data[ 67] <= 8'h42;rs_encoded_data[ 68] <= 8'h43;rs_encoded_data[ 69] <= 8'h44;rs_encoded_data[ 70] <= 8'h45;rs_encoded_data[ 71] <= 8'h46;rs_encoded_data[ 72] <= 8'h47;
rs_encoded_data[ 73] <= 8'h48;rs_encoded_data[ 74] <= 8'h49;rs_encoded_data[ 75] <= 8'h4a;rs_encoded_data[ 76] <= 8'h4b;rs_encoded_data[ 77] <= 8'h4c;rs_encoded_data[ 78] <= 8'h4d;
rs_encoded_data[ 79] <= 8'h4e;rs_encoded_data[ 80] <= 8'h4f;rs_encoded_data[ 81] <= 8'h50;rs_encoded_data[ 82] <= 8'h51;rs_encoded_data[ 83] <= 8'h52;rs_encoded_data[ 84] <= 8'h53;
rs_encoded_data[ 85] <= 8'h54;rs_encoded_data[ 86] <= 8'h55;rs_encoded_data[ 87] <= 8'h56;rs_encoded_data[ 88] <= 8'h57;rs_encoded_data[ 89] <= 8'h58;rs_encoded_data[ 90] <= 8'h59;
rs_encoded_data[ 91] <= 8'h5a;rs_encoded_data[ 92] <= 8'h5b;rs_encoded_data[ 93] <= 8'h5c;rs_encoded_data[ 94] <= 8'h5d;rs_encoded_data[ 95] <= 8'h5e;rs_encoded_data[ 96] <= 8'h5f;
rs_encoded_data[ 97] <= 8'h60;rs_encoded_data[ 98] <= 8'h61;rs_encoded_data[ 99] <= 8'h62;rs_encoded_data[100] <= 8'h63;rs_encoded_data[101] <= 8'h64;rs_encoded_data[102] <= 8'h65;
rs_encoded_data[103] <= 8'h66;rs_encoded_data[104] <= 8'h67;rs_encoded_data[105] <= 8'h68;rs_encoded_data[106] <= 8'h69;rs_encoded_data[107] <= 8'h6a;rs_encoded_data[108] <= 8'h6b;
rs_encoded_data[109] <= 8'h6c;rs_encoded_data[110] <= 8'h6d;rs_encoded_data[111] <= 8'h6e;rs_encoded_data[112] <= 8'h6f;rs_encoded_data[113] <= 8'h70;rs_encoded_data[114] <= 8'h71;
rs_encoded_data[115] <= 8'h72;rs_encoded_data[116] <= 8'h73;rs_encoded_data[117] <= 8'h74;rs_encoded_data[118] <= 8'h75;rs_encoded_data[119] <= 8'h76;rs_encoded_data[120] <= 8'h77;
rs_encoded_data[121] <= 8'h78;rs_encoded_data[122] <= 8'h79;rs_encoded_data[123] <= 8'h7a;rs_encoded_data[124] <= 8'h7b;rs_encoded_data[125] <= 8'h7c;rs_encoded_data[126] <= 8'h7d;
rs_encoded_data[127] <= 8'h7e;rs_encoded_data[128] <= 8'h7f;rs_encoded_data[129] <= 8'h80;rs_encoded_data[130] <= 8'h81;rs_encoded_data[131] <= 8'h82;rs_encoded_data[132] <= 8'h83;
rs_encoded_data[133] <= 8'h84;rs_encoded_data[134] <= 8'h85;rs_encoded_data[135] <= 8'h86;rs_encoded_data[136] <= 8'h87;rs_encoded_data[137] <= 8'h88;rs_encoded_data[138] <= 8'h89;
rs_encoded_data[139] <= 8'h8a;rs_encoded_data[140] <= 8'h8b;rs_encoded_data[141] <= 8'h8c;rs_encoded_data[142] <= 8'h8d;rs_encoded_data[143] <= 8'h8e;rs_encoded_data[144] <= 8'h8f;
rs_encoded_data[145] <= 8'h90;rs_encoded_data[146] <= 8'h91;rs_encoded_data[147] <= 8'h92;rs_encoded_data[148] <= 8'h93;rs_encoded_data[149] <= 8'h94;rs_encoded_data[150] <= 8'h95;
rs_encoded_data[151] <= 8'h96;rs_encoded_data[152] <= 8'h97;rs_encoded_data[153] <= 8'h98;rs_encoded_data[154] <= 8'h99;rs_encoded_data[155] <= 8'h9a;rs_encoded_data[156] <= 8'h9b;
rs_encoded_data[157] <= 8'h9c;rs_encoded_data[158] <= 8'h9d;rs_encoded_data[159] <= 8'h9e;rs_encoded_data[160] <= 8'h9f;rs_encoded_data[161] <= 8'ha0;rs_encoded_data[162] <= 8'ha1;
rs_encoded_data[163] <= 8'ha2;rs_encoded_data[164] <= 8'ha3;rs_encoded_data[165] <= 8'ha4;rs_encoded_data[166] <= 8'ha5;rs_encoded_data[167] <= 8'ha6;rs_encoded_data[168] <= 8'ha7;
rs_encoded_data[169] <= 8'ha8;rs_encoded_data[170] <= 8'ha9;rs_encoded_data[171] <= 8'haa;rs_encoded_data[172] <= 8'hab;rs_encoded_data[173] <= 8'hac;rs_encoded_data[174] <= 8'had;
rs_encoded_data[175] <= 8'hae;rs_encoded_data[176] <= 8'haf;rs_encoded_data[177] <= 8'hb0;rs_encoded_data[178] <= 8'hb1;rs_encoded_data[179] <= 8'hb2;rs_encoded_data[180] <= 8'hb3;
rs_encoded_data[181] <= 8'hb4;rs_encoded_data[182] <= 8'hb5;rs_encoded_data[183] <= 8'hb6;rs_encoded_data[184] <= 8'hb7;rs_encoded_data[185] <= 8'hb8;rs_encoded_data[186] <= 8'hb9;
rs_encoded_data[187] <= 8'hba;rs_encoded_data[188] <= 8'hbb;rs_encoded_data[189] <= 8'hbc;rs_encoded_data[190] <= 8'hbd;rs_encoded_data[191] <= 8'hbe;rs_encoded_data[192] <= 8'hbf;
rs_encoded_data[193] <= 8'hc0;rs_encoded_data[194] <= 8'hc1;rs_encoded_data[195] <= 8'hc2;rs_encoded_data[196] <= 8'hc3;rs_encoded_data[197] <= 8'hc4;rs_encoded_data[198] <= 8'hc5;
rs_encoded_data[199] <= 8'hc6;rs_encoded_data[200] <= 8'hc7;rs_encoded_data[201] <= 8'hc8;rs_encoded_data[202] <= 8'hc9;rs_encoded_data[203] <= 8'hca;rs_encoded_data[204] <= 8'hcb;
rs_encoded_data[205] <= 8'hcc;rs_encoded_data[206] <= 8'hcd;rs_encoded_data[207] <= 8'hce;rs_encoded_data[208] <= 8'hcf;rs_encoded_data[209] <= 8'hd0;rs_encoded_data[210] <= 8'hd1;
rs_encoded_data[211] <= 8'hd2;rs_encoded_data[212] <= 8'hd3;rs_encoded_data[213] <= 8'hd4;rs_encoded_data[214] <= 8'hd5;rs_encoded_data[215] <= 8'hd6;rs_encoded_data[216] <= 8'hd7;
rs_encoded_data[217] <= 8'hd8;rs_encoded_data[218] <= 8'hd9;rs_encoded_data[219] <= 8'hda;rs_encoded_data[220] <= 8'hdb;rs_encoded_data[221] <= 8'hdc;rs_encoded_data[222] <= 8'hdd;
rs_encoded_data[223] <= 8'h8f;rs_encoded_data[224] <= 8'hda;rs_encoded_data[225] <= 8'h30;rs_encoded_data[226] <= 8'haa;rs_encoded_data[227] <= 8'h92;rs_encoded_data[228] <= 8'h5e;
rs_encoded_data[229] <= 8'hd3;rs_encoded_data[230] <= 8'h39;rs_encoded_data[231] <= 8'hbf;rs_encoded_data[232] <= 8'h92;rs_encoded_data[233] <= 8'hc6;rs_encoded_data[234] <= 8'h93;
rs_encoded_data[235] <= 8'h2b;rs_encoded_data[236] <= 8'hf7;rs_encoded_data[237] <= 8'ha9;rs_encoded_data[238] <= 8'h67;rs_encoded_data[239] <= 8'h72;rs_encoded_data[240] <= 8'h9d;
rs_encoded_data[241] <= 8'h7b;rs_encoded_data[242] <= 8'he9;rs_encoded_data[243] <= 8'hbe;rs_encoded_data[244] <= 8'he6;rs_encoded_data[245] <= 8'hd2;rs_encoded_data[246] <= 8'hde;
rs_encoded_data[247] <= 8'he7;rs_encoded_data[248] <= 8'h6c;rs_encoded_data[249] <= 8'h7d;rs_encoded_data[250] <= 8'h4a;rs_encoded_data[251] <= 8'hc7;rs_encoded_data[252] <= 8'h1e;
rs_encoded_data[253] <= 8'h9c;rs_encoded_data[254] <= 8'h13;
											rs_encoded_data[255] <= 8'hfe;
											*/
											//------------------------

											FSMState <= `FSMSD_RS_DECODER_START;
											rsd_ce<=1; // enable reed-solomon decoder
											frame_counter <= 0;
											rsdsync<=1;
											end
										else	begin 
											frame_counter <= frame_counter + 1;
											FRAME_COUNT<=FRAME_COUNT + 1;
											frameReady <= 0; // Listo para aceptar otro frame 
											FSMState <= `FSMSD_WAIT_FOR_FRAME;
											end
										end
									else	begin
											decoded_byte <= decoded_byte + 1;
										   FSMState <=`FSMSD_COMPRESS_SYMBOL;
											end
									end
									

						// Inicializa decoder Reed-solomon
						`FSMSD_RS_DECODER_START:begin
									// Sync signal
									if (frame_counter==0)
										begin
										$display("Decoding Reed-Solomon");
										rsdsync<=0;
										end
									// Data in
									if (frame_counter==255)
										FSMState <= `FSMSD_RS_DECODER_WAIT;
									else	frame_counter <= frame_counter + 1;
									end
						// Espera que termine el decoder
						`FSMSD_RS_DECODER_WAIT: begin
									rs_decoded_data[0]<=rsd_data_out;
									if (rsd_blk_strt == 1) 
										begin
										FSMState <= `FSMSD_RS_DECODER_OUT;
										framed_counter <= 1;
										end
									end
						// Copia la salida del decoder al buffer de salida
						`FSMSD_RS_DECODER_OUT:  begin
									rs_decoded_data[framed_counter]<=rsd_data_out;
									if (rsd_blk_end)
										begin
										FSMState <= `FSMSD_END;
										rsd_ce <=0;
										end
									else	framed_counter <= framed_counter + 1;
									end

						`FSMSD_END:	begin
								$display("%dns: Decoding of block %d end",$time,FRAME_COUNT);
								if (rsd_fail==0)
									begin
									GOOD_BLOCK_COUNT<=GOOD_BLOCK_COUNT+1;
		      							BER_COUNT<=BER_COUNT+rsd_err_cnt;
									end
								else	begin
									$display("%dns: Reed Solomon decoding failed! bad block received.",$time);
									BAD_BLOCK_COUNT<=BAD_BLOCK_COUNT+1;
									BER_COUNT<=BER_COUNT+rsd_err_cnt;
									end
								frameReady <= 0; // Listo para aceptar otro frame 
								frame_counter <= 0; // Internal frame counter
								FSMState <= `FSMSD_WAIT_FOR_FRAME;
								end
						endcase
					end

	end

endmodule 


