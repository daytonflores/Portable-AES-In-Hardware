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
	
	reg [0:127] subBytesIn;
	reg [0:127] shiftRowsIn;
	reg [0:127] mixColumnsIn;
	reg [0:127] addRoundKeyIn;
	reg [0:127] invSubBytesIn;
	reg [0:127] invShiftRowsIn;
	reg [0:127] invMixColumnsIn;
	reg [0:127] invAddRoundKeyIn;
	
	wire [0:127] subBytesOut;
	wire [0:127] shiftRowsOut;
	wire [0:127] mixColumnsOut;
	wire [0:127] addRoundKeyOut;
	wire [0:127] invSubBytesOut;
	wire [0:127] invShiftRowsOut;
	wire [0:127] invMixColumnsOut;
	wire [0:127] invAddRoundKeyOut;
	
	reg enableKeyExpansion;
	reg enableInvKeyControl;
	reg enableKeyControl;

	wire [0:127] newKey;
	wire [0:127] invNewKey;
	wire [0:1919] keyExp;
	
	//state = encOrDec, keyexpansion, initialround, finalround, subbytes, shiftrows, mixcolumns, keycontrol, addroundkey
	
	always@ (posedge clk)
		if(rst)
			begin
				state <= 9'b000000000;
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
								addRoundKeyIn <= messageIn;
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
								subBytesIn <= addRoundKeyOut;
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
								shiftRowsIn <= subBytesOut;
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
								addRoundKeyIn <= shiftRowsOut;
								messageOut <= addRoundKeyOut;
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
								subBytesIn <= addRoundKeyOut;
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
								shiftRowsIn <= subBytesOut;
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
								mixColumnsIn <= shiftRowsOut;
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
										enableKeyControl <= 1'b0;
										addRoundKeyIn <= mixColumnsOut;
									end
								else if(keySize == 3'b010 && count == 11)
									begin
										nextstate <= 9'b010110000;
										enableKeyControl <= 1'b0;
										addRoundKeyIn <= mixColumnsOut;
									end
								else if(keySize != 3'b100 && keySize != 3'b010 && count == 9)
									begin
										nextstate <= 9'b010110000;
										enableKeyControl <= 1'b0;
										addRoundKeyIn <= mixColumnsOut;
									end
								else
									begin
										nextstate <= 9'b010010000;
										enableKeyControl <= 1'b0;
										addRoundKeyIn <= mixColumnsOut;				
									end
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
								invAddRoundKeyIn <= messageOut;
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
								invShiftRowsIn <= invMixColumnsOut;
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
								invSubBytesIn <= invShiftRowsOut;
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
								invAddRoundKeyIn <= invSubBytesOut;
								messageOut <= invAddRoundKeyOut;
								HEX0 <= 7'b0001010;				// K
								HEX1 <= 7'b0101111;				// R
								HEX2 <= 7'b0001000;				// A
								HEX3 <= 7'b1101110;				// I
								HEX4 <= 7'b0001110;				// F
								HEX5 <= 7'b1111111;
								HEX6 <= 7'b0000110;				// E
								HEX7 <= 7'b0100001;				// D
							end
						//invShiftRowshiftRows
						9'b000001000:
						// 0x08
							begin
								nextstate <= 9'b000010000;
								if(count == 0)
									begin
										invShiftRowsIn <= invAddRoundKeyOut;
									end
								else
									begin
										invShiftRowsIn <= invMixColumnsOut;
									end
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
								invSubBytesIn <= invShiftRowsOut;
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
								invAddRoundKeyIn <= invSubBytesOut;
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
										invMixColumnsIn <= invAddRoundKeyOut;
									end
								else if(keySize == 3'b010 && count == 11)
									begin
										nextstate <= 9'b000101000;
										invMixColumnsIn <= invAddRoundKeyOut;		
									end
								else if(keySize != 3'b100 && keySize != 3'b010 && count == 9)
									begin
										nextstate <= 9'b000101000;
										invMixColumnsIn <= invAddRoundKeyOut;
									end
								else
									begin
										nextstate <= 9'b000001000;
										invMixColumnsIn <= invAddRoundKeyOut;
									end
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

subBytes subBytes(	subBytesIn,						// unsigned 16-byte message to be encrypted in subBytes
					subBytesOut);					// unsigned 16-byte encrypted message after subBytes
					
shiftRows shiftRows(	shiftRowsIn,				// unsigned 16-byte message to be encrypted in shiftRows
						shiftRowsOut);				// unsigned 16-byte encrypted message after shiftRows
					
mixColumns mixColumns(	mixColumnsIn,				// unsigned 16-byte message to be encrypted in mixColumns
						mixColumnsOut);				// unsigned 16-byte encrypted message after mixColumns
						
addRoundKey addRoundKey(	addRoundKeyIn, 			// unsigned 16-byte message to be encrypted
							newKey, 				// unsigned 16 bytes of 176-byte expanded key
							addRoundKeyOut);			// unsigned 16-byte encrypted message
						
invSubBytes invSubBytes(	invSubBytesIn,			// unsigned 16-byte message to be encrypted in invSubBytes
							invSubBytesOut);		// unsigned 16-byte encrypted message after invSubBytes

invShiftRows invShiftRows(	invShiftRowsIn,			// unsigned 16-byte message to be encrypted in invShiftRows
							invShiftRowsOut);		// unsigned 16-byte encrypted message after invShiftRows
					
invMixColumns invMixColumns(	invMixColumnsIn,	// unsigned 16-byte message to be encrypted in invMixColumns
								invMixColumnsOut); 	// unsigned 16-byte encrypted message after invMixColumns
						
invAddRoundKey invAddRoundKey(	invAddRoundKeyIn, 	// unsigned 16-byte message to be encrypted
								invNewKey, 			// unsigned 16 bytes of 176-byte expanded key
								invAddRoundKeyOut);	// unsigned 16-byte encrypted message
								
keyExpansion keyExpansion(	clk,
							rst, 					// input reset
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