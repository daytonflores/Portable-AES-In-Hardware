module invAddRoundKey(	input clk, 						// input clock
						input rst, 						// input reset
						input enableInvAddRoundKey, 	// begin invAddRoundKey
						input [0:127] state, 			// unsigned 16-byte message to be encrypted
						input [0:127] newKey, 			// unsigned 16 bytes of 176-byte expanded key
						output reg [0:127] stateOut,	// unsigned 16-byte encrypted message
						output reg invRoundsDone);		// set when invAddRoundKey is finished
	
	
	always@ (posedge enableInvAddRoundKey, posedge rst)
		begin
			if(rst)
				begin
					stateOut = 128'd0;
					invRoundsDone = 1'b0;
				end
			else
				begin
					stateOut = state ^ newKey;
					#50;
					invRoundsDone = 1'b1;
					#50;
					invRoundsDone = 1'b0;
				end
		end
		
endmodule