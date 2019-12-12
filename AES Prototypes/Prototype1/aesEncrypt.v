module aesEncrypt(	input clk, 						// input clock
					input rst, 						// input reset
					input start, 					// begin encryption
					input encOrDec,					// set high for encryption, low for decryption
					input [2:0] keySize,			// encoded size of key (128-bit/192-bit/256-bit)	
					input [0:127] messageIn, 		// unsigned 16-byte message to be encrypted
					output reg [0:127] messageOut,	// unsigned 16-byte encrypted message
					output [0:255] key,
					output reg done);				// set when encryption is finished
	
	integer countRounds = 0;			// which round is currently executing
	reg checkingDone;					// set when checking is finished for rounds
	reg initialRound;					// set when it is in initial round
	reg finalRound;						// set when it is in final round
	reg [4:0] numRounds;				// either 10, 12, or 14 rounds
	reg [0:127] tempIn;					// unsigned 16-byte partially encrypted message from previous round
	wire enableKeyExp;					// begin keyExp
	wire enableKeyControl;				// begin keyControl
	wire enableRounds;					// begin rounds
	wire keyExpDone;					// set when keyExpansion is finished
	wire keyControlDone;				// set when keyControl is finished
	wire roundsDone;					// set when a round has finished
	wire [0:127] newKey;				// output key from keyControl for rounds
	wire [0:127] tempOut;				// unsigned 16-byte partially encrypted message from current round
	wire [0:1919] keyExp;				// unsigned 176-byte expanded key

	wire [0:256] testKey = {8'h00, 8'h01, 8'h02, 8'h03,		// unsigned 16-byte test key
							8'h04, 8'h05, 8'h06, 8'h07,		// unsigned 16-byte test key
							8'h08, 8'h09, 8'h0a, 8'h0b,		// unsigned 16-byte test key
							8'h0c, 8'h0d, 8'h0e, 8'h0f,		// unsigned 16-byte test key
							8'h10, 8'h11, 8'h12, 8'h13,		// unsigned 16-byte test key
							8'h14, 8'h15, 8'h16, 8'h17,		// unsigned 16-byte test key
							8'h18, 8'h19, 8'h1a, 8'h1b,		// unsigned 16-byte test key
							8'h1c, 8'h1d, 8'h1e, 8'h1f};	// unsigned 16-byte test key
							
	
	always @ (keySize)
		begin
			case(keySize)
				3'b100 : 
					begin
						numRounds <= 5'd15;
					end
				3'b010 : 
					begin
						numRounds <= 5'd13;
					end
				default: 
					begin
						numRounds <= 5'd11; 
					end
			endcase
		end	
		
	always @ (posedge keyControlDone, posedge rst)
		begin			
			if(rst)
				begin
					checkingDone = 1'b0;
					initialRound = 1'b0;
					finalRound = 1'b0;
					countRounds = 0;
					done = 1'b0;
				end
			else
				begin
					#50;
					checkingDone = 1'b0;
					
					if(countRounds == 0)
						begin
							tempIn = messageIn;
							initialRound = 1'b1;
							finalRound = 1'b0;
							countRounds = countRounds + 1;
							done = 1'b0;
							#50;
							checkingDone = 1'b1;
						end
					else if(countRounds < (numRounds - 5'd1))
						begin
							tempIn = tempOut;
							initialRound = 1'b0;
							finalRound = 1'b0;
							countRounds = countRounds + 1;
							done = 1'b0;
							#50;
							checkingDone = 1'b1;
						end
					else if(countRounds == (numRounds - 5'd1))
						begin
							tempIn = tempOut;
							initialRound = 1'b0;
							finalRound = 1'b1;
							countRounds = countRounds + 1;
							done = 1'b0;
							#50;
							checkingDone = 1'b1;
						end
					else
						begin
							messageOut = tempOut;
							done = 1'b1;
							initialRound = 1'b0;
							finalRound = 1'b0;
							countRounds = 5'b11111;
							#50;
							checkingDone = 1'b0;
						end
				end
		end
	
	assign enableKeyExp = start & encOrDec;
	assign enableKeyControl = keyExpDone | roundsDone;
	assign enableRounds = checkingDone;				
	
	keyExpansion keyExpansion(	clk, 						// input clock
								rst, 						// input reset
								enableKeyExp, 				// begin keyExpansion
								numRounds,					// either 10, 12, or 14 rounds
								testKey, 					// unsigned 16-byte key
								keyExp, 					// unsigned 176-byte expanded key
								keyExpDone);				// set when keyExpansion is finished
					
	keyControl keyControl(		clk,						// input clock
								rst,						// input reset
								enableKeyControl,			// begin keyControl
								keyExp,						// unsigned 176-byte expanded key
								newKey,						// output newKey for rounds
								keyControlDone);			// set when keyControl is finished
						
	rounds rounds(				clk,						// input clock		
								rst,						// input reset
								enableRounds,				// begin rounds		
								initialRound,				// set when it is in initialRound
								finalRound,					// set when it is in finalRound
								done,
								tempIn,						// unsigned 16-byte message to be encrypted in 1 round
								newKey,						// output newKey from keyControl for rounds
								tempOut,					// unsigned 16-byte encrypted message after 1 round
								roundsDone);				// set when 1 round is finished
					
endmodule