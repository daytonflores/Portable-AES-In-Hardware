module invShiftRows(input [0:127] state,			// unsigned 16-byte message to be encrypted in invShiftRows
					output [0:127] stateOut);		// unsigned 16-byte encrypted message after invShiftRows
			
	assign stateOut[0:7] = state[0:7];
	assign stateOut[8:15] = state[104:111];
	assign stateOut[16:23] = state[80:87];
	assign stateOut[24:31] = state[56:63];
	assign stateOut[32:39] = state[32:39];
	assign stateOut[40:47] = state[8:15];
	assign stateOut[48:55] = state[112:119];
	assign stateOut[56:63] = state[88:95];
	assign stateOut[64:71] = state[64:71];
	assign stateOut[72:79] = state[40:47];
	assign stateOut[80:87] = state[16:23];				
	assign stateOut[88:95] = state[120:127];				
	assign stateOut[96:103] = state[96:103];
	assign stateOut[104:111] = state[72:79];
	assign stateOut[112:119] = state[48:55];
	assign stateOut[120:127] = state[24:31];	
					
endmodule