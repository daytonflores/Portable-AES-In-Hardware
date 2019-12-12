module addRoundKey(		input clk, 						// input clock
						input rst, 						// input reset
						input enableAddRoundKey, 		// begin addRoundKey
						input [0:127] state, 			// unsigned 16-byte message to be encrypted
						input [0:127] newKey, 			// unsigned 16 bytes of 176-byte expanded key
						output reg [0:127] stateOut,	// unsigned 16-byte encrypted message
						output reg roundsDone);			// set when addRoundKey is finished
	
	
	always@ (posedge enableAddRoundKey, posedge rst)
		begin
			if(rst)
				begin
					stateOut = 128'd0;
					roundsDone = 1'b0;
				end
			else
				begin
					#50;
					roundsDone = 1'b0;
					stateOut = state ^ newKey;
					#50;
					roundsDone = 1'b1;
				end
		end
		
endmodule