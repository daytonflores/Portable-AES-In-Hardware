module rounds(	input clk, 						// input clock
				input rst, 						// input reset
				input enableRounds, 			// begin rounds
				input initialRound,				// set when it is in initialRound
				input finalRound,				// set when it is in finalRound
				input done,
				input [0:127] messageIn, 		// unsigned 16-byte message to be encrypted in subBytes
				input [0:127] newKey, 			// unsigned 16 bytes of 176-byte expanded key
				output [0:127] messageOut,		// unsigned 16-byte encrypted message after addRoundKey
				output roundsDone);				// set enableFinalRound when finished
	
	reg [0:127] messageInSB;			// unsigned 16-byte message to be encrypted in subBytes
	reg [0:127] messageInSR;			// unsigned 16-byte message to be encrypted in shiftRows
	reg [0:127] messageInMC;			// unsigned 16-byte message to be encrypted in mixColumns
	reg [0:127] messageInARK;			// unsigned 16-byte message to be encrypted in addRoundKey
	wire enableSubBytes;				// enable subBytes
	wire enableShiftRows;				// enable shiftRows	
	wire enableMixColumns;				// enable mixColumns
	wire enableAddRoundKey;				// enable addRoundKey
	wire subBytesDone;					// set when subBytes is finished
	wire shiftRowsDone;					// set when shiftRows is finished
	wire mixColumnsDone;				// set when mixColumns is finished
	wire addRoundKeyDone;				// set when addRoundKey is finished
	wire [0:127] messageOutSB;			// unsigned 16-byte encrypted message after subBytes
	wire [0:127] messageOutSR;			// unsigned 16-byte encrypted message after shiftRows
	wire [0:127] messageOutMC;			// unsigned 16-byte encrypted message after mixColumns
	wire [0:127] messageOutARK;			// unsigned 16-byte encrypted message after addRoundKey
	
	assign enableSubBytes = ~initialRound & enableRounds;
	assign enableShiftRows = subBytesDone;
	assign enableMixColumns = shiftRowsDone & ~finalRound & ~done;
	assign enableAddRoundKey = mixColumnsDone & ~finalRound | initialRound | shiftRowsDone & finalRound;
	
	assign roundsDone = addRoundKeyDone;
	assign messageOut = messageOutARK;
	
	always @ (*)
		begin
			case ({initialRound, finalRound})
				2'b10 : 
					begin
						messageInSB <= 128'bz;
						messageInSR <= 128'bz;
						messageInMC <= 128'bz;
						messageInARK <= messageIn;
					end
				2'b00 :
					begin
						messageInSB <= messageIn;
						messageInSR <= messageOutSB;
						messageInMC <= messageOutSR;
						messageInARK <= messageOutMC;
					end
				2'b01 :
					begin
						messageInSB <= messageIn;
						messageInSR <= messageOutSB;
						messageInMC <= 128'bz;
						messageInARK <= messageOutSR;
					end
				default : 
					begin
						messageInSB <= 128'bz;
						messageInSR <= 128'bz;
						messageInMC <= 128'bz;
						messageInARK <= 128'bz;
					end
			endcase
		end
	
	subBytes subBytes(			clk,				// input clock
								rst,				// input reset
								enableSubBytes,		// begin subBytes
								messageInSB,		// unsigned 16-byte message to be encrypted in subBytes
								messageOutSB,		// unsigned 16-byte encrypted message after subBytes
								subBytesDone);		// set enableShiftRows when finished
				
	shiftRows shiftRows(		clk,				// input clock	
								rst,				// input reset
								enableShiftRows,	// begin shiftRows
								messageInSR,		// unsigned 16-byte message to be encrypted in shiftRows
								messageOutSR,		// unsigned 16-byte encrypted message after shiftRows
								shiftRowsDone);		// set enableMixColumns when finished
					
	mixColumns mixColumns(		clk,				// input clock
								rst,				// input reset
								enableMixColumns,	// begin mixColumns
								messageInMC,		// unsigned 16-byte message to be encrypted in mixColumns
								messageOutMC,		// unsigned 16-byte encrypted message after mixColumns
								mixColumnsDone);	// set enableAddRoundKey when finished
					
	addRoundKey addRoundKey(	clk,				// input clock
								rst,				// input reset
								enableAddRoundKey,	// begin addRoundKey
								messageInARK,		// unsigned 16-byte message to be encrypted in addRoundKey
								newKey,				// unsigned 16 bytes of 176-byte expanded key
								messageOutARK,		// unsigned 16-byte message encrypted after addRoundKey
								addRoundKeyDone);	// set enableSubBytes when finished
		
endmodule