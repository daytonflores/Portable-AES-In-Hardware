module shiftRows(	input clk,						// input clock
					input rst,						// input reset
					input enableShiftRows,			// begin shiftRows
					input [0:127] state,			// unsigned 16-byte message to be encrypted in shiftRows
					output reg [0:127] stateOut,	// unsigned 16-byte encrypted message after shiftRows
					output reg shiftRowsDone);		// set when shiftRows is finished
					
	always@ (posedge enableShiftRows, posedge rst)
		begin
			if(rst)
				begin
					stateOut = 128'd0;
					shiftRowsDone = 1'b0;
				end
			else
				begin
					#50;
					shiftRowsDone = 1'b0;
				
					stateOut[0:7] = state[0:7];
					stateOut[8:15] = state[40:47];
					stateOut[16:23] = state[80:87];
					stateOut[24:31] = state[120:127];
					stateOut[32:39] = state[32:39];
					stateOut[40:47] = state[72:79];
					stateOut[48:55] = state[112:119];
					stateOut[56:63] = state[24:31];
					stateOut[64:71] = state[64:71];
					stateOut[72:79] = state[104:111];
					stateOut[80:87] = state[16:23];				
					stateOut[88:95] = state[56:63];				
					stateOut[96:103] = state[96:103];
					stateOut[104:111] = state[8:15];
					stateOut[112:119] = state[48:55];
					stateOut[120:127] = state[88:95];		
					
					#50;
					shiftRowsDone = 1'b1;
				end	
		end
					
endmodule