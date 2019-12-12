module aes_uart(	input clock,
						input reset,
						input encOrDec,
						input [0:2]keySize,
						input rx,
						output tx
			    );

reg aesReset;
reg rxRdyClr;
reg txBegin;
reg tParity;
reg tempParity;
reg tempmessageIn;
reg [0:3] state;
reg [0:7] din;
reg [0:127] messageIn;	
reg [0:15] parity;

wire aesDone;
wire rxRdy;		
wire txBusy;
wire [0:7] dout;
wire [0:127] messageOut;
		
integer count = 0;
integer countCheck;		
integer i = 0;
integer j = 0;
integer k = 0;
integer l = 0;

parameter waitForRX = 4'b0000;
parameter receiveByte = 4'b0001;
parameter checkForNextRX = 4'b0010;
parameter waitForAES = 4'b0100;
parameter waitForTX = 4'b0101;
parameter transmitByte = 4'b0110;
parameter checkForNextTX = 4'b0111;
parameter setMessageIn = 4'b1000;
parameter incrementJandK = 4'b1001;
parameter getParityValueTX = 4'b1010;
parameter incrementJ = 4'b1011;
parameter incrementL = 4'b1100;

initial
	begin
		aesReset <= 1;
		count <= 0;
		din <= 0;
		i <= 0;
		j <= 0;
		k <= 0;
		l <= 0;
		messageIn <= 0;
		rxRdyClr <= 0;
		txBegin <= 0;
		state <= waitForRX;
	end
		
always @(posedge clock)
			begin
				casex (state)
					waitForRX:
						begin
							rxRdyClr <= 0;
							
							if(rxRdy)
								begin
									state <= receiveByte;
								end
						end	
						
						
						
						
					receiveByte:
						begin
							if(count % 2 == 0)
								begin
									messageIn[j +: 8] <= dout;	//puts every other byte in the messageIn array
								end
							else
								begin
									parity[k] <= dout[0];		//puts the least significant bit of every other byte in the parity arry
								end
							countCheck <= count;
							rxRdyClr <= 1;
							state <= checkForNextRX;
						end	
					checkForNextRX:
						begin
							if(countCheck != 31)					//reads 32 bytes
								begin
									count <= count + 1;
									rxRdyClr <= 0;
									aesReset <= 0;
									
									if(countCheck % 2 == 0)
										begin
											j <= j + 8;				//increment messageIn pointer by 8 every time
										end
									else
										begin
											k <= k + 1;				//increment parity pointer by 1 every time
										end
									
									state <= waitForRX;
								end
							else
								begin
									j <= 0;
									k <= 0;
									l <= 0;
									tempParity <= 0;
									count <= 0;
									rxRdyClr <= 0;
									aesReset <= 1;
									state <= setMessageIn;
									
									messageIn <= "This is a test!!";		//set messageIn for testing purposes because even parity from Termite screws up input message
									
								end
						end
					setMessageIn:
						begin
							tempmessageIn <= ~messageIn[j];				//copy and invert most significant bit of byte to prevent race condition
							if(k != 15)											//go trough 16 bytes
								begin
									if(l != 7)									//xor all 8 bits to check parity
										begin	
											tempParity <= tempParity ^ messageIn[j+l];
											state <= incrementL;
										end
									else
										begin
											if(parity[k] != tempParity)	//if recieved parity and calculated parity are not equal invert most significant bit
												begin
													messageIn[j] <= tempmessageIn;
												end
											state <= incrementJandK;
										end
								end
							else
								begin
									//state <= waitForAES;
									state <= waitForTX;
									i <= 0;
									j <= 0;
									k <= 0;
									l <= 0;
								end
						end
					incrementL:
						begin
							l <= l + 1;											//increment messageIn pointer by 1
							state <= setMessageIn;
						end
					incrementJandK:
						begin
							tempParity <= 0;
							j <= j + 8;											//increment messageIn pointer by 8
							k <= k + 1;											//increment number of bytes used by 1
							l <= 0;
							
							state <= setMessageIn;
						end
						
						
						
						
					waitForAES:
						begin
							aesReset <= 0;
							
							if(aesDone)
								begin
									state <= waitForTX;//sendEmptyFirst;
								end
						end
					waitForTX:
						begin
							txBegin <= 0;
							
							if(!txBusy)
								begin
									//if(messageOut[i] == 0)
									//	din <= {1'b0, messageOut[(i+1) +:8]};
									//else
									//	din <= messageOut[i +:8];
									//din <= messageOut[i +:8];
									din <= messageIn[i +:8];
									state <= getParityValueTX;
								end
						end
						
						
						
					getParityValueTX:
						begin
							if(j != 8)
								begin
									tParity <= tParity ^ messageIn[i+j];	//set parity bit value for transmit
									state <= incrementJ;
								end
							else
								begin
									state <= transmitByte;
								end
						end
					incrementJ:
						begin
							j <= j + 1;											//increment messageIn pointer by 1
							state <= getParityValueTX;
						end
						
					transmitByte:
						begin
							txBegin <= 1;
							state <= checkForNextTX;
						end
					checkForNextTX:
						begin
							if(txBusy)
								begin
									if(count != 15)							//fixed extra byte issue only 16 sent out now
										begin
											j <= 0;
											i <= i + 8;							//increment messageIn pointer by 8
											count <= count + 1;
											txBegin <= 0;
											state <= waitForTX;
										end
									else
										begin
											j <= 0;
											i <= 0;
											tParity <= 0;
											count <= 0;
											txBegin <= 0;
											state <= waitForRX;
										end
								end
						end
						
						
						
						
					default:
						begin
							state <= waitForRX;
						end
				endcase
			end
	

/*aes aes (	clock,
			aesReset,
			encOrDec,
			keySize,
			messageIn,
			aesDone,
			messageOut
		);*/
			
uart uart (	clock,
			txBegin,
			rx,
			rxRdyClr,
			tParity,
			din,
			tx,
			txBusy,
			rxRdy,
			dout
		   );

endmodule 