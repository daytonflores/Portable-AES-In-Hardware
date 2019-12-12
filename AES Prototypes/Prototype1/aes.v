module aes(	input clk,						// input clock
			input rst, 						// input reset
			input start, 					// begin encryption/decryption
			input encOrDec,					// set high for encryption, low for decryption
			input [2:0] keySize,			// encoded size of key (128-bit/192-bit/256-bit)
			input [0:127] messageIn, 		// unsigned 16-byte message to be encrypted
			output [0:127] messageOutE,		// unsigned 16-byte encrypted message
			output [0:127] messageOutD,
			output started,
			output doneE,					// set when encryption is finished
			output doneD);					// set when decryption is finished
		
	wire [0:127] testMessage = "This is a test!!";		// unsigned 16-byte test message to be encrypted
	wire [0:255] key;
	
	wire [0:127] testE;
	wire [0:127] testD = 128'hfa6a5db133bba6abe3e8536d223ac295;
	
	reg [0:127] messageInE;
	reg [0:127] messageInD;
	
	assign started = start;
	
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
	always @ (encOrDec)
		begin
			case (encOrDec)
				1'b1: 
					begin
						messageInE <= testE;
					end
				1'b0:
					begin
						messageInD <= messageOutE;
					end
			endcase
		end
	
	aesEncrypt aesEncrypt(	clk, 						// input clock
							rst, 						// input reset
							start, 						// begin encryption if encOrDec is set high
							encOrDec,					// set high for encryption, low for decryption
							keySize,					// encoded size of key (128-bit/192-bit/256-bit)
							messageInE, 				// unsigned 16-byte test message to be encrypted
							messageOutE,				// unsigned 16-byte encrypted message
							key,
							doneE);						// set when encryption is finished
							
	aesDecrypt aesDecrypt(	clk, 						// input clock
							rst, 						// input reset
							start, 						// begin decryption if encOrDec is set low
							encOrDec,					// set high for encryption, low for decryption
							keySize,					// encoded size of key (128-bit/192-bit/256-bit)
							messageInD, 				// unsigned 16-byte test message to be encrypted
							key,
							messageOutD,				// unsigned 16-byte encrypted message
							doneD);						// set when decryption is finished

endmodule