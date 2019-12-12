module aes(	input clock,					// DE2-115 on-board 50 MHz internal clock
			input reset,
			input encOrDec,
			input [0:2] keySize,
			input [0:127] messageIn, 		// unsigned 16-byte message to be encrypted
			output done,
			output [0:127] messageOut);		// unsigned 16-byte encrypted message
	
	wire [0:127] messageE;
	wire [0:127] messageD;


	assign messageE = messageIn;
	
	assign messageD = messageIn;
	
controlUnit controlUnit (	clock,
							reset,
							encOrDec,
							keySize,
							messageE,
							messageD,
							done,
							messageOut
							);


endmodule