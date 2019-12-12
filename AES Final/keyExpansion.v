module keyExpansion(	input clock,
						input reset, 							// input reset
						input [2:0] keySize,				// either 10, 12, or 14 rounds
						output reg keyExpDone,
						output reg [0:1919] keyExp); 		// unsigned 176-byte expanded key		
	
	integer count;
	integer keyPlace;
	
	reg hasBegun;
	reg [0:6] state;
	reg [0:7] rcon;
	reg [0:31] tempKeyRotate;
	reg [0:31] tempKeySubByte;
	reg [0:31] tempKeySubByte256;
	reg [0:31] tempKeyRcon;
	reg [0:31] tempKey0;
	reg [0:31] tempKey1;
	reg [0:31] tempKey2;
	reg [0:31] tempKey3;
	reg [0:31] tempKey4;
	reg [0:31] tempKey5;
	reg [0:31] tempKey6;
	reg [0:31] tempKey7;
	
	parameter key192 = 3'b010;
	parameter key256 = 3'b100;
	parameter defaultState = 7'b000_0000;
	parameter doneState = 7'b111_1111;
	
	parameter key128begin = 7'b001_0000;
	parameter key128split = 7'b001_0001;
	parameter key128rotate = 7'b001_0010;
	parameter key128sub = 7'b001_0011;
	parameter key128rcon = 7'b001_0100;
	parameter key128temp0 = 7'b001_0101;
	parameter key128temp1 = 7'b001_0110;
	parameter key128temp2 = 7'b001_0111;
	parameter key128temp3 = 7'b001_1000;
	parameter key128set = 7'b001_1001;
	
	parameter key192begin = 7'b010_0000;
	parameter key192split = 7'b010_0001;
	parameter key192rotate = 7'b010_0010;
	parameter key192sub = 7'b010_0011;
	parameter key192rcon = 7'b010_0100;
	parameter key192temp0 = 7'b010_0101;
	parameter key192temp1 = 7'b010_0110;
	parameter key192temp2 = 7'b010_0111;
	parameter key192temp3 = 7'b010_1000;
	parameter key192temp4 = 7'b010_1001;
	parameter key192temp5 = 7'b010_1010;
	parameter key192set = 7'b010_1011;
	
	parameter key256begin = 7'b100_0000;
	parameter key256split = 7'b100_0001;
	parameter key256rotate = 7'b100_0010;
	parameter key256sub = 7'b100_0011;
	parameter key256rcon = 7'b100_0100;
	parameter key256temp0 = 7'b100_0101;
	parameter key256temp1 = 7'b100_0110;
	parameter key256temp2 = 7'b100_0111;
	parameter key256temp3 = 7'b100_1000;
	parameter key256extra = 7'b100_1001;
	parameter key256temp4 = 7'b100_1010;
	parameter key256temp5 = 7'b100_1011;
	parameter key256temp6 = 7'b100_1100;
	parameter key256temp7 = 7'b100_1101;
	parameter key256set = 7'b100_1110;
	
	wire [0:255] key = {8'h00, 8'h01, 8'h02, 8'h03,		// unsigned 16-byte test key
						8'h04, 8'h05, 8'h06, 8'h07,		// unsigned 16-byte test key
						8'h08, 8'h09, 8'h0a, 8'h0b,		// unsigned 16-byte test key
						8'h0c, 8'h0d, 8'h0e, 8'h0f,		// unsigned 16-byte test key
						8'h10, 8'h11, 8'h12, 8'h13,		// unsigned 16-byte test key
						8'h14, 8'h15, 8'h16, 8'h17,		// unsigned 16-byte test key
						8'h18, 8'h19, 8'h1a, 8'h1b,		// unsigned 16-byte test key
						8'h1c, 8'h1d, 8'h1e, 8'h1f};	// unsigned 16-byte test key
	
	wire [0:2047] cypher =  {8'h63 ,8'h7c ,8'h77 ,8'h7b ,8'hf2 ,8'h6b ,8'h6f ,8'hc5 ,8'h30 ,8'h01 ,8'h67 ,8'h2b ,8'hfe ,8'hd7 ,8'hab ,8'h76
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
	
	always@ (posedge clock)
		begin
			if(reset)
				begin
					count <= 0;
					hasBegun <= 0;
					keyPlace <= 0;
					keyExpDone <= 0;
					rcon <= 1;
					state <= defaultState;
				end
			else
				begin
					if(hasBegun == 0)
						begin
							if(keySize == key192)
								begin
									state <= key192begin;
								end
							else if(keySize == key256)
								begin
									state <= key256begin;
								end
							else
								begin
									state <= key128begin;
								end
							hasBegun <= 1;
						end
					else
						begin						
							casex (state)
								key192begin:
									begin
										keyExp[0:191] <= key[0:191];
										
										state <= key192split;
									end
								key192split:
									begin
										tempKey0 <= keyExp[keyPlace +: 32];
										tempKey1 <= keyExp[keyPlace + 32 +: 32];
										tempKey2 <= keyExp[keyPlace + 64 +: 32];
										tempKey3 <= keyExp[keyPlace + 96 +: 32];
										tempKey4 <= keyExp[keyPlace + 128 +: 32];
										tempKey5 <= keyExp[keyPlace + 160 +: 32];				

										state <= key192rotate;
									end
								key192rotate:
									begin
										// 192-bit rotate
										tempKeyRotate[0:7] <= tempKey5[8:15];
										tempKeyRotate[8:15] <= tempKey5[16:23];
										tempKeyRotate[16:23] <= tempKey5[24:31];
										tempKeyRotate[24:31] <= tempKey5[0:7];
										
										state <= key192sub;
									end
								key192sub:
									begin
										// 192-bit SubByte
										tempKeySubByte[0:7] <= cypher[tempKeyRotate[4:7] * 8 + tempKeyRotate[0:3] * 128 +: 8];
										tempKeySubByte[8:15] <= cypher[tempKeyRotate[12:15] * 8 + tempKeyRotate[8:11] * 128 +: 8];
										tempKeySubByte[16:23] <= cypher[tempKeyRotate[20:23] * 8 + tempKeyRotate[16:19] * 128 +: 8];
										tempKeySubByte[24:31] <= cypher[tempKeyRotate[28:31] * 8 + tempKeyRotate[24:27] * 128 +: 8];
										
										state <= key192rcon;
									end
								key192rcon:	
									begin
										// 192-bit rcon
										tempKeyRcon[0:7] <= tempKeySubByte[0:7] ^ rcon;
										tempKeyRcon[8:15] <= tempKeySubByte[8:15];
										tempKeyRcon[16:23] <= tempKeySubByte[16:23];
										tempKeyRcon[24:31] <= tempKeySubByte[24:31];
										
										state <= key192temp0;
									end
								key192temp0:	
									begin
										tempKey0 <= tempKeyRcon ^ tempKey0;
										
										state <= key192temp1;
									end
								key192temp1:	
									begin
										tempKey1 <= tempKey0 ^ tempKey1;
							
										state <= key192temp2;
									end
								key192temp2:		
									begin
										tempKey2 <= tempKey1 ^ tempKey2;
										
										state <= key192temp3;
									end
								key192temp3:
									begin
										tempKey3 <= tempKey2 ^ tempKey3;
										
										state <= key192temp4;
									end
								key192temp4:
									begin
										tempKey4 <= tempKey3 ^ tempKey4;
										
										state <= key192temp5;
									end
								key192temp5:		
									begin
										tempKey5 <= tempKey4 ^ tempKey5;
										
										state <= key192set;
									end
								key192set:	
									begin
										// 192-bit set keyExp
										keyExp[keyPlace + 192 +:32] <= tempKey0;
										keyExp[keyPlace + 224 +:32] <= tempKey1;
										keyExp[keyPlace + 256 +:32] <= tempKey2;
										keyExp[keyPlace + 288 +:32] <= tempKey3;
										keyExp[keyPlace + 320 +:32] <= tempKey4;
										keyExp[keyPlace + 352 +:32] <= tempKey5;
										
										if(count == 7)
											begin
												state <= doneState;
											end
										else
											begin
												rcon <= (rcon << 1);
												state <= key192split;
												count <= count + 1;
												keyPlace <= keyPlace + 192;
											end
									end
								////////////////////////////////////////
								// 256-bit
								key256begin:
									begin
										keyExp[0:255] <= key[0:255];
										
										state <= key256split;
									end
								key256split:
									begin
										tempKey0 <= keyExp[keyPlace +: 32];
										tempKey1 <= keyExp[keyPlace + 32 +: 32];
										tempKey2 <= keyExp[keyPlace + 64 +: 32];
										tempKey3 <= keyExp[keyPlace + 96 +: 32];
										tempKey4 <= keyExp[keyPlace + 128 +: 32];
										tempKey5 <= keyExp[keyPlace + 160 +: 32];
										tempKey6 <= keyExp[keyPlace + 192 +: 32];
										tempKey7 <= keyExp[keyPlace + 224 +: 32];				

										state <= key256rotate;
									end
								key256rotate:
									begin
										// 256-bit rotate
										tempKeyRotate[0:7] <= tempKey7[8:15];
										tempKeyRotate[8:15] <= tempKey7[16:23];
										tempKeyRotate[16:23] <= tempKey7[24:31];
										tempKeyRotate[24:31] <= tempKey7[0:7];
										
										state <= key256sub;
									end
								key256sub:
									begin
										// 256-bit SubByte
										tempKeySubByte[0:7] <= cypher[tempKeyRotate[4:7] * 8 + tempKeyRotate[0:3] * 128 +: 8];
										tempKeySubByte[8:15] <= cypher[tempKeyRotate[12:15] * 8 + tempKeyRotate[8:11] * 128 +: 8];
										tempKeySubByte[16:23] <= cypher[tempKeyRotate[20:23] * 8 + tempKeyRotate[16:19] * 128 +: 8];
										tempKeySubByte[24:31] <= cypher[tempKeyRotate[28:31] * 8 + tempKeyRotate[24:27] * 128 +: 8];
										
										state <= key256rcon;
									end
								key256rcon:		
									begin
										// 256-bit rcon
										tempKeyRcon[0:7] <= tempKeySubByte[0:7] ^ rcon;
										tempKeyRcon[8:15] <= tempKeySubByte[8:15];
										tempKeyRcon[16:23] <= tempKeySubByte[16:23];
										tempKeyRcon[24:31] <= tempKeySubByte[24:31];
										
										state <= key256temp0;
									end
								key256temp0:		
									begin
										tempKey0 <= tempKeyRcon ^ tempKey0;
										
										state <= key256temp1;
									end
								key256temp1:		
									begin
										tempKey1 <= tempKey0 ^ tempKey1;
										
										state <= key256temp2;
									end
								key256temp2:		
									begin
										tempKey2 <= tempKey1 ^ tempKey2;
										
										state <= key256temp3;
									end
								key256temp3:	
									begin
										tempKey3 <= tempKey2 ^ tempKey3;
										
										state <= key256extra;
									end
								key256extra:		
									begin
										// 256-bit extra SubByte
										tempKeySubByte256[0:7] <= cypher[tempKey3[4:7] * 8 + tempKey3[0:3] * 128 +: 8];
										tempKeySubByte256[8:15] <= cypher[tempKey3[12:15] * 8 + tempKey3[8:11] * 128 +: 8];
										tempKeySubByte256[16:23] <= cypher[tempKey3[20:23] * 8 + tempKey3[16:19] * 128 +: 8];
										tempKeySubByte256[24:31] <= cypher[tempKey3[28:31] * 8 + tempKey3[24:27] * 128 +: 8];
										
										state <= key256temp4;
									end
								key256temp4:	
									begin
										tempKey4 <= tempKeySubByte256 ^ tempKey4;
										
										state <= key256temp5;
									end
								key256temp5:		
									begin
										tempKey5 <= tempKey4 ^ tempKey5;
										
										state <= key256temp6;
									end
								key256temp6:		
									begin
										tempKey6 <= tempKey5 ^ tempKey6;
										
										state <= key256temp7;
									end
								key256temp7:		
									begin
										tempKey7 <= tempKey6 ^ tempKey7;
										
										state <= key256set;
									end
								key256set:	
									begin
										// 256-bit set keyExp
										keyExp[keyPlace + 256 +:32] <= tempKey0;
										keyExp[keyPlace + 288 +:32] <= tempKey1;
										keyExp[keyPlace + 320 +:32] <= tempKey2;
										keyExp[keyPlace + 352 +:32] <= tempKey3;
										keyExp[keyPlace + 384 +:32] <= tempKey4;
										keyExp[keyPlace + 416 +:32] <= tempKey5;
										keyExp[keyPlace + 448 +:32] <= tempKey6;
										keyExp[keyPlace + 480 +:32] <= tempKey7;
										
										if(count == 6)
											begin
												state <= doneState;
											end
										else
											begin
												rcon <= (rcon << 1);
												state <= key256split;
												count <= count + 1;
												keyPlace <= keyPlace + 256;
											end
									end
								/////////////////////////////////////
								// 128-bit
								key128begin:
									begin
										keyExp[0:127] <= key[0:127];
										
										state <= key128split;
									end
								key128split:
									begin
										tempKey0 <= keyExp[keyPlace +: 32];
										tempKey1 <= keyExp[keyPlace + 32 +: 32];
										tempKey2 <= keyExp[keyPlace + 64 +: 32];
										tempKey3 <= keyExp[keyPlace + 96 +: 32];
									
										state <= key128rotate;
									end
								key128rotate:
									begin
										// 128-bit rotate
										tempKeyRotate[0:7] <= tempKey3[8:15];
										tempKeyRotate[8:15] <= tempKey3[16:23];
										tempKeyRotate[16:23] <= tempKey3[24:31];
										tempKeyRotate[24:31] <= tempKey3[0:7];
										
										state <= key128sub;
									end
								key128sub:	
									begin
										// 128-bit SubByte
										tempKeySubByte[0:7] <= cypher[tempKeyRotate[4:7] * 8 + tempKeyRotate[0:3] * 128 +: 8];
										tempKeySubByte[8:15] <= cypher[tempKeyRotate[12:15] * 8 + tempKeyRotate[8:11] * 128 +: 8];
										tempKeySubByte[16:23] <= cypher[tempKeyRotate[20:23] * 8 + tempKeyRotate[16:19] * 128 +: 8];
										tempKeySubByte[24:31] <= cypher[tempKeyRotate[28:31] * 8 + tempKeyRotate[24:27] * 128 +: 8];
										
										state <= key128rcon;
									end
								key128rcon:		
									begin
										// 128-bit rcon
										tempKeyRcon[0:7] <= tempKeySubByte[0:7] ^ rcon;
										tempKeyRcon[8:15] <= tempKeySubByte[8:15];
										tempKeyRcon[16:23] <= tempKeySubByte[16:23];
										tempKeyRcon[24:31] <= tempKeySubByte[24:31];
										
										state <= key128temp0;
									end
								key128temp0:		
									begin
										tempKey0 <= tempKeyRcon ^ tempKey0;
										
										state <= key128temp1;
									end
								key128temp1:		
									begin
										tempKey1 <= tempKey0 ^ tempKey1;
										
										state <= key128temp2;
									end
								key128temp2:		
									begin
										tempKey2 <= tempKey1 ^ tempKey2;
										
										state <= key128temp3;
									end
								key128temp3:		
									begin
										tempKey3 <= tempKey2 ^ tempKey3;
										
										state <= key128set;
									end
								key128set:	
									begin
										// 128-bit setKeyExpansion
										keyExp[keyPlace + 128 +:32] <= tempKey0;
										keyExp[keyPlace + 160 +:32] <= tempKey1;
										keyExp[keyPlace + 192 +:32] <= tempKey2;
										keyExp[keyPlace + 224 +:32] <= tempKey3;
										
										if(count == 9)
											begin
												state <= doneState;
											end
										else
											begin
												if(rcon == 8'h80)
													begin
														rcon <= 8'h1b;
													end
												else
													begin
														rcon <= (rcon << 1);
													end
												state <= key128split;
												count <= count + 1;
												keyPlace <= keyPlace + 128;
											end
									end
								doneState:
									begin
										keyExpDone <= 1;
									end
								default:
									begin
										state <= defaultState;
									end
							endcase
						end
				end
		end
	
endmodule