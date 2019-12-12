module aes(	input CLOCK_50,					// DE2-115 on-board 50 MHz internal clock
			input start, 					// begin encryption/decryption
			input [0:127] messageIn, 		// unsigned 16-byte message to be encrypted
			input [3:0] KEY, 				// DE2-115 on-board push buttons
			input [17:0] SW,				// DE2-115 on-board switches
			output [0:127] messageOut,		// unsigned 16-byte encrypted message
			output [6:0] HEX0,				// DE2-115 on-board 7-segment display [0]
			output [6:0] HEX1,				// DE2-115 on-board 7-segment display [1]
			output [6:0] HEX2,				// DE2-115 on-board 7-segment display [2]
			output [6:0] HEX3,				// DE2-115 on-board 7-segment display [3]
			output [6:0] HEX4,				// DE2-115 on-board 7-segment display [4]
			output [6:0] HEX5,				// DE2-115 on-board 7-segment display [5]
			output [6:0] HEX6,				// DE2-115 on-board 7-segment display [6]
			output [6:0] HEX7,				// DE2-115 on-board 7-segment display [7]
			output [17:0] LEDR);			// DE2-115 on-board red LEDs
		
	wire [0:127] testMessage = "This is a test!!";		// unsigned 16-byte test message to be encrypted
	wire [0:127] testE;
	wire [0:127] testD = 128'hfa6a5db133bba6abe3e8536d223ac295;
	wire doneE;
	wire doneD;
	reg clk_out;
	integer count;
	
	assign LEDR[0] = doneE;
	assign LEDR[1] = doneD;
	
	assign testE[0:7] = testMessage[0:7];
	assign testE[32:39] = testMessage[8:15];
	assign testE[64:71] = testMessage[16:23];
	assign testE[96:103] = testMessage[24:31];
	assign testE[8:15] = testMessage[32:39];
	assign testE[40:47] = testMessage[40:47];
	assign testE[72:79] = testMessage[48:55];
	assign testE[104:111] = testMessage[56:63];
	assign testE[16:23] = testMessage[64:71];
	assign testE[48:55] = testMessage[72:79];
	assign testE[80:87] = testMessage[80:87];
	assign testE[112:119] = testMessage[88:95];
	assign testE[24:31] = testMessage[96:103];
	assign testE[56:63] = testMessage[104:111];
	assign testE[88:95] = testMessage[112:119];
	assign testE[120:127] = testMessage[120:127];
/*	
	assign message[0:7] = messageIn[0:7];
	assign message[32:39] = messageIn[8:15];
	assign message[64:71] = messageIn[16:23];
	assign message[96:103] = messageIn[24:31];
	assign message[8:15] = messageIn[32:39];
	assign message[40:47] = messageIn[40:47];
	assign message[72:79] = messageIn[48:55];
	assign message[104:111] = messageIn[56:63];
	assign message[16:23] = messageIn[64:71];
	assign message[48:55] = messageIn[72:79];
	assign message[80:87] = messageIn[80:87];
	assign message[112:119] = messageIn[88:95];
	assign message[24:31] = messageIn[96:103];
	assign message[56:63] = messageIn[104:111];
	assign message[88:95] = messageIn[112:119];
	assign message[120:127] = messageIn[120:127];
	
*/
	always @(posedge CLOCK_50) 
		begin
			if(count == 0)
				begin
					count <= 124999999;
					clk_out <= !clk_out;
				end
			else
				begin
					count <= count - 1;
				end
		end
	
controlUnit controlUnit (	clk_out,
							~KEY[0],
							start,
							SW[0],
							SW[17:15],
							testE,
							doneE,
							doneD,
							messageOut,	
							HEX0,
							HEX1,
							HEX2,
							HEX3,
							HEX4,
							HEX5,
							HEX6,
							HEX7
							);


endmodule