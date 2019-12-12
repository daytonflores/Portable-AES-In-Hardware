module addRoundKey(		input [0:127] state, 			// unsigned 16-byte message to be encrypted
						input [0:127] newKey, 			// unsigned 16 bytes of 176-byte expanded key
						output [0:127] stateOut);	// unsigned 16-byte encrypted message
	
	assign stateOut = state ^ newKey;
		
endmodule