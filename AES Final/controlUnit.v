module controlUnit (	input clock,
						input reset,
						input encOrDec,
						input [0:2] keySize,
						input [0:127] messageE,
						input [0:127] messageD,
						output reg done,
						output reg [0:135] messageOut
					);

	integer count;
	integer bottomKeyControl;
	integer bottomInvKeyControl;
	
	reg hasBegun;
	reg isInit;
	reg isFinal;
	reg [0:8] state;
	reg [0:127] newKey;
	reg [0:127] invNewKey;
	reg [0:127] arktemp;
	reg [0:127] sbtemp;
	reg [0:127] srtemp;
	reg [0:127] mctemp;

	wire keyExpDone;
	wire [0:1919] keyExp;
	
	parameter key256 = 3'b100;
	parameter key192 = 3'b010;
	parameter defaultState = 9'b000000000;
	parameter doneState = 9'b111111111;
	
	parameter beginKeyExp = 9'b110000000;
	
	parameter eSubBytes = 9'b010010000;
	parameter eShiftRows = 9'b010001000;
	parameter eMixColumns = 9'b010000100;
	parameter eKeyControl = 9'b010000010;
	parameter eAddRoundKey = 9'b010000001;
	
	parameter dInvShiftRows = 9'b000001000;
	parameter dInvSubBytes = 9'b000010000;
	parameter dInvKeyControl = 9'b000000010;
	parameter dInvAddRoundKey = 9'b000000001;
	parameter dInvMixColumns = 9'b000000100;
	
	wire [0:2047] sb =  {8'h63 ,8'h7c ,8'h77 ,8'h7b ,8'hf2 ,8'h6b ,8'h6f ,8'hc5 ,8'h30 ,8'h01 ,8'h67 ,8'h2b ,8'hfe ,8'hd7 ,8'hab ,8'h76
						,8'hca ,8'h82 ,8'hc9 ,8'h7d ,8'hfa ,8'h59 ,8'h47 ,8'hf0 ,8'had ,8'hd4 ,8'ha2 ,8'haf ,8'h9c ,8'ha4 ,8'h72 ,8'hc0
						,8'hb7 ,8'hfd ,8'h93 ,8'h26 ,8'h36 ,8'h3f ,8'hf7 ,8'hcc ,8'h34 ,8'ha5 ,8'he5 ,8'hf1 ,8'h71 ,8'hd8 ,8'h31 ,8'h15
						,8'h04 ,8'hc7 ,8'h23 ,8'hc3 ,8'h18 ,8'h96 ,8'h05 ,8'h9a ,8'h07 ,8'h12 ,8'h80 ,8'he2 ,8'heb ,8'h27 ,8'hb2 ,8'h75
						,8'h09 ,8'h83 ,8'h2c ,8'h1a ,8'h1b ,8'h6e ,8'h5a ,8'ha0 ,8'h52 ,8'h3b ,8'hd6 ,8'hb3 ,8'h29 ,8'he3 ,8'h2f ,8'h84
						,8'h53 ,8'hd1 ,8'h00 ,8'hed ,8'h20 ,8'hfc ,8'hb1 ,8'h5b ,8'h6a ,8'hcb ,8'hbe ,8'h39 ,8'h4a ,8'h4c ,8'h58 ,8'hcf
						,8'hd0 ,8'hef ,8'haa ,8'hfb ,8'h43 ,8'h4d ,8'h33 ,8'h85 ,8'h45 ,8'hf9 ,8'h02 ,8'h7f ,8'h50 ,8'h3c ,8'h9f ,8'ha8
						,8'h51 ,8'ha3 ,8'h40 ,8'h8f ,8'h92 ,8'h9d ,8'h38 ,8'hf5 ,8'hbc ,8'hb6 ,8'hda ,8'h21 ,8'h10 ,8'hff ,8'hf3 ,8'hd2
						,8'hcd ,8'h0c ,8'h13 ,8'hec ,8'h5f ,8'h97 ,8'h44 ,8'h17 ,8'hc4 ,8'ha7 ,8'h7e ,8'h3d ,8'h64 ,8'h5d ,8'h19 ,8'h73
						,8'h60 ,8'h81 ,8'h4f ,8'hdc ,8'h22 ,8'h2a ,8'h90 ,8'h88 ,8'h46 ,8'hee ,8'hb8 ,8'h14 ,8'hde ,8'h5e ,8'h0b ,8'hdb
						,8'he0 ,8'h32 ,8'h3a ,8'h0a ,8'h49 ,8'h06 ,8'h24 ,8'h5c ,8'hc2 ,8'hd3 ,8'hac ,8'h62 ,8'h91 ,8'h95 ,8'he4 ,8'h79
						,8'he7 ,8'hc8 ,8'h37 ,8'h6d ,8'h8d ,8'hd5 ,8'h4e ,8'ha9 ,8'h6c ,8'h56 ,8'hf4 ,8'hea ,8'h65 ,8'h7a ,8'hae ,8'h08
						,8'hba ,8'h78 ,8'h25 ,8'h2e ,8'h1c ,8'ha6 ,8'hb4 ,8'hc6 ,8'he8 ,8'hdd ,8'h74 ,8'h1f ,8'h4b ,8'hbd ,8'h8b ,8'h8a
						,8'h70 ,8'h3e ,8'hb5 ,8'h66 ,8'h48 ,8'h03 ,8'hf6 ,8'h0e ,8'h61 ,8'h35 ,8'h57 ,8'hb9 ,8'h86 ,8'hc1 ,8'h1d ,8'h9e
						,8'he1 ,8'hf8 ,8'h98 ,8'h11 ,8'h69 ,8'hd9 ,8'h8e ,8'h94 ,8'h9b ,8'h1e ,8'h87 ,8'he9 ,8'hce ,8'h55 ,8'h28 ,8'hdf
						,8'h8c ,8'ha1 ,8'h89 ,8'h0d ,8'hbf ,8'he6 ,8'h42 ,8'h68 ,8'h41 ,8'h99 ,8'h2d ,8'h0f ,8'hb0 ,8'h54 ,8'hbb ,8'h16};	
							
	wire [0:2047] isb =  {8'h52 ,8'h09 ,8'h6a ,8'hd5 ,8'h30 ,8'h36 ,8'ha5 ,8'h38 ,8'hbf ,8'h40 ,8'ha3 ,8'h9e ,8'h81 ,8'hf3 ,8'hd7 ,8'hfb
						 ,8'h7c ,8'he3 ,8'h39 ,8'h82 ,8'h9b ,8'h2f ,8'hff ,8'h87 ,8'h34 ,8'h8e ,8'h43 ,8'h44 ,8'hc4 ,8'hde ,8'he9 ,8'hcb
						 ,8'h54 ,8'h7b ,8'h94 ,8'h32 ,8'ha6 ,8'hc2 ,8'h23 ,8'h3d ,8'hee ,8'h4c ,8'h95 ,8'h0b ,8'h42 ,8'hfa ,8'hc3 ,8'h4e
						 ,8'h08 ,8'h2e ,8'ha1 ,8'h66 ,8'h28 ,8'hd9 ,8'h24 ,8'hb2 ,8'h76 ,8'h5b ,8'ha2 ,8'h49 ,8'h6d ,8'h8b ,8'hd1 ,8'h25
						 ,8'h72 ,8'hf8 ,8'hf6 ,8'h64 ,8'h86 ,8'h68 ,8'h98 ,8'h16 ,8'hd4 ,8'ha4 ,8'h5c ,8'hcc ,8'h5d ,8'h65 ,8'hb6 ,8'h92
						 ,8'h6c ,8'h70 ,8'h48 ,8'h50 ,8'hfd ,8'hed ,8'hb9 ,8'hda ,8'h5e ,8'h15 ,8'h46 ,8'h57 ,8'ha7 ,8'h8d ,8'h9d ,8'h84
						 ,8'h90 ,8'hd8 ,8'hab ,8'h00 ,8'h8c ,8'hbc ,8'hd3 ,8'h0a ,8'hf7 ,8'he4 ,8'h58 ,8'h05 ,8'hb8 ,8'hb3 ,8'h45 ,8'h06
						 ,8'hd0 ,8'h2c ,8'h1e ,8'h8f ,8'hca ,8'h3f ,8'h0f ,8'h02 ,8'hc1 ,8'haf ,8'hbd ,8'h03 ,8'h01 ,8'h13 ,8'h8a ,8'h6b
						 ,8'h3a ,8'h91 ,8'h11 ,8'h41 ,8'h4f ,8'h67 ,8'hdc ,8'hea ,8'h97 ,8'hf2 ,8'hcf ,8'hce ,8'hf0 ,8'hb4 ,8'he6 ,8'h73
						 ,8'h96 ,8'hac ,8'h74 ,8'h22 ,8'he7 ,8'had ,8'h35 ,8'h85 ,8'he2 ,8'hf9 ,8'h37 ,8'he8 ,8'h1c ,8'h75 ,8'hdf ,8'h6e
						 ,8'h47 ,8'hf1 ,8'h1a ,8'h71 ,8'h1d ,8'h29 ,8'hc5 ,8'h89 ,8'h6f ,8'hb7 ,8'h62 ,8'h0e ,8'haa ,8'h18 ,8'hbe ,8'h1b
						 ,8'hfc ,8'h56 ,8'h3e ,8'h4b ,8'hc6 ,8'hd2 ,8'h79 ,8'h20 ,8'h9a ,8'hdb ,8'hc0 ,8'hfe ,8'h78 ,8'hcd ,8'h5a ,8'hf4
						 ,8'h1f ,8'hdd ,8'ha8 ,8'h33 ,8'h88 ,8'h07 ,8'hc7 ,8'h31 ,8'hb1 ,8'h12 ,8'h10 ,8'h59 ,8'h27 ,8'h80 ,8'hec ,8'h5f
						 ,8'h60 ,8'h51 ,8'h7f ,8'ha9 ,8'h19 ,8'hb5 ,8'h4a ,8'h0d ,8'h2d ,8'he5 ,8'h7a ,8'h9f ,8'h93 ,8'hc9 ,8'h9c ,8'hef
						 ,8'ha0 ,8'he0 ,8'h3b ,8'h4d ,8'hae ,8'h2a ,8'hf5 ,8'hb0 ,8'hc8 ,8'heb ,8'hbb ,8'h3c ,8'h83 ,8'h53 ,8'h99 ,8'h61
						 ,8'h17 ,8'h2b ,8'h04 ,8'h7e ,8'hba ,8'h77 ,8'hd6 ,8'h26 ,8'he1 ,8'h69 ,8'h14 ,8'h63 ,8'h55 ,8'h21 ,8'h0c ,8'h7d};	
							
	wire [0:2047] mul2 = {	8'h00, 8'h02, 8'h04, 8'h06, 8'h08, 8'h0a, 8'h0c, 8'h0e, 8'h10, 8'h12, 8'h14, 8'h16, 8'h18, 8'h1a, 8'h1c, 8'h1e,
							8'h20, 8'h22, 8'h24, 8'h26, 8'h28, 8'h2a, 8'h2c, 8'h2e, 8'h30, 8'h32, 8'h34, 8'h36, 8'h38, 8'h3a, 8'h3c, 8'h3e,
							8'h40, 8'h42, 8'h44, 8'h46, 8'h48, 8'h4a, 8'h4c, 8'h4e, 8'h50, 8'h52, 8'h54, 8'h56, 8'h58, 8'h5a, 8'h5c, 8'h5e,
							8'h60, 8'h62, 8'h64, 8'h66, 8'h68, 8'h6a, 8'h6c, 8'h6e, 8'h70, 8'h72, 8'h74, 8'h76, 8'h78, 8'h7a, 8'h7c, 8'h7e,
							8'h80, 8'h82, 8'h84, 8'h86, 8'h88, 8'h8a, 8'h8c, 8'h8e, 8'h90, 8'h92, 8'h94, 8'h96, 8'h98, 8'h9a, 8'h9c, 8'h9e,
							8'ha0, 8'ha2, 8'ha4, 8'ha6, 8'ha8, 8'haa, 8'hac, 8'hae, 8'hb0, 8'hb2, 8'hb4, 8'hb6, 8'hb8, 8'hba, 8'hbc, 8'hbe,
							8'hc0, 8'hc2, 8'hc4, 8'hc6, 8'hc8, 8'hca, 8'hcc, 8'hce, 8'hd0, 8'hd2, 8'hd4, 8'hd6, 8'hd8, 8'hda, 8'hdc, 8'hde,
							8'he0, 8'he2, 8'he4, 8'he6, 8'he8, 8'hea, 8'hec, 8'hee, 8'hf0, 8'hf2, 8'hf4, 8'hf6, 8'hf8, 8'hfa, 8'hfc, 8'hfe,
							8'h1b, 8'h19, 8'h1f, 8'h1d, 8'h13, 8'h11, 8'h17, 8'h15, 8'h0b, 8'h09, 8'h0f, 8'h0d, 8'h03, 8'h01, 8'h07, 8'h05,
							8'h3b, 8'h39, 8'h3f, 8'h3d, 8'h33, 8'h31, 8'h37, 8'h35, 8'h2b, 8'h29, 8'h2f, 8'h2d, 8'h23, 8'h21, 8'h27, 8'h25,
							8'h5b, 8'h59, 8'h5f, 8'h5d, 8'h53, 8'h51, 8'h57, 8'h55, 8'h4b, 8'h49, 8'h4f, 8'h4d, 8'h43, 8'h41, 8'h47, 8'h45,
							8'h7b, 8'h79, 8'h7f, 8'h7d, 8'h73, 8'h71, 8'h77, 8'h75, 8'h6b, 8'h69, 8'h6f, 8'h6d, 8'h63, 8'h61, 8'h67, 8'h65,
							8'h9b, 8'h99, 8'h9f, 8'h9d, 8'h93, 8'h91, 8'h97, 8'h95, 8'h8b, 8'h89, 8'h8f, 8'h8d, 8'h83, 8'h81, 8'h87, 8'h85,
							8'hbb, 8'hb9, 8'hbf, 8'hbd, 8'hb3, 8'hb1, 8'hb7, 8'hb5, 8'hab, 8'ha9, 8'haf, 8'had, 8'ha3, 8'ha1, 8'ha7, 8'ha5,
							8'hdb, 8'hd9, 8'hdf, 8'hdd, 8'hd3, 8'hd1, 8'hd7, 8'hd5, 8'hcb, 8'hc9, 8'hcf, 8'hcd, 8'hc3, 8'hc1, 8'hc7, 8'hc5,
							8'hfb, 8'hf9, 8'hff, 8'hfd, 8'hf3, 8'hf1, 8'hf7, 8'hf5, 8'heb, 8'he9, 8'hef, 8'hed, 8'he3, 8'he1, 8'he7, 8'he5};
							
	wire [0:2047] mul3 = {	8'h00, 8'h03, 8'h06, 8'h05, 8'h0c, 8'h0f, 8'h0a, 8'h09, 8'h18, 8'h1b, 8'h1e, 8'h1d, 8'h14, 8'h17, 8'h12, 8'h11,
							8'h30, 8'h33, 8'h36, 8'h35, 8'h3c, 8'h3f, 8'h3a, 8'h39, 8'h28, 8'h2b, 8'h2e, 8'h2d, 8'h24, 8'h27, 8'h22, 8'h21,
							8'h60, 8'h63, 8'h66, 8'h65, 8'h6c, 8'h6f, 8'h6a, 8'h69, 8'h78, 8'h7b, 8'h7e, 8'h7d, 8'h74, 8'h77, 8'h72, 8'h71,
							8'h50, 8'h53, 8'h56, 8'h55, 8'h5c, 8'h5f, 8'h5a, 8'h59, 8'h48, 8'h4b, 8'h4e, 8'h4d, 8'h44, 8'h47, 8'h42, 8'h41,
							8'hc0, 8'hc3, 8'hc6, 8'hc5, 8'hcc, 8'hcf, 8'hca, 8'hc9, 8'hd8, 8'hdb, 8'hde, 8'hdd, 8'hd4, 8'hd7, 8'hd2, 8'hd1,
							8'hf0, 8'hf3, 8'hf6, 8'hf5, 8'hfc, 8'hff, 8'hfa, 8'hf9, 8'he8, 8'heb, 8'hee, 8'hed, 8'he4, 8'he7, 8'he2, 8'he1,
							8'ha0, 8'ha3, 8'ha6, 8'ha5, 8'hac, 8'haf, 8'haa, 8'ha9, 8'hb8, 8'hbb, 8'hbe, 8'hbd, 8'hb4, 8'hb7, 8'hb2, 8'hb1,
							8'h90, 8'h93, 8'h96, 8'h95, 8'h9c, 8'h9f, 8'h9a, 8'h99, 8'h88, 8'h8b, 8'h8e, 8'h8d, 8'h84, 8'h87, 8'h82, 8'h81,
							8'h9b, 8'h98, 8'h9d, 8'h9e, 8'h97, 8'h94, 8'h91, 8'h92, 8'h83, 8'h80, 8'h85, 8'h86, 8'h8f, 8'h8c, 8'h89, 8'h8a,
							8'hab, 8'ha8, 8'had, 8'hae, 8'ha7, 8'ha4, 8'ha1, 8'ha2, 8'hb3, 8'hb0, 8'hb5, 8'hb6, 8'hbf, 8'hbc, 8'hb9, 8'hba,
							8'hfb, 8'hf8, 8'hfd, 8'hfe, 8'hf7, 8'hf4, 8'hf1, 8'hf2, 8'he3, 8'he0, 8'he5, 8'he6, 8'hef, 8'hec, 8'he9, 8'hea,
							8'hcb, 8'hc8, 8'hcd, 8'hce, 8'hc7, 8'hc4, 8'hc1, 8'hc2, 8'hd3, 8'hd0, 8'hd5, 8'hd6, 8'hdf, 8'hdc, 8'hd9, 8'hda,
							8'h5b, 8'h58, 8'h5d, 8'h5e, 8'h57, 8'h54, 8'h51, 8'h52, 8'h43, 8'h40, 8'h45, 8'h46, 8'h4f, 8'h4c, 8'h49, 8'h4a,
							8'h6b, 8'h68, 8'h6d, 8'h6e, 8'h67, 8'h64, 8'h61, 8'h62, 8'h73, 8'h70, 8'h75, 8'h76, 8'h7f, 8'h7c, 8'h79, 8'h7a,
							8'h3b, 8'h38, 8'h3d, 8'h3e, 8'h37, 8'h34, 8'h31, 8'h32, 8'h23, 8'h20, 8'h25, 8'h26, 8'h2f, 8'h2c, 8'h29, 8'h2a,
							8'h0b, 8'h08, 8'h0d, 8'h0e, 8'h07, 8'h04, 8'h01, 8'h02, 8'h13, 8'h10, 8'h15, 8'h16, 8'h1f, 8'h1c, 8'h19, 8'h1a};
							
	wire [0:2047] mul9 = {	8'h00, 8'h09, 8'h12, 8'h1b, 8'h24, 8'h2d, 8'h36, 8'h3f, 8'h48, 8'h41, 8'h5a, 8'h53, 8'h6c, 8'h65, 8'h7e, 8'h77, 
							8'h90, 8'h99, 8'h82, 8'h8b, 8'hb4, 8'hbd, 8'ha6, 8'haf, 8'hd8, 8'hd1, 8'hca, 8'hc3, 8'hfc, 8'hf5, 8'hee, 8'he7, 
							8'h3b, 8'h32, 8'h29, 8'h20, 8'h1f, 8'h16, 8'h0d, 8'h04, 8'h73, 8'h7a, 8'h61, 8'h68, 8'h57, 8'h5e, 8'h45, 8'h4c, 
							8'hab, 8'ha2, 8'hb9, 8'hb0, 8'h8f, 8'h86, 8'h9d, 8'h94, 8'he3, 8'hea, 8'hf1, 8'hf8, 8'hc7, 8'hce, 8'hd5, 8'hdc, 
							8'h76, 8'h7f, 8'h64, 8'h6d, 8'h52, 8'h5b, 8'h40, 8'h49, 8'h3e, 8'h37, 8'h2c, 8'h25, 8'h1a, 8'h13, 8'h08, 8'h01, 
							8'he6, 8'hef, 8'hf4, 8'hfd, 8'hc2, 8'hcb, 8'hd0, 8'hd9, 8'hae, 8'ha7, 8'hbc, 8'hb5, 8'h8a, 8'h83, 8'h98, 8'h91, 
							8'h4d, 8'h44, 8'h5f, 8'h56, 8'h69, 8'h60, 8'h7b, 8'h72, 8'h05, 8'h0c, 8'h17, 8'h1e, 8'h21, 8'h28, 8'h33, 8'h3a, 
							8'hdd, 8'hd4, 8'hcf, 8'hc6, 8'hf9, 8'hf0, 8'heb, 8'he2, 8'h95, 8'h9c, 8'h87, 8'h8e, 8'hb1, 8'hb8, 8'ha3, 8'haa, 
							8'hec, 8'he5, 8'hfe, 8'hf7, 8'hc8, 8'hc1, 8'hda, 8'hd3, 8'ha4, 8'had, 8'hb6, 8'hbf, 8'h80, 8'h89, 8'h92, 8'h9b, 
							8'h7c, 8'h75, 8'h6e, 8'h67, 8'h58, 8'h51, 8'h4a, 8'h43, 8'h34, 8'h3d, 8'h26, 8'h2f, 8'h10, 8'h19, 8'h02, 8'h0b, 
							8'hd7, 8'hde, 8'hc5, 8'hcc, 8'hf3, 8'hfa, 8'he1, 8'he8, 8'h9f, 8'h96, 8'h8d, 8'h84, 8'hbb, 8'hb2, 8'ha9, 8'ha0, 
							8'h47, 8'h4e, 8'h55, 8'h5c, 8'h63, 8'h6a, 8'h71, 8'h78, 8'h0f, 8'h06, 8'h1d, 8'h14, 8'h2b, 8'h22, 8'h39, 8'h30, 
							8'h9a, 8'h93, 8'h88, 8'h81, 8'hbe, 8'hb7, 8'hac, 8'ha5, 8'hd2, 8'hdb, 8'hc0, 8'hc9, 8'hf6, 8'hff, 8'he4, 8'hed, 
							8'h0a, 8'h03, 8'h18, 8'h11, 8'h2e, 8'h27, 8'h3c, 8'h35, 8'h42, 8'h4b, 8'h50, 8'h59, 8'h66, 8'h6f, 8'h74, 8'h7d, 
							8'ha1, 8'ha8, 8'hb3, 8'hba, 8'h85, 8'h8c, 8'h97, 8'h9e, 8'he9, 8'he0, 8'hfb, 8'hf2, 8'hcd, 8'hc4, 8'hdf, 8'hd6, 
							8'h31, 8'h38, 8'h23, 8'h2a, 8'h15, 8'h1c, 8'h07, 8'h0e, 8'h79, 8'h70, 8'h6b, 8'h62, 8'h5d, 8'h54, 8'h4f, 8'h46};
							
	wire [0:2047] mul11 = {	8'h00, 8'h0b, 8'h16, 8'h1d, 8'h2c, 8'h27, 8'h3a, 8'h31, 8'h58, 8'h53, 8'h4e, 8'h45, 8'h74, 8'h7f, 8'h62, 8'h69, 
							8'hb0, 8'hbb, 8'ha6, 8'had, 8'h9c, 8'h97, 8'h8a, 8'h81, 8'he8, 8'he3, 8'hfe, 8'hf5, 8'hc4, 8'hcf, 8'hd2, 8'hd9, 
							8'h7b, 8'h70, 8'h6d, 8'h66, 8'h57, 8'h5c, 8'h41, 8'h4a, 8'h23, 8'h28, 8'h35, 8'h3e, 8'h0f, 8'h04, 8'h19, 8'h12, 
							8'hcb, 8'hc0, 8'hdd, 8'hd6, 8'he7, 8'hec, 8'hf1, 8'hfa, 8'h93, 8'h98, 8'h85, 8'h8e, 8'hbf, 8'hb4, 8'ha9, 8'ha2, 
							8'hf6, 8'hfd, 8'he0, 8'heb, 8'hda, 8'hd1, 8'hcc, 8'hc7, 8'hae, 8'ha5, 8'hb8, 8'hb3, 8'h82, 8'h89, 8'h94, 8'h9f, 
							8'h46, 8'h4d, 8'h50, 8'h5b, 8'h6a, 8'h61, 8'h7c, 8'h77, 8'h1e, 8'h15, 8'h08, 8'h03, 8'h32, 8'h39, 8'h24, 8'h2f, 
							8'h8d, 8'h86, 8'h9b, 8'h90, 8'ha1, 8'haa, 8'hb7, 8'hbc, 8'hd5, 8'hde, 8'hc3, 8'hc8, 8'hf9, 8'hf2, 8'hef, 8'he4, 
							8'h3d, 8'h36, 8'h2b, 8'h20, 8'h11, 8'h1a, 8'h07, 8'h0c, 8'h65, 8'h6e, 8'h73, 8'h78, 8'h49, 8'h42, 8'h5f, 8'h54, 
							8'hf7, 8'hfc, 8'he1, 8'hea, 8'hdb, 8'hd0, 8'hcd, 8'hc6, 8'haf, 8'ha4, 8'hb9, 8'hb2, 8'h83, 8'h88, 8'h95, 8'h9e, 
							8'h47, 8'h4c, 8'h51, 8'h5a, 8'h6b, 8'h60, 8'h7d, 8'h76, 8'h1f, 8'h14, 8'h09, 8'h02, 8'h33, 8'h38, 8'h25, 8'h2e, 
							8'h8c, 8'h87, 8'h9a, 8'h91, 8'ha0, 8'hab, 8'hb6, 8'hbd, 8'hd4, 8'hdf, 8'hc2, 8'hc9, 8'hf8, 8'hf3, 8'hee, 8'he5, 
							8'h3c, 8'h37, 8'h2a, 8'h21, 8'h10, 8'h1b, 8'h06, 8'h0d, 8'h64, 8'h6f, 8'h72, 8'h79, 8'h48, 8'h43, 8'h5e, 8'h55, 
							8'h01, 8'h0a, 8'h17, 8'h1c, 8'h2d, 8'h26, 8'h3b, 8'h30, 8'h59, 8'h52, 8'h4f, 8'h44, 8'h75, 8'h7e, 8'h63, 8'h68, 
							8'hb1, 8'hba, 8'ha7, 8'hac, 8'h9d, 8'h96, 8'h8b, 8'h80, 8'he9, 8'he2, 8'hff, 8'hf4, 8'hc5, 8'hce, 8'hd3, 8'hd8, 
							8'h7a, 8'h71, 8'h6c, 8'h67, 8'h56, 8'h5d, 8'h40, 8'h4b, 8'h22, 8'h29, 8'h34, 8'h3f, 8'h0e, 8'h05, 8'h18, 8'h13, 
							8'hca, 8'hc1, 8'hdc, 8'hd7, 8'he6, 8'hed, 8'hf0, 8'hfb, 8'h92, 8'h99, 8'h84, 8'h8f, 8'hbe, 8'hb5, 8'ha8, 8'ha3};
							
	wire [0:2047] mul13 = {	8'h00, 8'h0d, 8'h1a, 8'h17, 8'h34, 8'h39, 8'h2e, 8'h23, 8'h68, 8'h65, 8'h72, 8'h7f, 8'h5c, 8'h51, 8'h46, 8'h4b, 
							8'hd0, 8'hdd, 8'hca, 8'hc7, 8'he4, 8'he9, 8'hfe, 8'hf3, 8'hb8, 8'hb5, 8'ha2, 8'haf, 8'h8c, 8'h81, 8'h96, 8'h9b, 
							8'hbb, 8'hb6, 8'ha1, 8'hac, 8'h8f, 8'h82, 8'h95, 8'h98, 8'hd3, 8'hde, 8'hc9, 8'hc4, 8'he7, 8'hea, 8'hfd, 8'hf0, 
							8'h6b, 8'h66, 8'h71, 8'h7c, 8'h5f, 8'h52, 8'h45, 8'h48, 8'h03, 8'h0e, 8'h19, 8'h14, 8'h37, 8'h3a, 8'h2d, 8'h20, 
							8'h6d, 8'h60, 8'h77, 8'h7a, 8'h59, 8'h54, 8'h43, 8'h4e, 8'h05, 8'h08, 8'h1f, 8'h12, 8'h31, 8'h3c, 8'h2b, 8'h26, 
							8'hbd, 8'hb0, 8'ha7, 8'haa, 8'h89, 8'h84, 8'h93, 8'h9e, 8'hd5, 8'hd8, 8'hcf, 8'hc2, 8'he1, 8'hec, 8'hfb, 8'hf6, 
							8'hd6, 8'hdb, 8'hcc, 8'hc1, 8'he2, 8'hef, 8'hf8, 8'hf5, 8'hbe, 8'hb3, 8'ha4, 8'ha9, 8'h8a, 8'h87, 8'h90, 8'h9d, 
							8'h06, 8'h0b, 8'h1c, 8'h11, 8'h32, 8'h3f, 8'h28, 8'h25, 8'h6e, 8'h63, 8'h74, 8'h79, 8'h5a, 8'h57, 8'h40, 8'h4d, 
							8'hda, 8'hd7, 8'hc0, 8'hcd, 8'hee, 8'he3, 8'hf4, 8'hf9, 8'hb2, 8'hbf, 8'ha8, 8'ha5, 8'h86, 8'h8b, 8'h9c, 8'h91, 
							8'h0a, 8'h07, 8'h10, 8'h1d, 8'h3e, 8'h33, 8'h24, 8'h29, 8'h62, 8'h6f, 8'h78, 8'h75, 8'h56, 8'h5b, 8'h4c, 8'h41, 
							8'h61, 8'h6c, 8'h7b, 8'h76, 8'h55, 8'h58, 8'h4f, 8'h42, 8'h09, 8'h04, 8'h13, 8'h1e, 8'h3d, 8'h30, 8'h27, 8'h2a, 
							8'hb1, 8'hbc, 8'hab, 8'ha6, 8'h85, 8'h88, 8'h9f, 8'h92, 8'hd9, 8'hd4, 8'hc3, 8'hce, 8'hed, 8'he0, 8'hf7, 8'hfa, 
							8'hb7, 8'hba, 8'had, 8'ha0, 8'h83, 8'h8e, 8'h99, 8'h94, 8'hdf, 8'hd2, 8'hc5, 8'hc8, 8'heb, 8'he6, 8'hf1, 8'hfc, 
							8'h67, 8'h6a, 8'h7d, 8'h70, 8'h53, 8'h5e, 8'h49, 8'h44, 8'h0f, 8'h02, 8'h15, 8'h18, 8'h3b, 8'h36, 8'h21, 8'h2c, 
							8'h0c, 8'h01, 8'h16, 8'h1b, 8'h38, 8'h35, 8'h22, 8'h2f, 8'h64, 8'h69, 8'h7e, 8'h73, 8'h50, 8'h5d, 8'h4a, 8'h47, 
							8'hdc, 8'hd1, 8'hc6, 8'hcb, 8'he8, 8'he5, 8'hf2, 8'hff, 8'hb4, 8'hb9, 8'hae, 8'ha3, 8'h80, 8'h8d, 8'h9a, 8'h97};
							
	wire [0:2047] mul14 = {	8'h00, 8'h0e, 8'h1c, 8'h12, 8'h38, 8'h36, 8'h24, 8'h2a, 8'h70, 8'h7e, 8'h6c, 8'h62, 8'h48, 8'h46, 8'h54, 8'h5a, 
							8'he0, 8'hee, 8'hfc, 8'hf2, 8'hd8, 8'hd6, 8'hc4, 8'hca, 8'h90, 8'h9e, 8'h8c, 8'h82, 8'ha8, 8'ha6, 8'hb4, 8'hba, 
							8'hdb, 8'hd5, 8'hc7, 8'hc9, 8'he3, 8'hed, 8'hff, 8'hf1, 8'hab, 8'ha5, 8'hb7, 8'hb9, 8'h93, 8'h9d, 8'h8f, 8'h81, 
							8'h3b, 8'h35, 8'h27, 8'h29, 8'h03, 8'h0d, 8'h1f, 8'h11, 8'h4b, 8'h45, 8'h57, 8'h59, 8'h73, 8'h7d, 8'h6f, 8'h61, 
							8'had, 8'ha3, 8'hb1, 8'hbf, 8'h95, 8'h9b, 8'h89, 8'h87, 8'hdd, 8'hd3, 8'hc1, 8'hcf, 8'he5, 8'heb, 8'hf9, 8'hf7, 
							8'h4d, 8'h43, 8'h51, 8'h5f, 8'h75, 8'h7b, 8'h69, 8'h67, 8'h3d, 8'h33, 8'h21, 8'h2f, 8'h05, 8'h0b, 8'h19, 8'h17, 
							8'h76, 8'h78, 8'h6a, 8'h64, 8'h4e, 8'h40, 8'h52, 8'h5c, 8'h06, 8'h08, 8'h1a, 8'h14, 8'h3e, 8'h30, 8'h22, 8'h2c, 
							8'h96, 8'h98, 8'h8a, 8'h84, 8'hae, 8'ha0, 8'hb2, 8'hbc, 8'he6, 8'he8, 8'hfa, 8'hf4, 8'hde, 8'hd0, 8'hc2, 8'hcc, 
							8'h41, 8'h4f, 8'h5d, 8'h53, 8'h79, 8'h77, 8'h65, 8'h6b, 8'h31, 8'h3f, 8'h2d, 8'h23, 8'h09, 8'h07, 8'h15, 8'h1b, 
							8'ha1, 8'haf, 8'hbd, 8'hb3, 8'h99, 8'h97, 8'h85, 8'h8b, 8'hd1, 8'hdf, 8'hcd, 8'hc3, 8'he9, 8'he7, 8'hf5, 8'hfb, 
							8'h9a, 8'h94, 8'h86, 8'h88, 8'ha2, 8'hac, 8'hbe, 8'hb0, 8'hea, 8'he4, 8'hf6, 8'hf8, 8'hd2, 8'hdc, 8'hce, 8'hc0, 
							8'h7a, 8'h74, 8'h66, 8'h68, 8'h42, 8'h4c, 8'h5e, 8'h50, 8'h0a, 8'h04, 8'h16, 8'h18, 8'h32, 8'h3c, 8'h2e, 8'h20, 
							8'hec, 8'he2, 8'hf0, 8'hfe, 8'hd4, 8'hda, 8'hc8, 8'hc6, 8'h9c, 8'h92, 8'h80, 8'h8e, 8'ha4, 8'haa, 8'hb8, 8'hb6, 
							8'h0c, 8'h02, 8'h10, 8'h1e, 8'h34, 8'h3a, 8'h28, 8'h26, 8'h7c, 8'h72, 8'h60, 8'h6e, 8'h44, 8'h4a, 8'h58, 8'h56, 
							8'h37, 8'h39, 8'h2b, 8'h25, 8'h0f, 8'h01, 8'h13, 8'h1d, 8'h47, 8'h49, 8'h5b, 8'h55, 8'h7f, 8'h71, 8'h63, 8'h6d, 
							8'hd7, 8'hd9, 8'hcb, 8'hc5, 8'hef, 8'he1, 8'hf3, 8'hfd, 8'ha7, 8'ha9, 8'hbb, 8'hb5, 8'h9f, 8'h91, 8'h83, 8'h8d};
	
	always@ (posedge clock)
		begin
			if(reset)
				begin
					bottomKeyControl <= 0;
					bottomInvKeyControl <= 0;
					count <= 0;
					done <= 0;
					hasBegun <= 0;
					isInit <= 0;
					isFinal <= 0;
					messageOut <= 0;
					newKey <= 0;
					invNewKey <= 0;
					state <= defaultState;
				end
			else
				begin
					if(hasBegun == 0)
						begin
							if(keySize == key256)
								begin
									bottomInvKeyControl <= 1792;
								end
							else if(keySize == key192)
								begin
									bottomInvKeyControl <= 1536;
								end
							else
								begin
									bottomInvKeyControl <= 1280;
								end
							state <= beginKeyExp;
							hasBegun <= 1;
						end
					else
						begin
							casex (state)
								beginKeyExp:
									begin
										if(keyExpDone && encOrDec)
											begin
												state <= eKeyControl;
												isInit <= 1;
												isFinal <= 0;
											end
										else if(keyExpDone && !encOrDec)
											begin
												state <= dInvKeyControl;
												isInit <= 1;
												isFinal <= 0;
											end
									end
								eSubBytes:
									begin
									
										count <= count + 1;
										bottomKeyControl <= bottomKeyControl + 128;
										bottomInvKeyControl <= bottomInvKeyControl - 128;
									
										state <= eShiftRows;
										/////////////////////////////////////////////
										sbtemp[0:7] <= sb[arktemp[4:7] * 8 + arktemp[0:3] * 128 +: 8];
										sbtemp[8:15] <= sb[arktemp[12:15] * 8 + arktemp[8:11] * 128 +: 8];
										sbtemp[16:23] <= sb[arktemp[20:23] * 8 + arktemp[16:19] * 128 +: 8];
										sbtemp[24:31] <= sb[arktemp[28:31] * 8 + arktemp[24:27] * 128 +: 8];
										sbtemp[32:39] <= sb[arktemp[36:39] * 8 + arktemp[32:35] * 128 +: 8];
										sbtemp[40:47] <= sb[arktemp[44:47] * 8 + arktemp[40:43] * 128 +: 8];
										sbtemp[48:55] <= sb[arktemp[52:55] * 8 + arktemp[48:51] * 128 +: 8];
										sbtemp[56:63] <= sb[arktemp[60:63] * 8 + arktemp[56:59] * 128 +: 8];
										sbtemp[64:71] <= sb[arktemp[68:71] * 8 + arktemp[64:67] * 128 +: 8];
										sbtemp[72:79] <= sb[arktemp[76:79] * 8 + arktemp[72:75] * 128 +: 8];
										sbtemp[80:87] <= sb[arktemp[84:87] * 8 + arktemp[80:83] * 128 +: 8];
										sbtemp[88:95] <= sb[arktemp[92:95] * 8 + arktemp[88:91] * 128 +: 8];
										sbtemp[96:103] <= sb[arktemp[100:103] * 8 + arktemp[96:99] * 128 +: 8];
										sbtemp[104:111] <= sb[arktemp[108:111] * 8 + arktemp[104:107] * 128 +: 8];
										sbtemp[112:119] <= sb[arktemp[116:119] * 8 + arktemp[112:115] * 128 +: 8];
										sbtemp[120:127] <= sb[arktemp[124:127] * 8 + arktemp[120:123] * 128 +: 8];	
										/////////////////////////////////////////////
									end
								eShiftRows:
									begin
										if(isFinal)
											begin
												state <= eKeyControl;
											end
										else
											begin
												state <= eMixColumns;
											end
										/////////////////////////////////////////////
										srtemp[0:7] <= sbtemp[0:7];
										srtemp[8:15] <= sbtemp[40:47];
										srtemp[16:23] <= sbtemp[80:87];
										srtemp[24:31] <= sbtemp[120:127];
										srtemp[32:39] <= sbtemp[32:39];
										srtemp[40:47] <= sbtemp[72:79];
										srtemp[48:55] <= sbtemp[112:119];
										srtemp[56:63] <= sbtemp[24:31];
										srtemp[64:71] <= sbtemp[64:71];
										srtemp[72:79] <= sbtemp[104:111];
										srtemp[80:87] <= sbtemp[16:23];				
										srtemp[88:95] <= sbtemp[56:63];				
										srtemp[96:103] <= sbtemp[96:103];
										srtemp[104:111] <= sbtemp[8:15];
										srtemp[112:119] <= sbtemp[48:55];
										srtemp[120:127] <= sbtemp[88:95];
										/////////////////////////////////////////////
									end
								eMixColumns:
									begin
										state <= eKeyControl;
										/////////////////////////////////////////////
										mctemp[0:7] <= (mul2[srtemp[4:7] * 8 + srtemp[0:3] * 128 +: 8]) ^ (mul3[srtemp[12:15] * 8 + srtemp[8:11] * 128 +: 8]) ^ srtemp[16:23] ^ srtemp[24:31];
										mctemp[8:15] <= (mul2[srtemp[12:15] * 8 + srtemp[8:11] * 128 +: 8]) ^ (mul3[srtemp[20:23] * 8 + srtemp[16:19] * 128 +: 8]) ^ srtemp[0:7] ^ srtemp[24:31];
										mctemp[16:23] <= (mul2[srtemp[20:23] * 8 + srtemp[16:19] * 128 +: 8]) ^ (mul3[srtemp[28:31] * 8 + srtemp[24:27] * 128 +: 8]) ^ srtemp[0:7] ^ srtemp[8:15];
										mctemp[24:31] <= (mul2[srtemp[28:31] * 8 + srtemp[24:27] * 128 +: 8]) ^ (mul3[srtemp[4:7] * 8 + srtemp[0:3] * 128 +: 8]) ^ srtemp[8:15] ^ srtemp[16:23];
										mctemp[32:39] <= (mul2[srtemp[36:39] * 8 + srtemp[32:35] * 128 +: 8]) ^ (mul3[srtemp[44:47] * 8 + srtemp[40:43] * 128 +: 8]) ^ srtemp[48:55] ^ srtemp[56:63];
										mctemp[40:47] <= (mul2[srtemp[44:47] * 8 + srtemp[40:43] * 128 +: 8]) ^ (mul3[srtemp[52:55] * 8 + srtemp[48:51] * 128 +: 8]) ^ srtemp[32:39] ^ srtemp[56:63];
										mctemp[48:55] <= (mul2[srtemp[52:55] * 8 + srtemp[48:51] * 128 +: 8]) ^ (mul3[srtemp[60:63] * 8 + srtemp[56:59] * 128 +: 8]) ^ srtemp[32:39] ^ srtemp[40:47];
										mctemp[56:63] <= (mul2[srtemp[60:63] * 8 + srtemp[56:59] * 128 +: 8]) ^ (mul3[srtemp[36:39] * 8 + srtemp[32:35] * 128 +: 8]) ^ srtemp[40:47] ^ srtemp[48:55];
										mctemp[64:71] <= (mul2[srtemp[68:71] * 8 + srtemp[64:67] * 128 +: 8]) ^ (mul3[srtemp[76:79] * 8 + srtemp[72:75] * 128 +: 8]) ^ srtemp[80:87] ^ srtemp[88:95];
										mctemp[72:79] <= (mul2[srtemp[76:79] * 8 + srtemp[72:75] * 128 +: 8]) ^ (mul3[srtemp[84:87] * 8 + srtemp[80:83] * 128 +: 8]) ^ srtemp[64:71] ^ srtemp[88:95];
										mctemp[80:87] <= (mul2[srtemp[84:87] * 8 + srtemp[80:83] * 128 +: 8]) ^ (mul3[srtemp[92:95] * 8 + srtemp[88:91] * 128 +: 8]) ^ srtemp[64:71] ^ srtemp[72:79];
										mctemp[88:95] <= (mul2[srtemp[92:95] * 8 + srtemp[88:91] * 128 +: 8]) ^ (mul3[srtemp[68:71] * 8 + srtemp[64:67] * 128 +: 8]) ^ srtemp[72:79] ^ srtemp[80:87];
										mctemp[96:103] <= (mul2[srtemp[100:103] * 8 + srtemp[96:99] * 128 +: 8]) ^ (mul3[srtemp[108:111] * 8 + srtemp[104:107] * 128 +: 8]) ^ srtemp[112:119] ^ srtemp[120:127];
										mctemp[104:111] <= (mul2[srtemp[108:111] * 8 + srtemp[104:107] * 128 +: 8]) ^ (mul3[srtemp[116:119] * 8 + srtemp[112:115] * 128 +: 8]) ^ srtemp[96:103] ^ srtemp[120:127];
										mctemp[112:119] <= (mul2[srtemp[116:119] * 8 + srtemp[112:115] * 128 +: 8]) ^ (mul3[srtemp[124:127] * 8 + srtemp[120:123] * 128 +: 8]) ^ srtemp[96:103] ^ srtemp[104:111];
										mctemp[120:127] <= (mul2[srtemp[124:127] * 8 + srtemp[120:123] * 128 +: 8]) ^ (mul3[srtemp[100:103] * 8 + srtemp[96:99] * 128 +: 8]) ^ srtemp[104:111] ^ srtemp[112:119];
										/////////////////////////////////////////////
									end
								eKeyControl:
									begin
										newKey <= keyExp[bottomKeyControl +: 128];
										state <= eAddRoundKey;
									end
								eAddRoundKey: 
									begin
										if(isInit)
											begin
												isInit <= 0;
												arktemp <= messageE ^ newKey;
												state <= eSubBytes;
											end
										else if(isFinal)
											begin
												isFinal <= 0;
												messageOut[7:135] <= srtemp ^ newKey;
												state <= doneState;
											end
										else
											begin
												if((keySize == key256 && count == 13) ||
													(keySize == key192 && count == 11) ||
													(keySize != key256 && keySize != key192 && count == 9))
													begin
														isFinal <= 1;	
													end
												arktemp <= mctemp ^ newKey;
												state <= eSubBytes;										
											end				
									end
								dInvShiftRows:
									begin
									
										count <= count + 1;
										bottomKeyControl <= bottomKeyControl + 128;
										bottomInvKeyControl <= bottomInvKeyControl - 128;
									
										state <= dInvSubBytes;
										
										if(isInit == 1)
											begin
												/////////////////////////////////////////////
												srtemp[0:7] <= arktemp[0:7];
												srtemp[8:15] <= arktemp[104:111];
												srtemp[16:23] <= arktemp[80:87];
												srtemp[24:31] <= arktemp[56:63];
												srtemp[32:39] <= arktemp[32:39];
												srtemp[40:47] <= arktemp[8:15];
												srtemp[48:55] <= arktemp[112:119];
												srtemp[56:63] <= arktemp[88:95];
												srtemp[64:71] <= arktemp[64:71];
												srtemp[72:79] <= arktemp[40:47];
												srtemp[80:87] <= arktemp[16:23];				
												srtemp[88:95] <= arktemp[120:127];				
												srtemp[96:103] <= arktemp[96:103];
												srtemp[104:111] <= arktemp[72:79];
												srtemp[112:119] <= arktemp[48:55];
												srtemp[120:127] <= arktemp[24:31];
												/////////////////////////////////////////////	
												isInit <= 0;
											end
										else
											begin
												/////////////////////////////////////////////
												srtemp[0:7] <= mctemp[0:7];
												srtemp[8:15] <= mctemp[104:111];
												srtemp[16:23] <= mctemp[80:87];
												srtemp[24:31] <= mctemp[56:63];
												srtemp[32:39] <= mctemp[32:39];
												srtemp[40:47] <= mctemp[8:15];
												srtemp[48:55] <= mctemp[112:119];
												srtemp[56:63] <= mctemp[88:95];
												srtemp[64:71] <= mctemp[64:71];
												srtemp[72:79] <= mctemp[40:47];
												srtemp[80:87] <= mctemp[16:23];				
												srtemp[88:95] <= mctemp[120:127];				
												srtemp[96:103] <= mctemp[96:103];
												srtemp[104:111] <= mctemp[72:79];
												srtemp[112:119] <= mctemp[48:55];
												srtemp[120:127] <= mctemp[24:31];
												/////////////////////////////////////////////
											end
									end
								dInvSubBytes:
									begin
										state <= dInvKeyControl;
										/////////////////////////////////////////////
										sbtemp[0:7] <= isb[srtemp[4:7] * 8 + srtemp[0:3] * 128 +: 8];
										sbtemp[8:15] <= isb[srtemp[12:15] * 8 + srtemp[8:11] * 128 +: 8];
										sbtemp[16:23] <= isb[srtemp[20:23] * 8 + srtemp[16:19] * 128 +: 8];
										sbtemp[24:31] <= isb[srtemp[28:31] * 8 + srtemp[24:27] * 128 +: 8];
										sbtemp[32:39] <= isb[srtemp[36:39] * 8 + srtemp[32:35] * 128 +: 8];
										sbtemp[40:47] <= isb[srtemp[44:47] * 8 + srtemp[40:43] * 128 +: 8];
										sbtemp[48:55] <= isb[srtemp[52:55] * 8 + srtemp[48:51] * 128 +: 8];
										sbtemp[56:63] <= isb[srtemp[60:63] * 8 + srtemp[56:59] * 128 +: 8];
										sbtemp[64:71] <= isb[srtemp[68:71] * 8 + srtemp[64:67] * 128 +: 8];
										sbtemp[72:79] <= isb[srtemp[76:79] * 8 + srtemp[72:75] * 128 +: 8];
										sbtemp[80:87] <= isb[srtemp[84:87] * 8 + srtemp[80:83] * 128 +: 8];
										sbtemp[88:95] <= isb[srtemp[92:95] * 8 + srtemp[88:91] * 128 +: 8];
										sbtemp[96:103] <= isb[srtemp[100:103] * 8 + srtemp[96:99] * 128 +: 8];
										sbtemp[104:111] <= isb[srtemp[108:111] * 8 + srtemp[104:107] * 128 +: 8];
										sbtemp[112:119] <= isb[srtemp[116:119] * 8 + srtemp[112:115] * 128 +: 8];
										sbtemp[120:127] <= isb[srtemp[124:127] * 8 + srtemp[120:123] * 128 +: 8];			
										/////////////////////////////////////////////
									end
								dInvKeyControl:
									begin
										invNewKey <= keyExp[bottomInvKeyControl +: 128];
										state <= dInvAddRoundKey;
									end
								dInvAddRoundKey: 
									begin
										if(isInit)
											begin
												arktemp <= messageD ^ invNewKey;
												state <= dInvShiftRows;
											end
										else if(isFinal)
											begin
												isFinal <= 0;
												messageOut <= sbtemp ^ invNewKey;
												state <= doneState;
											end
										else
											begin
												if((keySize == key256 && count == 13) ||
													(keySize == key192 && count == 11) ||
													(keySize != key256 && keySize != key192 && count == 9))
													begin
														isFinal <= 1;	
													end
												arktemp <= sbtemp ^ invNewKey;
												state <= dInvMixColumns;										
											end	
									end
								dInvMixColumns:
									begin
										state <= dInvShiftRows;
										/////////////////////////////////////////////
										mctemp[0:7] <= (mul14[arktemp[4:7] * 8 + arktemp[0:3] * 128 +: 8]) ^ (mul11[arktemp[12:15] * 8 + arktemp[8:11] * 128 +: 8])
																			^ (mul13[arktemp[20:23] * 8 + arktemp[16:19] * 128 +: 8]) ^ (mul9[arktemp[28:31] * 8 + arktemp[24:27] * 128 +: 8]);
										mctemp[8:15] <= (mul14[arktemp[12:15] * 8 + arktemp[8:11] * 128 +: 8]) ^ (mul11[arktemp[20:23] * 8 + arktemp[16:19] * 128 +: 8])
																			^ (mul13[arktemp[28:31] * 8 + arktemp[24:27] * 128 +: 8]) ^ (mul9[arktemp[4:7] * 8 + arktemp[0:3] * 128 +: 8]);
										mctemp[16:23] <= (mul14[arktemp[20:23] * 8 + arktemp[16:19] * 128 +: 8]) ^ (mul11[arktemp[28:31] * 8 + arktemp[24:27] * 128 +: 8])
																			^ (mul13[arktemp[4:7] * 8 + arktemp[0:3] * 128 +: 8]) ^ (mul9[arktemp[12:15] * 8 + arktemp[8:11] * 128 +: 8]);
										mctemp[24:31] <= (mul14[arktemp[28:31] * 8 + arktemp[24:27] * 128 +: 8]) ^ (mul11[arktemp[4:7] * 8 + arktemp[0:3] * 128 +: 8])
																			^ (mul13[arktemp[12:15] * 8 + arktemp[8:11] * 128 +: 8]) ^ (mul9[arktemp[20:23] * 8 + arktemp[16:19] * 128 +: 8]);
										
										mctemp[32:39] <= (mul14[arktemp[36:39] * 8 + arktemp[32:35] * 128 +: 8]) ^ (mul11[arktemp[44:47] * 8 + arktemp[40:43] * 128 +: 8])
																			^ (mul13[arktemp[52:55] * 8 + arktemp[48:51] * 128 +: 8]) ^ (mul9[arktemp[60:63] * 8 + arktemp[56:59] * 128 +: 8]);
										mctemp[40:47] <= (mul14[arktemp[44:47] * 8 + arktemp[40:43] * 128 +: 8]) ^ (mul11[arktemp[52:55] * 8 + arktemp[48:51] * 128 +: 8])
																			^ (mul13[arktemp[60:63] * 8 + arktemp[56:59] * 128 +: 8]) ^ (mul9[arktemp[36:39] * 8 + arktemp[32:35] * 128 +: 8]);
										mctemp[48:55] <= (mul14[arktemp[52:55] * 8 + arktemp[48:51] * 128 +: 8]) ^ (mul11[arktemp[60:63] * 8 + arktemp[56:59] * 128 +: 8])
																			^ (mul13[arktemp[36:39] * 8 + arktemp[32:35] * 128 +: 8]) ^ (mul9[arktemp[44:47] * 8 + arktemp[40:43] * 128 +: 8]);
										mctemp[56:63] <= (mul14[arktemp[60:63] * 8 + arktemp[56:59] * 128 +: 8]) ^ (mul11[arktemp[36:39] * 8 + arktemp[32:35] * 128 +: 8])
																			^ (mul13[arktemp[44:47] * 8 + arktemp[40:43] * 128 +: 8]) ^ (mul9[arktemp[52:55] * 8 + arktemp[48:51] * 128 +: 8]);
																			
										mctemp[64:71] <= (mul14[arktemp[68:71] * 8 + arktemp[64:67] * 128 +: 8]) ^ (mul11[arktemp[76:79] * 8 + arktemp[72:75] * 128 +: 8])
																			^ (mul13[arktemp[84:87] * 8 + arktemp[80:83] * 128 +: 8]) ^ (mul9[arktemp[92:95] * 8 + arktemp[88:91] * 128 +: 8]);
										mctemp[72:79] <= (mul14[arktemp[76:79] * 8 + arktemp[72:75] * 128 +: 8]) ^ (mul11[arktemp[84:87] * 8 + arktemp[80:83] * 128 +: 8])
																			^ (mul13[arktemp[92:95] * 8 + arktemp[88:91] * 128 +: 8]) ^ (mul9[arktemp[68:71] * 8 + arktemp[64:67] * 128 +: 8]);
										mctemp[80:87] <= (mul14[arktemp[84:87] * 8 + arktemp[80:83] * 128 +: 8]) ^ (mul11[arktemp[92:95] * 8 + arktemp[88:91] * 128 +: 8])
																			^ (mul13[arktemp[68:71] * 8 + arktemp[64:67] * 128 +: 8]) ^ (mul9[arktemp[76:79] * 8 + arktemp[72:75] * 128 +: 8]);
										mctemp[88:95] <= (mul14[arktemp[92:95] * 8 + arktemp[88:91] * 128 +: 8]) ^ (mul11[arktemp[68:71] * 8 + arktemp[64:67] * 128 +: 8])
																			^ (mul13[arktemp[76:79] * 8 + arktemp[72:75] * 128 +: 8]) ^ (mul9[arktemp[84:87] * 8 + arktemp[80:83] * 128 +: 8]);
																			
										mctemp[96:103] <= (mul14[arktemp[100:103] * 8 + arktemp[96:99] * 128 +: 8]) ^ (mul11[arktemp[108:111] * 8 + arktemp[104:107] * 128 +: 8])
																			^ (mul13[arktemp[116:119] * 8 + arktemp[112:115] * 128 +: 8]) ^ (mul9[arktemp[124:127] * 8 + arktemp[120:123] * 128 +: 8]);
										mctemp[104:111] <= (mul14[arktemp[108:111] * 8 + arktemp[104:107] * 128 +: 8]) ^ (mul11[arktemp[116:119] * 8 + arktemp[112:115] * 128 +: 8])
																			^ (mul13[arktemp[124:127] * 8 + arktemp[120:123] * 128 +: 8]) ^ (mul9[arktemp[100:103] * 8 + arktemp[96:99] * 128 +: 8]);
										mctemp[112:119] <= (mul14[arktemp[116:119] * 8 + arktemp[112:115] * 128 +: 8]) ^ (mul11[arktemp[124:127] * 8 + arktemp[120:123] * 128 +: 8])
																			^ (mul13[arktemp[100:103] * 8 + arktemp[96:99] * 128 +: 8]) ^ (mul9[arktemp[108:111] * 8 + arktemp[104:107] * 128 +: 8]);
										mctemp[120:127] <= (mul14[arktemp[124:127] * 8 + arktemp[120:123] * 128 +: 8]) ^ (mul11[arktemp[100:103] * 8 + arktemp[96:99] * 128 +: 8])
																			^ (mul13[arktemp[108:111] * 8 + arktemp[104:107] * 128 +: 8]) ^ (mul9[arktemp[116:119] * 8 + arktemp[112:115] * 128 +: 8]);
										/////////////////////////////////////////////									
									end
								doneState: 
									begin
										done <= 1;
									end
								default:
									begin
										state <= defaultState;
									end
							endcase
						end
				end
	end
								
keyExpansion keyExpansion(	clock,
							reset, 					// input reset
							keySize,				// either 10, 12, or 14 rounds
							keyExpDone,
							keyExp); 				// unsigned 176-byte expanded key

endmodule