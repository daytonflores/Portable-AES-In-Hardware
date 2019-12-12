module invRounds(	input clk, 						// input clock
					input rst, 						// input reset
					input enableInvRounds, 			// begin rounds
					input initialRound,				// set when it is in initialRound
					input finalRound,				// set when it is in finalRound
					input done,
					input [0:127] messageIn, 		// unsigned 16-byte message to be encrypted in invShiftRows
					input [0:127] invNewKey, 		// unsigned 16 bytes of 176-byte expanded key
					output reg [0:127] messageOut,	// unsigned 16-byte encrypted message after invAddRoundKey
					output reg invRoundsDone);		// set enableFinalRound when finished
	
	reg [0:127] messageInISR;			// unsigned 16-byte message to be encrypted in invShiftRows
	reg [0:127] messageInISB;			// unsigned 16-byte message to be encrypted in invSubBytes
	reg [0:127] messageInIARK;			// unsigned 16-byte message to be encrypted in invAddRoundKey
	reg [0:127] messageInIMC;			// unsigned 16-byte message to be encrypted in invMixColumns
	wire enableInvShiftRows;			// enable invShiftRows	
	wire enableInvSubBytes;				// enable invSubBytes
	wire enableInvAddRoundKey;			// enable invAddRoundKey
	wire enableInvMixColumns;			// enable invMixColumns
	wire invShiftRowsDone;				// set when invShiftRows is finished
	wire invSubBytesDone;				// set when invSubBytes is finished
	wire invAddRoundKeyDone;			// set when invAddRoundKey is finished
	wire invMixColumnsDone;				// set when invMixColumns is finished
	wire [0:127] messageOutISR;			// unsigned 16-byte encrypted message after invShiftRows
	wire [0:127] messageOutISB;			// unsigned 16-byte encrypted message after invSubBytes
	wire [0:127] messageOutIARK;		// unsigned 16-byte encrypted message after invAddRoundKey
	wire [0:127] messageOutIMC;			// unsigned 16-byte encrypted message after invMixColumns
	
	assign enableInvShiftRows = enableInvRounds & ~initialRound & ~done;
	assign enableInvSubBytes = invShiftRowsDone & ~done;
	assign enableInvAddRoundKey = (enableInvRounds & initialRound | ~initialRound & invSubBytesDone) & ~done;
	assign enableInvMixColumns = ~initialRound & ~finalRound & invAddRoundKeyDone & ~done;
	
	always @ (*)
		begin
			case ({initialRound, finalRound, done})
				3'b100 : 
					begin
						messageInISR <= 128'bz;
						messageInISB <= 128'bz;
						messageInIARK <= messageIn;
						messageInIMC <= 128'bz;
						invRoundsDone <= invAddRoundKeyDone;
						messageOut <= messageOutIARK;
					end
				3'b000 :
					begin
						messageInISR <= messageIn;
						messageInISB <= messageOutISR;
						messageInIARK <= messageOutISB;
						messageInIMC <= messageOutIARK;
						invRoundsDone <= invMixColumnsDone;
						messageOut <= messageOutIMC;
					end
				3'b010 :
					begin
						messageInISR <= messageIn;
						messageInISB <= messageOutISR;
						messageInIARK <= messageOutISB;
						messageInIMC <= 128'bz;
						invRoundsDone <= invAddRoundKeyDone;
						messageOut <= messageOutIARK;
					end
				3'b001 :
					begin
						messageInISR <= messageIn;
						messageInISB <= messageOutISR;
						messageInIARK <= messageOutISB;
						messageInIMC <= 128'bz;
						invRoundsDone <= invAddRoundKeyDone;
						messageOut <= messageOutIARK;
					end
				default : 
					begin
						messageInISR <= 128'bz;
						messageInISB <= 128'bz;
						messageInIARK <= 128'bz;
						messageInIMC <= 128'bz;
						invRoundsDone <= 1'bz;
						messageOut <= 128'bz;
					end
			endcase
		end
	
	invShiftRows invShiftRows(		clk,					// input clock	
									rst,					// input reset
									enableInvShiftRows,		// begin invShiftRows
									messageInISR,			// unsigned 16-byte message to be encrypted in invShiftRows
									messageOutISR,			// unsigned 16-byte encrypted message after invShiftRows
									invShiftRowsDone);		// set enableInvMixColumns when finished
	
	invSubBytes invSubBytes(		clk,					// input clock
									rst,					// input reset
									enableInvSubBytes,		// begin invSubBytes
									messageInISB,			// unsigned 16-byte message to be encrypted in invSubBytes
									messageOutISB,			// unsigned 16-byte encrypted message after invSubBytes
									invSubBytesDone);		// set enableInvShiftRows when finished
					
	invAddRoundKey invAddRoundKey(	clk,					// input clock
									rst,					// input reset
									enableInvAddRoundKey,	// begin invAddRoundKey
									messageInIARK,			// unsigned 16-byte message to be encrypted in invAddRoundKey
									invNewKey,				// unsigned 16 bytes of 176-byte expanded key
									messageOutIARK,			// unsigned 16-byte message encrypted after invAddRoundKey
									invAddRoundKeyDone);	// set enableInvSubBytes when finished
									
	invMixColumns invMixColumns(	clk,					// input clock
									rst,					// input reset
									enableInvMixColumns,	// begin invMixColumns
									messageInIMC,			// unsigned 16-byte message to be encrypted in invMixColumns
									messageOutIMC,			// unsigned 16-byte encrypted message after invMixColumns
									invMixColumnsDone);		// set enableInvAddRoundKey when finished
		
endmodule