module keyControl(	input rst, 							// input reset
					input enableKeyControl,				// begin keyControl
					input [0:1919] keyExp,				// unsigned 176-byte expanded key
					output reg [0:127] newKey);			// output key for rounds
	
	integer bottom = 0;				// bottom limit of bit-range

	always@ (posedge enableKeyControl, posedge rst)
		begin
			if(rst)
				begin
					newKey = 128'd0;
				end
			else
				begin
			
					case(bottom)
						0 : 		newKey = keyExp[0:127];
						128 : 		newKey = keyExp[128:255];
						256 : 		newKey = keyExp[256:383];
						384 : 		newKey = keyExp[384:511];
						512 :		newKey = keyExp[512:639]; 
						640 : 		newKey = keyExp[640:767];
						768 : 		newKey = keyExp[768:895];
						896 : 		newKey = keyExp[896:1023];
						1024 : 		newKey = keyExp[1024:1151];
						1152 : 		newKey = keyExp[1152:1279];
						1280 : 		newKey = keyExp[1280:1407];
						1408 : 		newKey = keyExp[1408:1535];
						1536 : 		newKey = keyExp[1536:1663];
						1664 : 		newKey = keyExp[1664:1791];
						1792 : 		newKey = keyExp[1792:1919];
						default :	newKey = 128'd0; 		
					endcase
					
					bottom = bottom + 128;
					
				end
		end	
					
endmodule