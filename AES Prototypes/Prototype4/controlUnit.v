module controlUnit (	input clk,
						input rst,
						input start,
						input encOrDec,
						input [0:2] keySize,
						input [0:127] messageIn,
						output reg doneE,
						output reg doneD,
						output reg [0:127] messageOut,
						output reg [6:0] HEX0,
						output reg [6:0] HEX1,
						output reg [6:0] HEX2,
						output reg [6:0] HEX3,
						output reg [6:0] HEX4,
						output reg [6:0] HEX5,
						output reg [6:0] HEX6,
						output reg [6:0] HEX7
					);

	integer count;
	reg [0:8] state;
	reg [0:8] nextstate;
	
	reg check;
	
	reg [0:127] tempmessage;
	reg [0:127] nexttempmessage;
	
	reg enableKeyExpansion;
	reg enableInvKeyControl;
	reg enableKeyControl;

	wire [0:127] newKey;
	wire [0:127] invNewKey;
	wire [0:1919] keyExp;
	
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
	
	//state <= encOrDec, keyexpansion, initialround, finalround, subbytes, shiftrows, mixcolumns, keycontrol, addroundkey
	
	always@ (posedge clk)
		if(rst)
			begin
				state <= 9'b000000000;
				tempmessage <= 128'b0;
				count <= 0;
				check <= 1'b1;
			end
		else
			begin
				if(check == 1'b1)
					begin
						if(encOrDec)
							begin
								state <= 9'b110000000;
							end
						else
							begin
								state <= 9'b010000000;
							end
						check <= 1'b0;
					end
				else
					begin
						state <= nextstate;
						tempmessage <= nexttempmessage;
						if(nextstate == 9'b010000001 || nextstate == 9'b000000100)
							begin
								count <= count + 1;
							end
					end
			end
	
	always@ (*)
		begin
			if(rst)
				begin
					enableKeyExpansion <= 1'b0;
					enableKeyControl <= 1'b0;
					enableInvKeyControl <= 1'b0;				
					doneE <= 1'b0;
					doneD <= 1'b0;
					nextstate <= 9'b000000000;
					nexttempmessage <= 128'b0;
				end
			else
				begin
					casex(state)
						//encrypt
						//keyExpansion
						9'b110000000:
						// 0x80
							begin
								nextstate <= 9'b011000010;
								enableKeyExpansion <= 1'b1;
								HEX0 <= 7'b0000110;				// E
								HEX1 <= 7'b0001010;				// K
								HEX2 <= 7'b1111111;
								HEX3 <= 7'b1111111;
								HEX4 <= 7'b1111111;
								HEX5 <= 7'b1111111;
								HEX6 <= 7'b0101011;				// N
								HEX7 <= 7'b0000110;				// E
							end
						//initialRound keyControl
						9'b011000010:
						// 0xc2
							begin
								nextstate <= 9'b011000000;
								enableKeyExpansion <= 1'b0;
								enableKeyControl <= 1'b1;
								HEX0 <= 7'b1000110;				// C
								HEX1 <= 7'b0001010;				// K
								HEX2 <= 7'b1111111;
								HEX3 <= 7'b1111111;
								HEX4 <= 7'b1101110;				// I
								HEX5 <= 7'b1111111;
								HEX6 <= 7'b0101011;				// N
								HEX7 <= 7'b0000110;				// E
							end
						//initialRound addRoundKey
						9'b011000000: 
						// 0xc0
							begin
								nextstate <= 9'b010010000;
								enableKeyControl <= 1'b0;
								/////////////////////////////////////////////
								nexttempmessage <= messageIn ^ newKey;
								/////////////////////////////////////////////
								HEX0 <= 7'b0001010;				// K
								HEX1 <= 7'b0101111;				// R
								HEX2 <= 7'b0001000;				// A
								HEX3 <= 7'b1111111;
								HEX4 <= 7'b1101110;				// I
								HEX5 <= 7'b1111111;
								HEX6 <= 7'b0101011;				// N
								HEX7 <= 7'b0000110;				// E
							end
						//finalRound subBytes
						9'b010110000:
						// 0xb0
							begin
								nextstate <= 9'b010101000;
								/////////////////////////////////////////////
								nexttempmessage[0:7] <= sb[tempmessage[4:7] * 8 + tempmessage[0:3] * 128 +: 8];
								nexttempmessage[8:15] <= sb[tempmessage[12:15] * 8 + tempmessage[8:11] * 128 +: 8];
								nexttempmessage[16:23] <= sb[tempmessage[20:23] * 8 + tempmessage[16:19] * 128 +: 8];
								nexttempmessage[24:31] <= sb[tempmessage[28:31] * 8 + tempmessage[24:27] * 128 +: 8];
								nexttempmessage[32:39] <= sb[tempmessage[36:39] * 8 + tempmessage[32:35] * 128 +: 8];
								nexttempmessage[40:47] <= sb[tempmessage[44:47] * 8 + tempmessage[40:43] * 128 +: 8];
								nexttempmessage[48:55] <= sb[tempmessage[52:55] * 8 + tempmessage[48:51] * 128 +: 8];
								nexttempmessage[56:63] <= sb[tempmessage[60:63] * 8 + tempmessage[56:59] * 128 +: 8];
								nexttempmessage[64:71] <= sb[tempmessage[68:71] * 8 + tempmessage[64:67] * 128 +: 8];
								nexttempmessage[72:79] <= sb[tempmessage[76:79] * 8 + tempmessage[72:75] * 128 +: 8];
								nexttempmessage[80:87] <= sb[tempmessage[84:87] * 8 + tempmessage[80:83] * 128 +: 8];
								nexttempmessage[88:95] <= sb[tempmessage[92:95] * 8 + tempmessage[88:91] * 128 +: 8];
								nexttempmessage[96:103] <= sb[tempmessage[100:103] * 8 + tempmessage[96:99] * 128 +: 8];
								nexttempmessage[104:111] <= sb[tempmessage[108:111] * 8 + tempmessage[104:107] * 128 +: 8];
								nexttempmessage[112:119] <= sb[tempmessage[116:119] * 8 + tempmessage[112:115] * 128 +: 8];
								nexttempmessage[120:127] <= sb[tempmessage[124:127] * 8 + tempmessage[120:123] * 128 +: 8];		
								/////////////////////////////////////////////
								HEX0 <= 7'b0000011;				// B
								HEX1 <= 7'b1010010;				// S
								HEX2 <= 7'b1111111;
								HEX3 <= 7'b1111111;
								HEX4 <= 7'b0001110;				// F
								HEX5 <= 7'b1111111;
								HEX6 <= 7'b0101011;				// N
								HEX7 <= 7'b0000110;				// E
							end
						//finalRound shiftRows
						9'b010101000: 
						// 0xa8
							begin
								nextstate <= 9'b010100010;
								/////////////////////////////////////////////
								nexttempmessage[0:7] <= tempmessage[0:7];
								nexttempmessage[8:15] <= tempmessage[40:47];
								nexttempmessage[16:23] <= tempmessage[80:87];
								nexttempmessage[24:31] <= tempmessage[120:127];
								nexttempmessage[32:39] <= tempmessage[32:39];
								nexttempmessage[40:47] <= tempmessage[72:79];
								nexttempmessage[48:55] <= tempmessage[112:119];
								nexttempmessage[56:63] <= tempmessage[24:31];
								nexttempmessage[64:71] <= tempmessage[64:71];
								nexttempmessage[72:79] <= tempmessage[104:111];
								nexttempmessage[80:87] <= tempmessage[16:23];				
								nexttempmessage[88:95] <= tempmessage[56:63];				
								nexttempmessage[96:103] <= tempmessage[96:103];
								nexttempmessage[104:111] <= tempmessage[8:15];
								nexttempmessage[112:119] <= tempmessage[48:55];
								nexttempmessage[120:127] <= tempmessage[88:95];
								/////////////////////////////////////////////		
								HEX0 <= 7'b0101111;				// R
								HEX1 <= 7'b1010010;				// S
								HEX2 <= 7'b1111111;
								HEX3 <= 7'b1111111;
								HEX4 <= 7'b0001110;				// F
								HEX5 <= 7'b1111111;
								HEX6 <= 7'b0101011;				// N
								HEX7 <= 7'b0000110;				// E
							end
						//finalRound keyControl
						9'b010100010:
						// 0xa2
							begin
								nextstate <= 9'b010100001;
								enableKeyControl <= 1'b1;
								HEX0 <= 7'b1000110;				// C
								HEX1 <= 7'b0001010;				// K
								HEX2 <= 7'b1111111;
								HEX3 <= 7'b1111111;
								HEX4 <= 7'b0001110;				// F
								HEX5 <= 7'b1111111;
								HEX6 <= 7'b0101011;				// N
								HEX7 <= 7'b0000110;				// E
							end
						//finalRound addRoundKey
						9'b010100001: 
						// 0xa1
							begin
								nextstate <= 9'b111101110;
								enableKeyControl <= 1'b0;
								/////////////////////////////////////////////
								messageOut <= tempmessage ^ newKey;
								/////////////////////////////////////////////
								HEX0 <= 7'b0001010;				// K
								HEX1 <= 7'b0101111;				// R
								HEX2 <= 7'b0001000;				// A
								HEX3 <= 7'b1111111;
								HEX4 <= 7'b0001110;				// F
								HEX5 <= 7'b1111111;
								HEX6 <= 7'b0101011;				// N
								HEX7 <= 7'b0000110;				// E
							end
						//subBytes
						9'b010010000:
						// 0x90
							begin
								nextstate <= 9'b010001000;
								/////////////////////////////////////////////
								nexttempmessage[0:7] <= sb[tempmessage[4:7] * 8 + tempmessage[0:3] * 128 +: 8];
								nexttempmessage[8:15] <= sb[tempmessage[12:15] * 8 + tempmessage[8:11] * 128 +: 8];
								nexttempmessage[16:23] <= sb[tempmessage[20:23] * 8 + tempmessage[16:19] * 128 +: 8];
								nexttempmessage[24:31] <= sb[tempmessage[28:31] * 8 + tempmessage[24:27] * 128 +: 8];
								nexttempmessage[32:39] <= sb[tempmessage[36:39] * 8 + tempmessage[32:35] * 128 +: 8];
								nexttempmessage[40:47] <= sb[tempmessage[44:47] * 8 + tempmessage[40:43] * 128 +: 8];
								nexttempmessage[48:55] <= sb[tempmessage[52:55] * 8 + tempmessage[48:51] * 128 +: 8];
								nexttempmessage[56:63] <= sb[tempmessage[60:63] * 8 + tempmessage[56:59] * 128 +: 8];
								nexttempmessage[64:71] <= sb[tempmessage[68:71] * 8 + tempmessage[64:67] * 128 +: 8];
								nexttempmessage[72:79] <= sb[tempmessage[76:79] * 8 + tempmessage[72:75] * 128 +: 8];
								nexttempmessage[80:87] <= sb[tempmessage[84:87] * 8 + tempmessage[80:83] * 128 +: 8];
								nexttempmessage[88:95] <= sb[tempmessage[92:95] * 8 + tempmessage[88:91] * 128 +: 8];
								nexttempmessage[96:103] <= sb[tempmessage[100:103] * 8 + tempmessage[96:99] * 128 +: 8];
								nexttempmessage[104:111] <= sb[tempmessage[108:111] * 8 + tempmessage[104:107] * 128 +: 8];
								nexttempmessage[112:119] <= sb[tempmessage[116:119] * 8 + tempmessage[112:115] * 128 +: 8];
								nexttempmessage[120:127] <= sb[tempmessage[124:127] * 8 + tempmessage[120:123] * 128 +: 8];		
								/////////////////////////////////////////////
								HEX0 <= 7'b0000011;				// B
								HEX1 <= 7'b1010010;				// S
								HEX2 <= 7'b1111111;
								HEX3 <= 7'b1111111;
								HEX4 <= 7'b0101111;				// R
								HEX5 <= 7'b1111111;
								HEX6 <= 7'b0101011;				// N
								HEX7 <= 7'b0000110;				// E
							end
						//shiftRows
						9'b010001000:
						// 0x88
							begin
								nextstate <= 9'b010000100;
								/////////////////////////////////////////////
								nexttempmessage[0:7] <= tempmessage[0:7];
								nexttempmessage[8:15] <= tempmessage[40:47];
								nexttempmessage[16:23] <= tempmessage[80:87];
								nexttempmessage[24:31] <= tempmessage[120:127];
								nexttempmessage[32:39] <= tempmessage[32:39];
								nexttempmessage[40:47] <= tempmessage[72:79];
								nexttempmessage[48:55] <= tempmessage[112:119];
								nexttempmessage[56:63] <= tempmessage[24:31];
								nexttempmessage[64:71] <= tempmessage[64:71];
								nexttempmessage[72:79] <= tempmessage[104:111];
								nexttempmessage[80:87] <= tempmessage[16:23];				
								nexttempmessage[88:95] <= tempmessage[56:63];				
								nexttempmessage[96:103] <= tempmessage[96:103];
								nexttempmessage[104:111] <= tempmessage[8:15];
								nexttempmessage[112:119] <= tempmessage[48:55];
								nexttempmessage[120:127] <= tempmessage[88:95];
								/////////////////////////////////////////////
								HEX0 <= 7'b0101111;				// R
								HEX1 <= 7'b1010010;				// S
								HEX2 <= 7'b1111111;
								HEX3 <= 7'b1111111;
								HEX4 <= 7'b0101111;				// R
								HEX5 <= 7'b1111111;
								HEX6 <= 7'b0101011;				// N
								HEX7 <= 7'b0000110;				// E
							end
						//mixColumns
						9'b010000100:
						// 0x84
							begin
								nextstate <= 9'b010000010;
								/////////////////////////////////////////////
								nexttempmessage[0:7] <= (mul2[tempmessage[4:7] * 8 + tempmessage[0:3] * 128 +: 8]) ^ (mul3[tempmessage[12:15] * 8 + tempmessage[8:11] * 128 +: 8]) ^ tempmessage[16:23] ^ tempmessage[24:31];
								nexttempmessage[8:15] <= (mul2[tempmessage[12:15] * 8 + tempmessage[8:11] * 128 +: 8]) ^ (mul3[tempmessage[20:23] * 8 + tempmessage[16:19] * 128 +: 8]) ^ tempmessage[0:7] ^ tempmessage[24:31];
								nexttempmessage[16:23] <= (mul2[tempmessage[20:23] * 8 + tempmessage[16:19] * 128 +: 8]) ^ (mul3[tempmessage[28:31] * 8 + tempmessage[24:27] * 128 +: 8]) ^ tempmessage[0:7] ^ tempmessage[8:15];
								nexttempmessage[24:31] <= (mul2[tempmessage[28:31] * 8 + tempmessage[24:27] * 128 +: 8]) ^ (mul3[tempmessage[4:7] * 8 + tempmessage[0:3] * 128 +: 8]) ^ tempmessage[8:15] ^ tempmessage[16:23];
								nexttempmessage[32:39] <= (mul2[tempmessage[36:39] * 8 + tempmessage[32:35] * 128 +: 8]) ^ (mul3[tempmessage[44:47] * 8 + tempmessage[40:43] * 128 +: 8]) ^ tempmessage[48:55] ^ tempmessage[56:63];
								nexttempmessage[40:47] <= (mul2[tempmessage[44:47] * 8 + tempmessage[40:43] * 128 +: 8]) ^ (mul3[tempmessage[52:55] * 8 + tempmessage[48:51] * 128 +: 8]) ^ tempmessage[32:39] ^ tempmessage[56:63];
								nexttempmessage[48:55] <= (mul2[tempmessage[52:55] * 8 + tempmessage[48:51] * 128 +: 8]) ^ (mul3[tempmessage[60:63] * 8 + tempmessage[56:59] * 128 +: 8]) ^ tempmessage[32:39] ^ tempmessage[40:47];
								nexttempmessage[56:63] <= (mul2[tempmessage[60:63] * 8 + tempmessage[56:59] * 128 +: 8]) ^ (mul3[tempmessage[36:39] * 8 + tempmessage[32:35] * 128 +: 8]) ^ tempmessage[40:47] ^ tempmessage[48:55];
								nexttempmessage[64:71] <= (mul2[tempmessage[68:71] * 8 + tempmessage[64:67] * 128 +: 8]) ^ (mul3[tempmessage[76:79] * 8 + tempmessage[72:75] * 128 +: 8]) ^ tempmessage[80:87] ^ tempmessage[88:95];
								nexttempmessage[72:79] <= (mul2[tempmessage[76:79] * 8 + tempmessage[72:75] * 128 +: 8]) ^ (mul3[tempmessage[84:87] * 8 + tempmessage[80:83] * 128 +: 8]) ^ tempmessage[64:71] ^ tempmessage[88:95];
								nexttempmessage[80:87] <= (mul2[tempmessage[84:87] * 8 + tempmessage[80:83] * 128 +: 8]) ^ (mul3[tempmessage[92:95] * 8 + tempmessage[88:91] * 128 +: 8]) ^ tempmessage[64:71] ^ tempmessage[72:79];
								nexttempmessage[88:95] <= (mul2[tempmessage[92:95] * 8 + tempmessage[88:91] * 128 +: 8]) ^ (mul3[tempmessage[68:71] * 8 + tempmessage[64:67] * 128 +: 8]) ^ tempmessage[72:79] ^ tempmessage[80:87];
								nexttempmessage[96:103] <= (mul2[tempmessage[100:103] * 8 + tempmessage[96:99] * 128 +: 8]) ^ (mul3[tempmessage[108:111] * 8 + tempmessage[104:107] * 128 +: 8]) ^ tempmessage[112:119] ^ tempmessage[120:127];
								nexttempmessage[104:111] <= (mul2[tempmessage[108:111] * 8 + tempmessage[104:107] * 128 +: 8]) ^ (mul3[tempmessage[116:119] * 8 + tempmessage[112:115] * 128 +: 8]) ^ tempmessage[96:103] ^ tempmessage[120:127];
								nexttempmessage[112:119] <= (mul2[tempmessage[116:119] * 8 + tempmessage[112:115] * 128 +: 8]) ^ (mul3[tempmessage[124:127] * 8 + tempmessage[120:123] * 128 +: 8]) ^ tempmessage[96:103] ^ tempmessage[104:111];
								nexttempmessage[120:127] <= (mul2[tempmessage[124:127] * 8 + tempmessage[120:123] * 128 +: 8]) ^ (mul3[tempmessage[100:103] * 8 + tempmessage[96:99] * 128 +: 8]) ^ tempmessage[104:111] ^ tempmessage[112:119];
								/////////////////////////////////////////////
								HEX0 <= 7'b1000110;				// C
								HEX1 <= 7'b0101010;				// M
								HEX2 <= 7'b1111111;
								HEX3 <= 7'b1111111;
								HEX4 <= 7'b0101111;				// R
								HEX5 <= 7'b1111111;
								HEX6 <= 7'b0101011;				// N
								HEX7 <= 7'b0000110;				// E
							end
						//keyControl
						9'b010000010:
						// 0x82
							begin
								nextstate <= 9'b010000001;
								enableKeyControl <= 1'b1;
								HEX0 <= 7'b1000110;				// C
								HEX1 <= 7'b0001010;				// K
								HEX2 <= 7'b1111111;
								HEX3 <= 7'b1111111;
								HEX4 <= 7'b0101111;				// R
								HEX5 <= 7'b1111111;
								HEX6 <= 7'b0101011;				// N
								HEX7 <= 7'b0000110;				// E
							end
						//addRoundKey
						9'b010000001: 
						// 0x81
							begin
								if(keySize == 3'b100 && count == 13)
									begin
										nextstate <= 9'b010110000;	
									end
								else if(keySize == 3'b010 && count == 11)
									begin
										nextstate <= 9'b010110000;
									end
								else if(keySize != 3'b100 && keySize != 3'b010 && count == 9)
									begin
										nextstate <= 9'b010110000;
									end
								else
									begin
										nextstate <= 9'b010010000;										
									end
									
								enableKeyControl <= 1'b0;
								/////////////////////////////////////////////
								nexttempmessage <= tempmessage ^ newKey;
								/////////////////////////////////////////////
								HEX0 <= 7'b0001010;				// K
								HEX1 <= 7'b0101111;				// R
								HEX2 <= 7'b0001000;				// A
								HEX3 <= 7'b1111111;
								HEX4 <= 7'b0101111;				// R
								HEX5 <= 7'b1111111;
								HEX6 <= 7'b0101011;				// N
								HEX7 <= 7'b0000110;				// E
							end
						9'b111101110:
						// 0xEE
							begin
								nextstate <= 9'b111101110;
								doneE <= 1'b1;
								HEX0 <= 7'b0000110;				// E
								HEX1 <= 7'b0101011;				// N
								HEX2 <= 7'b0100011;				// O
								HEX3 <= 7'b0100001;				// D
								HEX4 <= 7'b1111111;
								HEX5 <= 7'b1111111;
								HEX6 <= 7'b0101011;				// N
								HEX7 <= 7'b0000110;				// E
							end
							
						//decrypt	
						//keyExpansion
						9'b010000000:
						// 0x80
							begin
								nextstate <= 9'b001000010;
								enableKeyExpansion <= 1'b1;
								HEX0 <= 7'b0000110;				// E
								HEX1 <= 7'b0001010;				// K
								HEX2 <= 7'b1111111;				
								HEX3 <= 7'b1111111;				
								HEX4 <= 7'b1111111;
								HEX5 <= 7'b1111111;
								HEX6 <= 7'b0000110;				// E
								HEX7 <= 7'b0100001;				// D
							end
						//initialRound invKeyControl
						9'b001000010:
						// 0x42
							begin
								nextstate <= 9'b001000001;
								enableKeyExpansion <= 1'b0;
								enableInvKeyControl <= 1'b1;
								HEX0 <= 7'b1000110;				// C
								HEX1 <= 7'b0001010;				// K
								HEX2 <= 7'b1111111;				
								HEX3 <= 7'b1111111;				
								HEX4 <= 7'b1101110;				// I
								HEX5 <= 7'b1111111;
								HEX6 <= 7'b0000110;				// E
								HEX7 <= 7'b0100001;				// D
							end
						//initialRound invAddRoundKey
						9'b001000001:
						// 0x41
							begin
								nextstate <= 9'b000001000;
								/////////////////////////////////////////////
								nexttempmessage <= messageIn ^ invNewKey;
								/////////////////////////////////////////////
								enableInvKeyControl <= 1'b0;
								HEX0 <= 7'b0001010;				// K
								HEX1 <= 7'b0101111;				// R
								HEX2 <= 7'b0001000;				// A
								HEX3 <= 7'b1101110;				// I
								HEX4 <= 7'b1101110;				// I
								HEX5 <= 7'b1111111;
								HEX6 <= 7'b0000110;				// E
								HEX7 <= 7'b0100001;				// D
							end
						//finalRound invShiftRows
						9'b000101000:
						// 0x28
							begin
								nextstate <= 9'b000110000;
								/////////////////////////////////////////////
								nexttempmessage[0:7] <= tempmessage[0:7];
								nexttempmessage[8:15] <= tempmessage[104:111];
								nexttempmessage[16:23] <= tempmessage[80:87];
								nexttempmessage[24:31] <= tempmessage[56:63];
								nexttempmessage[32:39] <= tempmessage[32:39];
								nexttempmessage[40:47] <= tempmessage[8:15];
								nexttempmessage[48:55] <= tempmessage[112:119];
								nexttempmessage[56:63] <= tempmessage[88:95];
								nexttempmessage[64:71] <= tempmessage[64:71];
								nexttempmessage[72:79] <= tempmessage[40:47];
								nexttempmessage[80:87] <= tempmessage[16:23];				
								nexttempmessage[88:95] <= tempmessage[120:127];				
								nexttempmessage[96:103] <= tempmessage[96:103];
								nexttempmessage[104:111] <= tempmessage[72:79];
								nexttempmessage[112:119] <= tempmessage[48:55];
								nexttempmessage[120:127] <= tempmessage[24:31];
								/////////////////////////////////////////////								
								HEX0 <= 7'b0101111;				// R
								HEX1 <= 7'b1010010;				// S
								HEX2 <= 7'b1101110;				// I
								HEX3 <= 7'b1111111;				
								HEX4 <= 7'b0001110;				// F
								HEX5 <= 7'b1111111;
								HEX6 <= 7'b0000110;				// E
								HEX7 <= 7'b0100001;				// D
							end
						//finalRound invSubBytes	
						9'b000110000: 
						// 0x30
							begin
								nextstate <= 9'b000100010;
								/////////////////////////////////////////////
								nexttempmessage[0:7] <= isb[tempmessage[4:7] * 8 + tempmessage[0:3] * 128 +: 8];
								nexttempmessage[8:15] <= isb[tempmessage[12:15] * 8 + tempmessage[8:11] * 128 +: 8];
								nexttempmessage[16:23] <= isb[tempmessage[20:23] * 8 + tempmessage[16:19] * 128 +: 8];
								nexttempmessage[24:31] <= isb[tempmessage[28:31] * 8 + tempmessage[24:27] * 128 +: 8];
								nexttempmessage[32:39] <= isb[tempmessage[36:39] * 8 + tempmessage[32:35] * 128 +: 8];
								nexttempmessage[40:47] <= isb[tempmessage[44:47] * 8 + tempmessage[40:43] * 128 +: 8];
								nexttempmessage[48:55] <= isb[tempmessage[52:55] * 8 + tempmessage[48:51] * 128 +: 8];
								nexttempmessage[56:63] <= isb[tempmessage[60:63] * 8 + tempmessage[56:59] * 128 +: 8];
								nexttempmessage[64:71] <= isb[tempmessage[68:71] * 8 + tempmessage[64:67] * 128 +: 8];
								nexttempmessage[72:79] <= isb[tempmessage[76:79] * 8 + tempmessage[72:75] * 128 +: 8];
								nexttempmessage[80:87] <= isb[tempmessage[84:87] * 8 + tempmessage[80:83] * 128 +: 8];
								nexttempmessage[88:95] <= isb[tempmessage[92:95] * 8 + tempmessage[88:91] * 128 +: 8];
								nexttempmessage[96:103] <= isb[tempmessage[100:103] * 8 + tempmessage[96:99] * 128 +: 8];
								nexttempmessage[104:111] <= isb[tempmessage[108:111] * 8 + tempmessage[104:107] * 128 +: 8];
								nexttempmessage[112:119] <= isb[tempmessage[116:119] * 8 + tempmessage[112:115] * 128 +: 8];
								nexttempmessage[120:127] <= isb[tempmessage[124:127] * 8 + tempmessage[120:123] * 128 +: 8];			
								/////////////////////////////////////////////
								HEX0 <= 7'b0000011;				// B
								HEX1 <= 7'b1010010;				// S
								HEX2 <= 7'b1101110;				// I
								HEX3 <= 7'b1111111;				
								HEX4 <= 7'b0001110;				// F
								HEX5 <= 7'b1111111;
								HEX6 <= 7'b0000110;				// E
								HEX7 <= 7'b0100001;				// D
							end
						//finalRound invKeyControl
						9'b000100010:
						// 0x22
							begin
								nextstate <= 9'b000100001;
								enableInvKeyControl <= 1'b1;
								HEX0 <= 7'b1000110;				// C
								HEX1 <= 7'b0001010;				// K
								HEX2 <= 7'b1101110;				// I
								HEX3 <= 7'b1111111;				
								HEX4 <= 7'b0001110;				// F
								HEX5 <= 7'b1111111;
								HEX6 <= 7'b0000110;				// E
								HEX7 <= 7'b0100001;				// D
							end
						//finalRound invAddRoundKey
						9'b000100001: 
						// 0x21
							begin
								nextstate <= 9'b111011101;
								enableKeyControl <= 1'b0;
								/////////////////////////////////////////////
								messageOut <= tempmessage ^ invNewKey;
								/////////////////////////////////////////////
								HEX0 <= 7'b0001010;				// K
								HEX1 <= 7'b0101111;				// R
								HEX2 <= 7'b0001000;				// A
								HEX3 <= 7'b1101110;				// I
								HEX4 <= 7'b0001110;				// F
								HEX5 <= 7'b1111111;
								HEX6 <= 7'b0000110;				// E
								HEX7 <= 7'b0100001;				// D
							end
						//invShiftRows
						9'b000001000:
						// 0x08
							begin
								nextstate <= 9'b000010000;
								/////////////////////////////////////////////
								nexttempmessage[0:7] <= tempmessage[0:7];
								nexttempmessage[8:15] <= tempmessage[104:111];
								nexttempmessage[16:23] <= tempmessage[80:87];
								nexttempmessage[24:31] <= tempmessage[56:63];
								nexttempmessage[32:39] <= tempmessage[32:39];
								nexttempmessage[40:47] <= tempmessage[8:15];
								nexttempmessage[48:55] <= tempmessage[112:119];
								nexttempmessage[56:63] <= tempmessage[88:95];
								nexttempmessage[64:71] <= tempmessage[64:71];
								nexttempmessage[72:79] <= tempmessage[40:47];
								nexttempmessage[80:87] <= tempmessage[16:23];				
								nexttempmessage[88:95] <= tempmessage[120:127];				
								nexttempmessage[96:103] <= tempmessage[96:103];
								nexttempmessage[104:111] <= tempmessage[72:79];
								nexttempmessage[112:119] <= tempmessage[48:55];
								nexttempmessage[120:127] <= tempmessage[24:31];
								/////////////////////////////////////////////								
								HEX0 <= 7'b0101111;				// R
								HEX1 <= 7'b1010010;				// S
								HEX2 <= 7'b1101110;				// I
								HEX3 <= 7'b1111111;				
								HEX4 <= 7'b0101111;				// R
								HEX5 <= 7'b1111111;
								HEX6 <= 7'b0000110;				// E
								HEX7 <= 7'b0100001;				// D
							end
						//invSubBytes
						9'b000010000:
						// 0x10
							begin
								nextstate <= 9'b000000010;
								/////////////////////////////////////////////
								nexttempmessage[0:7] <= isb[tempmessage[4:7] * 8 + tempmessage[0:3] * 128 +: 8];
								nexttempmessage[8:15] <= isb[tempmessage[12:15] * 8 + tempmessage[8:11] * 128 +: 8];
								nexttempmessage[16:23] <= isb[tempmessage[20:23] * 8 + tempmessage[16:19] * 128 +: 8];
								nexttempmessage[24:31] <= isb[tempmessage[28:31] * 8 + tempmessage[24:27] * 128 +: 8];
								nexttempmessage[32:39] <= isb[tempmessage[36:39] * 8 + tempmessage[32:35] * 128 +: 8];
								nexttempmessage[40:47] <= isb[tempmessage[44:47] * 8 + tempmessage[40:43] * 128 +: 8];
								nexttempmessage[48:55] <= isb[tempmessage[52:55] * 8 + tempmessage[48:51] * 128 +: 8];
								nexttempmessage[56:63] <= isb[tempmessage[60:63] * 8 + tempmessage[56:59] * 128 +: 8];
								nexttempmessage[64:71] <= isb[tempmessage[68:71] * 8 + tempmessage[64:67] * 128 +: 8];
								nexttempmessage[72:79] <= isb[tempmessage[76:79] * 8 + tempmessage[72:75] * 128 +: 8];
								nexttempmessage[80:87] <= isb[tempmessage[84:87] * 8 + tempmessage[80:83] * 128 +: 8];
								nexttempmessage[88:95] <= isb[tempmessage[92:95] * 8 + tempmessage[88:91] * 128 +: 8];
								nexttempmessage[96:103] <= isb[tempmessage[100:103] * 8 + tempmessage[96:99] * 128 +: 8];
								nexttempmessage[104:111] <= isb[tempmessage[108:111] * 8 + tempmessage[104:107] * 128 +: 8];
								nexttempmessage[112:119] <= isb[tempmessage[116:119] * 8 + tempmessage[112:115] * 128 +: 8];
								nexttempmessage[120:127] <= isb[tempmessage[124:127] * 8 + tempmessage[120:123] * 128 +: 8];			
								/////////////////////////////////////////////
								HEX0 <= 7'b0000011;				// B
								HEX1 <= 7'b1010010;				// S
								HEX2 <= 7'b1101110;				// I
								HEX3 <= 7'b1111111;				
								HEX4 <= 7'b0101111;				// R
								HEX5 <= 7'b1111111;
								HEX6 <= 7'b0000110;				// E
								HEX7 <= 7'b0100001;				// D
							end
						//invKeyControl
						9'b000000010:
						// 0x02
							begin
								nextstate <= 9'b000000001;
								enableInvKeyControl <= 1'b1;
								HEX0 <= 7'b1000110;				// C
								HEX1 <= 7'b0001010;				// K
								HEX2 <= 7'b1101110;				// I
								HEX3 <= 7'b1111111;				
								HEX4 <= 7'b0101111;				// R
								HEX5 <= 7'b1111111;
								HEX6 <= 7'b0000110;				// E
								HEX7 <= 7'b0100001;				// D
							end
						//invAddRoundKey
						9'b000000001: 
						// 0x01
							begin
								nextstate <= 9'b000000100;
								/////////////////////////////////////////////
								nexttempmessage <= tempmessage ^ invNewKey;
								/////////////////////////////////////////////
								enableInvKeyControl <= 1'b0;
								HEX0 <= 7'b0001010;				// K
								HEX1 <= 7'b0101111;				// R
								HEX2 <= 7'b0001000;				// A
								HEX3 <= 7'b1101110;				// I
								HEX4 <= 7'b0101111;				// R
								HEX5 <= 7'b1111111;
								HEX6 <= 7'b0000110;				// E
								HEX7 <= 7'b0100001;				// D
							end
						//invMixColumns
						9'b000000100:
						// 0x04
							begin
								if(keySize == 3'b100 && count == 13)
									begin
										nextstate <= 9'b000101000;
									end
								else if(keySize == 3'b010 && count == 11)
									begin
										nextstate <= 9'b000101000;	
									end
								else if(keySize != 3'b100 && keySize != 3'b010 && count == 9)
									begin
										nextstate <= 9'b000101000;
									end
								else
									begin
										nextstate <= 9'b000001000;
									end
								/////////////////////////////////////////////
								nexttempmessage[0:7] <= (mul14[tempmessage[4:7] * 8 + tempmessage[0:3] * 128 +: 8]) ^ (mul11[tempmessage[12:15] * 8 + tempmessage[8:11] * 128 +: 8])
																	^ (mul13[tempmessage[20:23] * 8 + tempmessage[16:19] * 128 +: 8]) ^ (mul9[tempmessage[28:31] * 8 + tempmessage[24:27] * 128 +: 8]);
								nexttempmessage[8:15] <= (mul14[tempmessage[12:15] * 8 + tempmessage[8:11] * 128 +: 8]) ^ (mul11[tempmessage[20:23] * 8 + tempmessage[16:19] * 128 +: 8])
																	^ (mul13[tempmessage[28:31] * 8 + tempmessage[24:27] * 128 +: 8]) ^ (mul9[tempmessage[4:7] * 8 + tempmessage[0:3] * 128 +: 8]);
								nexttempmessage[16:23] <= (mul14[tempmessage[20:23] * 8 + tempmessage[16:19] * 128 +: 8]) ^ (mul11[tempmessage[28:31] * 8 + tempmessage[24:27] * 128 +: 8])
																	^ (mul13[tempmessage[4:7] * 8 + tempmessage[0:3] * 128 +: 8]) ^ (mul9[tempmessage[12:15] * 8 + tempmessage[8:11] * 128 +: 8]);
								nexttempmessage[24:31] <= (mul14[tempmessage[28:31] * 8 + tempmessage[24:27] * 128 +: 8]) ^ (mul11[tempmessage[4:7] * 8 + tempmessage[0:3] * 128 +: 8])
																	^ (mul13[tempmessage[12:15] * 8 + tempmessage[8:11] * 128 +: 8]) ^ (mul9[tempmessage[20:23] * 8 + tempmessage[16:19] * 128 +: 8]);
								
								nexttempmessage[32:39] <= (mul14[tempmessage[36:39] * 8 + tempmessage[32:35] * 128 +: 8]) ^ (mul11[tempmessage[44:47] * 8 + tempmessage[40:43] * 128 +: 8])
																	^ (mul13[tempmessage[52:55] * 8 + tempmessage[48:51] * 128 +: 8]) ^ (mul9[tempmessage[60:63] * 8 + tempmessage[56:59] * 128 +: 8]);
								nexttempmessage[40:47] <= (mul14[tempmessage[44:47] * 8 + tempmessage[40:43] * 128 +: 8]) ^ (mul11[tempmessage[52:55] * 8 + tempmessage[48:51] * 128 +: 8])
																	^ (mul13[tempmessage[60:63] * 8 + tempmessage[56:59] * 128 +: 8]) ^ (mul9[tempmessage[36:39] * 8 + tempmessage[32:35] * 128 +: 8]);
								nexttempmessage[48:55] <= (mul14[tempmessage[52:55] * 8 + tempmessage[48:51] * 128 +: 8]) ^ (mul11[tempmessage[60:63] * 8 + tempmessage[56:59] * 128 +: 8])
																	^ (mul13[tempmessage[36:39] * 8 + tempmessage[32:35] * 128 +: 8]) ^ (mul9[tempmessage[44:47] * 8 + tempmessage[40:43] * 128 +: 8]);
								nexttempmessage[56:63] <= (mul14[tempmessage[60:63] * 8 + tempmessage[56:59] * 128 +: 8]) ^ (mul11[tempmessage[36:39] * 8 + tempmessage[32:35] * 128 +: 8])
																	^ (mul13[tempmessage[44:47] * 8 + tempmessage[40:43] * 128 +: 8]) ^ (mul9[tempmessage[52:55] * 8 + tempmessage[48:51] * 128 +: 8]);
																	
								nexttempmessage[64:71] <= (mul14[tempmessage[68:71] * 8 + tempmessage[64:67] * 128 +: 8]) ^ (mul11[tempmessage[76:79] * 8 + tempmessage[72:75] * 128 +: 8])
																	^ (mul13[tempmessage[84:87] * 8 + tempmessage[80:83] * 128 +: 8]) ^ (mul9[tempmessage[92:95] * 8 + tempmessage[88:91] * 128 +: 8]);
								nexttempmessage[72:79] <= (mul14[tempmessage[76:79] * 8 + tempmessage[72:75] * 128 +: 8]) ^ (mul11[tempmessage[84:87] * 8 + tempmessage[80:83] * 128 +: 8])
																	^ (mul13[tempmessage[92:95] * 8 + tempmessage[88:91] * 128 +: 8]) ^ (mul9[tempmessage[68:71] * 8 + tempmessage[64:67] * 128 +: 8]);
								nexttempmessage[80:87] <= (mul14[tempmessage[84:87] * 8 + tempmessage[80:83] * 128 +: 8]) ^ (mul11[tempmessage[92:95] * 8 + tempmessage[88:91] * 128 +: 8])
																	^ (mul13[tempmessage[68:71] * 8 + tempmessage[64:67] * 128 +: 8]) ^ (mul9[tempmessage[76:79] * 8 + tempmessage[72:75] * 128 +: 8]);
								nexttempmessage[88:95] <= (mul14[tempmessage[92:95] * 8 + tempmessage[88:91] * 128 +: 8]) ^ (mul11[tempmessage[68:71] * 8 + tempmessage[64:67] * 128 +: 8])
																	^ (mul13[tempmessage[76:79] * 8 + tempmessage[72:75] * 128 +: 8]) ^ (mul9[tempmessage[84:87] * 8 + tempmessage[80:83] * 128 +: 8]);
																	
								nexttempmessage[96:103] <= (mul14[tempmessage[100:103] * 8 + tempmessage[96:99] * 128 +: 8]) ^ (mul11[tempmessage[108:111] * 8 + tempmessage[104:107] * 128 +: 8])
																	^ (mul13[tempmessage[116:119] * 8 + tempmessage[112:115] * 128 +: 8]) ^ (mul9[tempmessage[124:127] * 8 + tempmessage[120:123] * 128 +: 8]);
								nexttempmessage[104:111] <= (mul14[tempmessage[108:111] * 8 + tempmessage[104:107] * 128 +: 8]) ^ (mul11[tempmessage[116:119] * 8 + tempmessage[112:115] * 128 +: 8])
																	^ (mul13[tempmessage[124:127] * 8 + tempmessage[120:123] * 128 +: 8]) ^ (mul9[tempmessage[100:103] * 8 + tempmessage[96:99] * 128 +: 8]);
								nexttempmessage[112:119] <= (mul14[tempmessage[116:119] * 8 + tempmessage[112:115] * 128 +: 8]) ^ (mul11[tempmessage[124:127] * 8 + tempmessage[120:123] * 128 +: 8])
																	^ (mul13[tempmessage[100:103] * 8 + tempmessage[96:99] * 128 +: 8]) ^ (mul9[tempmessage[108:111] * 8 + tempmessage[104:107] * 128 +: 8]);
								nexttempmessage[120:127] <= (mul14[tempmessage[124:127] * 8 + tempmessage[120:123] * 128 +: 8]) ^ (mul11[tempmessage[100:103] * 8 + tempmessage[96:99] * 128 +: 8])
																	^ (mul13[tempmessage[108:111] * 8 + tempmessage[104:107] * 128 +: 8]) ^ (mul9[tempmessage[116:119] * 8 + tempmessage[112:115] * 128 +: 8]);
								/////////////////////////////////////////////									
								
								HEX0 <= 7'b1000110;				// C
								HEX1 <= 7'b0101010;				// M
								HEX2 <= 7'b1101110;				// I
								HEX3 <= 7'b1111111;				
								HEX4 <= 7'b0101111;				// R
								HEX5 <= 7'b1111111;
								HEX6 <= 7'b0000110;				// E
								HEX7 <= 7'b0100001;				// D
							end
						// doneDecrypt
						9'b111011101: 
						// 0xDD
							begin
								nextstate <= 9'b111011101;
								doneD <= 1'b1;
								HEX0 <= 7'b0000110;				// E
								HEX1 <= 7'b0101011;				// N
								HEX2 <= 7'b0100011;				// O
								HEX3 <= 7'b0100001;				// D
								HEX4 <= 7'b1111111;	
								HEX5 <= 7'b1111111;
								HEX6 <= 7'b0000110;				// E
								HEX7 <= 7'b0100001;				// D
							end
						default:
							begin
								nextstate <= 9'b000000000;
								HEX0 <= 7'b1111111;				
								HEX1 <= 7'b1111111;				
								HEX2 <= 7'b1111111;				
								HEX3 <= 7'b1111111;				
								HEX4 <= 7'b1111111;				
								HEX5 <= 7'b1111111;
								HEX6 <= 7'b1111111;				
								HEX7 <= 7'b1111111;				
							end
					endcase
			end
		end
								
keyExpansion keyExpansion(	rst, 					// input reset
							enableKeyExpansion, 	// begin keyExpansion
							keySize,				// either 10, 12, or 14 rounds
							keyExp); 				// unsigned 176-byte expanded key
							
keyControl keyControl( 	rst, 						// input reset
						enableKeyControl,			// begin keyControl
						keyExp,						// unsigned 176-byte expanded key
						newKey);					// output key for rounds
						
invKeyControl invKeyControl(	rst,
								enableInvKeyControl,
								keyExp,					// unsigned 176-byte expanded key
								keySize,
								invNewKey);				// output key for invRounds

endmodule