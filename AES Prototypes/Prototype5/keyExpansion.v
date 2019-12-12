module keyExpansion(	input clk,
						input rst, 							// input reset
						input [2:0] keySize,				// either 10, 12, or 14 rounds
						output reg expDone,
						output reg [0:1919] keyExp); 		// unsigned 176-byte expanded key		
						
	reg [0:6] state;
	reg check = 1'b0;
	reg [0:6] nextstate;
	
	reg [0:7] rcon;
	reg [0:7] rconTemp;
	reg [0:255] tempKey;
	reg [0:31] tempKeyRotate;
	reg [0:31] tempKeySubbyte;
	reg [0:31] tempKeySubbyte256;
	reg [0:31] temp256;
	reg [0:31] tempKeyRcon;
	
	reg keyDone;
	reg [0:31] tempKey0;
	reg [0:31] tempKey1;
	reg [0:31] tempKey2;
	reg [0:31] tempKey3;
	reg [0:31] tempKey4;
	reg [0:31] tempKey5;
	reg [0:31] tempKey6;
	reg [0:31] tempKey7;
	reg [0:31] nextTempKey0;
	reg [0:31] nextTempKey1;
	reg [0:31] nextTempKey2;
	reg [0:31] nextTempKey3;
	reg [0:31] nextTempKey4;
	reg [0:31] nextTempKey5;
	reg [0:31] nextTempKey6;
	reg [0:31] nextTempKey7;
	
	integer count = 0;
	integer keyPlace;
	
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
	
	always@ (posedge clk)
		begin
			if(rst)
				begin
					state <= 7'b000_0000;
					check <= 1'b1;
					count <= 0;
					keyPlace <= 0;
				end
			else
				begin
					if(check)
						begin
							if(keySize == 3'b010)
								begin
									state <= 7'b010_0000;
								end
							else if(keySize == 3'b100)
								begin
									state <= 7'b100_0000;
								end
							else
								begin
									state <= 7'b001_0000;
								end
							check <= 1'b0;
						end
					else
						begin
							state <= nextstate;
							
							if(state == 7'b001_1001 && !keyDone)
								begin
									count <= count + 1;
									keyPlace <= keyPlace + 128;
								end
							else if(state == 7'b010_1011 && !keyDone)
								begin
									count <= count + 1;
									keyPlace <= keyPlace + 192;
								end
							else if(state == 7'b100_1110 && !keyDone)
								begin
									count <= count + 1;
									keyPlace <= keyPlace + 256;
								end
							else if(state == 7'b111_1111)
								begin
									keyPlace <= 0;
									count <= 0;
								end
						end
				end
		end
	
	always @(*)
		begin
			if(rst)
				begin
					rcon <= 8'h01;
					keyExp <= 1920'h0;
					tempKey <= 256'h0;
					tempKeyRcon <= 32'h0;
					tempKeyRotate <= 32'h0;
					tempKeySubbyte <= 32'h0;
					nextstate <= 7'b000_0000;
					expDone <= 1'b0;
					keyDone <= 0;
				end			
			else
				begin 
					case (state)
						////////////////////////////////////////
						// 192-bit
						7'b010_0000:
							begin
								keyExp[0:191] <= key[0:191];
								
								nextstate <= 7'b010_0001;
							end
						7'b010_0001:
							begin
								// 192-bit sub-key split into six 32-bit tempKeys
								tempKey0 <= keyExp[keyPlace +:32];
								tempKey1 <= keyExp[keyPlace +:64];
								tempKey2 <= keyExp[keyPlace +:96];
								tempKey3 <= keyExp[keyPlace +:128];
								tempKey4 <= keyExp[keyPlace +:160];
								tempKey5 <= keyExp[keyPlace +:192];
								
								nextstate <= 7'b010_0010;
							end
						7'b010_0010:
							begin
								// 192-bit rotate
								tempKeyRotate[0:7] <= tempKey5[8:15];
								tempKeyRotate[8:15] <= tempKey5[16:23];
								tempKeyRotate[16:23] <= tempKey5[24:31];
								tempKeyRotate[24:31] <= tempKey5[0:7];
								
								nextstate <= 7'b010_0011;
							end
						7'b010_0011:
							begin
								// 192-bit subbyte
								tempKeySubbyte[0:7] <= cypher[tempKeyRotate[4:7] * 8 + tempKeyRotate[0:3] * 128 +: 8];
								tempKeySubbyte[8:15] <= cypher[tempKeyRotate[12:15] * 8 + tempKeyRotate[8:11] * 128 +: 8];
								tempKeySubbyte[16:23] <= cypher[tempKeyRotate[20:23] * 8 + tempKeyRotate[16:19] * 128 +: 8];
								tempKeySubbyte[24:31] <= cypher[tempKeyRotate[28:31] * 8 + tempKeyRotate[24:27] * 128 +: 8];
								
								nextstate <= 7'b010_0100;
							end
						7'b010_0100:	
							begin
								// 192-bit rcon
								tempKeyRcon[0:7] <= tempKeySubbyte[0:7] ^ rcon;
								tempKeyRcon[8:15] <= tempKeySubbyte[8:15];
								tempKeyRcon[16:23] <= tempKeySubbyte[16:23];
								tempKeyRcon[24:31] <= tempKeySubbyte[24:31];
								
								rconTemp <= rcon;
								
								nextstate <= 7'b010_0101;
							end
						7'b010_0101:	
							begin
								nextTempKey0 <= tempKeyRcon ^ tempKey0;
								
								nextstate <= 7'b010_0110;
							end
						7'b010_0110:	
							begin
								nextTempKey1 <= nextTempKey0 ^ tempKey1;
					
								nextstate <= 7'b010_0111;
							end
						7'b010_0111:		
							begin
								nextTempKey2 <= nextTempKey1 ^ tempKey2;
								
								nextstate <= 7'b010_1000;
							end
						7'b010_1000:
							begin
								nextTempKey3 <= nextTempKey2 ^ tempKey3;
								
								nextstate <= 7'b010_1001;
							end
						7'b010_1001:
							begin
								nextTempKey4 <= nextTempKey3 ^ tempKey4;
								
								nextstate <= 7'b010_1010;
							end
						7'b010_1010:		
							begin
								nextTempKey5 <= nextTempKey4 ^ tempKey5;
								
								nextstate <= 7'b010_1011;
							end
						7'b010_1011:	
							begin
								// 192-bit set keyExp
								keyExp[keyPlace + 192 +:32] <= nextTempKey0;
								keyExp[keyPlace + 224 +:32] <= nextTempKey1;
								keyExp[keyPlace + 256 +:32] <= nextTempKey2;
								keyExp[keyPlace + 288 +:32] <= nextTempKey3;
								keyExp[keyPlace + 320 +:32] <= nextTempKey4;
								keyExp[keyPlace + 352 +:32] <= nextTempKey5;
								
								if(count == 7)
									begin
										nextstate <= 7'b111_1111;
										keyDone <= 1'b1;
									end
								else
									begin
										rcon <= (rconTemp << 1);
										nextstate <= 7'b010_0001;
									end
							end
						////////////////////////////////////////
						// 256-bit
						7'b100_0000:
							begin
								keyExp[0:255] <= key[0:255];
								
								nextstate <= 7'b100_0001;
							end
						7'b100_0001:
							begin
								// 256-bit sub-key split into eight 32-bit tempKeys
								tempKey0 <= keyExp[keyPlace +:32];
								tempKey1 <= keyExp[keyPlace +:64];
								tempKey2 <= keyExp[keyPlace +:96];
								tempKey3 <= keyExp[keyPlace +:128];
								tempKey4 <= keyExp[keyPlace +:160];
								tempKey5 <= keyExp[keyPlace +:192];
								tempKey6 <= keyExp[keyPlace +:224];
								tempKey7 <= keyExp[keyPlace +:256];
							
								nextstate <= 7'b100_0010;
							end
						7'b100_0010:
							begin
								// 256-bit rotate
								tempKeyRotate[0:7] <= tempKey7[8:15];
								tempKeyRotate[8:15] <= tempKey7[16:23];
								tempKeyRotate[16:23] <= tempKey7[24:31];
								tempKeyRotate[24:31] <= tempKey7[0:7];
								
								nextstate <= 7'b100_0011;
							end
						7'b100_0011:
							begin
								// 256-bit subbyte
								tempKeySubbyte[0:7] <= cypher[tempKeyRotate[4:7] * 8 + tempKeyRotate[0:3] * 128 +: 8];
								tempKeySubbyte[8:15] <= cypher[tempKeyRotate[12:15] * 8 + tempKeyRotate[8:11] * 128 +: 8];
								tempKeySubbyte[16:23] <= cypher[tempKeyRotate[20:23] * 8 + tempKeyRotate[16:19] * 128 +: 8];
								tempKeySubbyte[24:31] <= cypher[tempKeyRotate[28:31] * 8 + tempKeyRotate[24:27] * 128 +: 8];
								
								nextstate <= 7'b100_0100;
							end
						7'b100_0100:		
							begin
								// 256-bit rcon
								tempKeyRcon[0:7] <= tempKeySubbyte[0:7] ^ rcon;
								tempKeyRcon[8:15] <= tempKeySubbyte[8:15];
								tempKeyRcon[16:23] <= tempKeySubbyte[16:23];
								tempKeyRcon[24:31] <= tempKeySubbyte[24:31];
								
								rconTemp <= rcon;
								
								nextstate <= 7'b100_0101;
							end
						7'b100_0101:		
							begin
								nextTempKey0 <= tempKeyRcon ^ tempKey0;
								
								nextstate <= 7'b100_0110;
							end
						7'b100_0110:		
							begin
								nextTempKey1 <= nextTempKey0 ^ tempKey1;
								
								nextstate <= 7'b100_0111;
							end
						7'b100_0111:		
							begin
								nextTempKey2 <= nextTempKey1 ^ tempKey2;
								
								nextstate <= 7'b100_1000;
							end
						7'b100_1000:	
							begin
								nextTempKey3 <= nextTempKey2 ^ tempKey3;
								
								nextstate <= 7'b100_1001;
							end
						7'b100_1001:		
							begin
								// 256-bit extra subbyte
								tempKeySubbyte256[0:7] <= cypher[nextTempKey3[4:7] * 8 + nextTempKey3[0:3] * 128 +: 8];
								tempKeySubbyte256[8:15] <= cypher[nextTempKey3[12:15] * 8 + nextTempKey3[8:11] * 128 +: 8];
								tempKeySubbyte256[16:23] <= cypher[nextTempKey3[20:23] * 8 + nextTempKey3[16:19] * 128 +: 8];
								tempKeySubbyte256[24:31] <= cypher[nextTempKey3[28:31] * 8 + nextTempKey3[24:27] * 128 +: 8];
								
								nextstate <= 7'b100_1010;
							end
						7'b100_1010:	
							begin
								nextTempKey4 <= tempKeySubbyte256 ^ tempKey4;
								
								nextstate <= 7'b100_1011;
							end
						7'b100_1011:		
							begin
								nextTempKey5 <= nextTempKey4 ^ tempKey5;
								
								nextstate <= 7'b100_1100;
							end
						7'b100_1100:		
							begin
								nextTempKey6 <= nextTempKey5 ^ tempKey6;
								
								nextstate <= 7'b100_1101;
							end
						7'b100_1101:		
							begin
								nextTempKey7 <= nextTempKey6 ^ tempKey7;
								
								nextstate <= 7'b100_1110;
							end
						7'b100_1110:	
							begin
								// 256-bit set keyExp
								keyExp[keyPlace + 256 +:32] <= nextTempKey0;
								keyExp[keyPlace + 288 +:32] <= nextTempKey1;
								keyExp[keyPlace + 320 +:32] <= nextTempKey2;
								keyExp[keyPlace + 352 +:32] <= nextTempKey3;
								keyExp[keyPlace + 384 +:32] <= nextTempKey4;
								keyExp[keyPlace + 416 +:32] <= nextTempKey5;
								keyExp[keyPlace + 448 +:32] <= nextTempKey6;
								keyExp[keyPlace + 480 +:32] <= nextTempKey7;
								
								if(count == 6)
									begin
										nextstate <= 7'b111_1111;
										keyDone <= 1'b1;
									end
								else
									begin
										rcon <= (rconTemp << 1);
										nextstate <= 7'b100_0001;
									end
							end
						/////////////////////////////////////
						// 128-bit
						7'b001_0000:
							begin
								keyExp[0:127] <= key[0:127];
								
								nextstate <= 7'b001_0001;
							end
						7'b001_0001:
							begin
								tempKey0 <= keyExp[keyPlace +:32];
								tempKey1 <= keyExp[keyPlace +:64];
								tempKey2 <= keyExp[keyPlace +:96];
								tempKey3 <= keyExp[keyPlace +:128];
							
								nextstate <= 7'b001_0010;
							end
						7'b001_0010:
							begin
								// 128-bit rotate
								tempKeyRotate[0:7] <= tempKey3[8:15];
								tempKeyRotate[8:15] <= tempKey3[16:23];
								tempKeyRotate[16:23] <= tempKey3[24:31];
								tempKeyRotate[24:31] <= tempKey3[0:7];
								
								nextstate <= 7'b001_0011;
							end
						7'b001_0011:	
							begin
								// 128-bit subbyte
								tempKeySubbyte[0:7] <= cypher[tempKeyRotate[4:7] * 8 + tempKeyRotate[0:3] * 128 +: 8];
								tempKeySubbyte[8:15] <= cypher[tempKeyRotate[12:15] * 8 + tempKeyRotate[8:11] * 128 +: 8];
								tempKeySubbyte[16:23] <= cypher[tempKeyRotate[20:23] * 8 + tempKeyRotate[16:19] * 128 +: 8];
								tempKeySubbyte[24:31] <= cypher[tempKeyRotate[28:31] * 8 + tempKeyRotate[24:27] * 128 +: 8];
								
								nextstate <= 7'b001_0100;
							end
						7'b001_0100:		
							begin
								// 128-bit rcon
								tempKeyRcon[0:7] <= tempKeySubbyte[0:7] ^ rcon;
								tempKeyRcon[8:15] <= tempKeySubbyte[8:15];
								tempKeyRcon[16:23] <= tempKeySubbyte[16:23];
								tempKeyRcon[24:31] <= tempKeySubbyte[24:31];
								
								rconTemp <= rcon;
								
								nextstate <= 7'b001_0101;
							end
						7'b001_0101:		
							begin
								nextTempKey0 <= tempKeyRcon ^ tempKey0;
								
								nextstate <= 7'b001_0110;
							end
						7'b001_0110:		
							begin
								nextTempKey1 <= nextTempKey0 ^ tempKey1;
								
								nextstate <= 7'b001_0111;
							end
						7'b001_0111:		
							begin
								nextTempKey2 <= nextTempKey1 ^ tempKey2;
								
								nextstate <= 7'b001_1000;
							end
						7'b001_1000:		
							begin
								nextTempKey3 <= nextTempKey2 ^ tempKey3;
								
								nextstate <= 7'b001_1001;
							end
						7'b001_1001:	
							begin
								// 128-bit setKeyExpansion
								keyExp[keyPlace + 128 +:32] <= nextTempKey0;
								keyExp[keyPlace + 160 +:32] <= nextTempKey1;
								keyExp[keyPlace + 192 +:32] <= nextTempKey2;
								keyExp[keyPlace + 224 +:32] <= nextTempKey3;
								
								if(count == 9)
									begin
										nextstate <= 7'b111_1111;
										keyDone <= 1'b1;
									end
								else
									begin
										if(rconTemp == 8'h80)
											begin
												rcon <= 8'h1b;
											end
										else
											begin
												rcon <= (rconTemp << 1);
											end
										nextstate <= 7'b001_0001;
									end
							end
						7'b111_1111:
							begin
								expDone <= 1'b1;
							end
						default:
							begin
							
							end
					endcase
				end
		end
		
			
			
			
			
			
		/*always @(posedge clk)	
				begin	
					if(keySize == 3'b010)
						begin
							keyExp [0:127] = 128'h000102030405060708090a0b0c0d0e0f;
							keyExp [128:255] = 128'h10111213141516175846f2f95c43f4fe;
							keyExp [256:383] = 128'h544afef55847f0fa4856e2e95c43f4fe;
							keyExp [384:511] = 128'h40f949b31cbabd4d48f043b810b7b342;
							keyExp [512:639] = 128'h58e151ab04a2a5557effb5416245080c;
							keyExp [640:767] = 128'h2ab54bb43a02f8f662e3a95d66410c08;
							keyExp [768:895] = 128'hf501857297448d7ebdf1c6ca87f33e3c;
							keyExp [896:1023] = 128'he510976183519b6934157c9ea351f1e0;
							keyExp [1024:1151] = 128'h1ea0372a995309167c439e77ff12051e;
							keyExp [1152:1279] = 128'hdd7e0e887e2fff68608fc842f9dcc154;
							keyExp [1280:1407] = 128'h859f5f237a8d5a3dc0c02952beefd63a;
							keyExp [1408:1535] = 128'hde601e7827bcdf2ca223800fd8aeda32;
							keyExp [1536:1663] = 128'ha4970a331a78dc09c418c271e3a41d5d;
						end
					else if(keySize == 3'b100)
						begin
							keyExp [0:127] = 128'h000102030405060708090a0b0c0d0e0f;
							keyExp [128:255] = 128'h101112131415161718191a1b1c1d1e1f;
							keyExp [256:383] = 128'ha573c29fa176c498a97fce93a572c09c;
							keyExp [384:511] = 128'h1651a8cd0244beda1a5da4c10640bade;
							keyExp [512:639] = 128'hae87dff00ff11b68a68ed5fb03fc1567;
							keyExp [640:767] = 128'h6de1f1486fa54f9275f8eb5373b8518d;
							keyExp [768:895] = 128'hc656827fc9a799176f294cec6cd5598b;
							keyExp [896:1023] = 128'h3de23a75524775e727bf9eb45407cf39;
							keyExp [1024:1151] = 128'h0bdc905fc27b0948ad5245a4c1871c2f;
							keyExp [1152:1279] = 128'h45f5a66017b2d387300d4d33640a820a;
							keyExp [1280:1407] = 128'h7ccff71cbeb4fe5413e6bbf0d261a7df;
							keyExp [1408:1535] = 128'hf01afafee7a82979d7a5644ab3afe640;
							keyExp [1536:1663] = 128'h2541fe719bf500258813bbd55a721c0a;
							keyExp [1664:1791] = 128'h4e5a6699a9f24fe07e572baacdf8cdea;
							keyExp [1792:1919] = 128'h24fc79ccbf0979e9371ac23c6d68de36;
						end		
					else
						begin
							keyExp [0:127] = 128'h000102030405060708090a0b0c0d0e0f;
							keyExp [128:255] = 128'hd6aa74fdd2af72fadaa678f1d6ab76fe;
							keyExp [256:383] = 128'hb692cf0b643dbdf1be9bc5006830b3fe;
							keyExp [384:511] = 128'hb6ff744ed2c2c9bf6c590cbf0469bf41;
							keyExp [512:639] = 128'h47f7f7bc95353e03f96c32bcfd058dfd;
							keyExp [640:767] = 128'h3caaa3e8a99f9deb50f3af57adf622aa;
							keyExp [768:895] = 128'h5e390f7df7a69296a7553dc10aa31f6b;
							keyExp [896:1023] = 128'h14f9701ae35fe28c440adf4d4ea9c026;
							keyExp [1024:1151] = 128'h47438735a41c65b9e016baf4aebf7ad2;
							keyExp [1152:1279] = 128'h549932d1f08557681093ed9cbe2c974e;
							keyExp [1280:1407] = 128'h13111d7fe3944a17f307a78b4d2b30c5;
						end	
				end	*/
			
	
endmodule