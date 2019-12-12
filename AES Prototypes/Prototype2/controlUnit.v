module controlUnit (	input clk,
						input rst,
						input start,
						input encOrDec,
						input [0:2] keySize,
						input [0:127] messageIn,
						output reg doneE,
						output reg doneD,
						output reg [0:127] messageOut
					);

	integer count;
	reg [0:8] state;
	reg [0:8] nextstate;
	
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
	wire [0:255] key;	
	wire [0:255] testKey = {8'h00, 8'h01, 8'h02, 8'h03,		// unsigned 16-byte test key
							8'h04, 8'h05, 8'h06, 8'h07,		// unsigned 16-byte test key
							8'h08, 8'h09, 8'h0a, 8'h0b,		// unsigned 16-byte test key
							8'h0c, 8'h0d, 8'h0e, 8'h0f,		// unsigned 16-byte test key
							8'h10, 8'h11, 8'h12, 8'h13,		// unsigned 16-byte test key
							8'h14, 8'h15, 8'h16, 8'h17,		// unsigned 16-byte test key
							8'h18, 8'h19, 8'h1a, 8'h1b,		// unsigned 16-byte test key
							8'h1c, 8'h1d, 8'h1e, 8'h1f};	// unsigned 16-byte test key
							
	assign key = testKey;
	
	//state = encOrDec, keyexpansion, initialround, finalround, subbytes, shiftrows, mixcolumns, keycontrol, addroundkey
	
	always@ (posedge clk)
		if(rst)
			begin
				state <= 9'b000000000;
				enableKeyExpansion <= 1'b0;
				enableKeyControl <= 1'b0;
				enableInvKeyControl <= 1'b0;
				count <= 0;
				doneE <= 1'b0;
				doneD <= 1'b0;
			end
		else
			begin
				state <= nextstate;
				
				if(nextstate == 9'b010000001 || nextstate == 9'b000000100)
					begin
						count <= count + 1;
					end
			end
			
	always@ (encOrDec)
		if(encOrDec)
			begin
				state <= 9'b110000000;
			end
		else
			begin
				state <= 9'b010000000;
			end
	
	always@ (*)
		begin
			casex(state)
				//encrypt
				//keyExpansion
				9'b110000000:
					begin
						nextstate <= 9'b011000010;
						enableKeyExpansion <= 1'b1;
					end
				//initialRound keyControl
				9'b011000010:
					begin
						nextstate <= 9'b011000000;
						enableKeyExpansion <= 1'b0;
						enableKeyControl <= 1'b1;
					end
				//initialRound addRoundKey
				9'b011000000: 
					begin
						nextstate <= 9'b010010000;
						enableKeyControl <= 1'b0;
						addRoundKeyIn <= messageIn;
					end
				//finalRound subBytes
				9'b010110000:
					begin
						nextstate <= 9'b010101000;
						subBytesIn <= addRoundKeyOut;
					end
				//finalRound shiftRows
				9'b010101000: 
					begin
						nextstate <= 9'b010100010;
						shiftRowsIn <= subBytesOut;
					end
				//finalRound keyControl
				9'b010100010:
					begin
						nextstate <= 9'b010100001;
						enableKeyControl <= 1'b1;
					end
				//finalRound addRoundKey
				9'b010100001: 
					begin
						nextstate <= 9'b000000000;
						enableKeyControl <= 1'b0;
						addRoundKeyIn <= shiftRowsOut;
						messageOut <= addRoundKeyOut;
						doneE <= 1'b1;
					end
				//subBytes
				9'b010010000:
					begin
						nextstate <= 9'b010001000;
						subBytesIn <= addRoundKeyOut;
					end
				//shiftRows
				9'b010001000:
					begin
						nextstate <= 9'b010000100;
						shiftRowsIn <= subBytesOut;
					end
				//mixColumns
				9'b010000100:
					begin
						nextstate <= 9'b010000010;
						mixColumnsIn <= shiftRowsOut;
					end
				//keyControl
				9'b010000010:
					begin
						nextstate <= 9'b010000001;
						enableKeyControl <= 1'b1;
					end
				//addRoundKey
				9'b010000001: 
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
					end
					
				//decrypt	
				//keyExpansion
				9'b010000000:
					begin
						nextstate <= 9'b001000010;
						enableKeyExpansion <= 1'b1;
					end
				//initialRound invKeyControl
				9'b001000010:
					begin
						nextstate <= 9'b001000001;
						enableKeyExpansion <= 1'b0;
						enableInvKeyControl <= 1'b1;
					end
				//initialRound invAddRoundKey
				9'b001000001:
					begin
						nextstate <= 9'b000001000;
						invAddRoundKeyIn <= messageOut;
						enableInvKeyControl <= 1'b0;
					end
				//finalRound invShiftRows
				9'b000101000:
					begin
						nextstate <= 9'b000110000;
						invShiftRowsIn <= invMixColumnsOut;
					end
				//finalRound invSubBytes	
				9'b000110000: 
					begin
						nextstate <= 9'b000100010;
						invSubBytesIn <= invShiftRowsOut;
					end
				//finalRound invKeyControl
				9'b000100010:
					begin
						nextstate <= 9'b000100001;
						enableInvKeyControl <= 1'b1;
					end
				//finalRound invAddRoundKey
				9'b000100001: 
					begin
						nextstate <= 9'b000000000;
						enableKeyControl <= 1'b0;
						invAddRoundKeyIn <= invSubBytesOut;
						messageOut <= invAddRoundKeyOut;
						doneD <= 1'b1;
					end
				//invShiftRowshiftRows
				9'b000001000:
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
					end
				//invSubBytes
				9'b000010000:
					begin
						nextstate <= 9'b000000010;
						invSubBytesIn <= invShiftRowsOut;
					end
				//invKeyControl
				9'b000000010:
					begin
						nextstate <= 9'b000000001;
						enableInvKeyControl <= 1'b1;
					end
				//invAddRoundKey
				9'b000000001: 
					begin
						nextstate <= 9'b000000100;
						invAddRoundKeyIn <= invSubBytesOut;
						enableInvKeyControl <= 1'b0;
					end
				//invMixColumns
				9'b000000100:
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
					end
				default:
					begin
						nextstate <= 9'b000000000;
					end
			endcase
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
								
keyExpansion keyExpansion(	rst, 					// input reset
							enableKeyExpansion, 	// begin keyExpansion
							keySize,				// either 10, 12, or 14 rounds
							key,					// unsigned 16-byte key
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