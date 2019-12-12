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
reg [0:3] state;
reg [0:7] din;
reg [0:127] messageIn;	

wire aesDone;
wire rxRdy;		
wire txBusy;
wire [0:7] dout;
wire [0:135] messageOut;
		
integer count = 0;	
integer i = 0;

parameter waitForRX = 4'b0000;
parameter receiveByte = 4'b0001;
parameter checkForNextRX = 4'b0010;
parameter waitForAES = 4'b0100;
parameter waitForTX = 4'b0101;
parameter transmitByte = 4'b0110;
parameter checkForNextTX = 4'b0111;

initial
	begin
		aesReset <= 1;
		count <= 0;
		din <= 0;
		i <= 0;
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
					messageIn[i +: 8] <= dout;
					rxRdyClr <= 1;
					
					state <= checkForNextRX;
				end	
			checkForNextRX:
				begin
					if(count != 15)
						begin
							aesReset <= 0;
							count <= count + 1;
							i <= i + 8;
							rxRdyClr <= 0;
							
							state <= waitForRX;
						end
					else
						begin
							aesReset <= 1;
							i <= 0;
							count <= 0;
							rxRdyClr <= 0;
							
							state <= waitForAES; //waitForTX;
						end
				end
			waitForAES:
				begin
					aesReset <= 0;
					
					if(aesDone)
						begin
							state <= waitForTX;
						end
				end
			waitForTX:
				begin
					txBegin <= 0;
					
					if(!txBusy)
						begin
							din <= messageOut[i +:8];
							//din <= messageIn[i +:8];
							
							state <= transmitByte;
						end
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
							txBegin <= 0;
							if(count != 16)
								begin
									count <= count + 1;
									i <= i + 8;
									
									state <= waitForTX;
								end
							else
								begin
									count <= 0;
									i <= 0;

									
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

aes aes (	clock,
			aesReset,
			encOrDec,
			keySize,
			messageIn,
			aesDone,
			messageOut
		);
		
uart uart (	clock,
			txBegin,
			rx,
			rxRdyClr,
			din,
			tx,
			txBusy,
			rxRdy,
			dout
		   );

endmodule 