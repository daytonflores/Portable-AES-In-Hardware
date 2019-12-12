module invKeyControl(	input rst, 							// input reset
						input enableInvKeyControl,
						input [0:1919] keyExp,				// unsigned 176-byte expanded key
						input [2:0] keySize,
						output reg [0:127] invNewKey);		// output key for invRounds
	
	integer bottom;
	integer bottom128 = 1280;				// bottom limit of bit-range
	integer bottom192 = 1536;
	integer bottom256 = 1792;

	always@ (posedge enableInvKeyControl or posedge rst)
		begin
			if(rst)
				begin
					invNewKey = 128'd0;
					bottom128 = 1280;				// bottom limit of bit-range
					bottom192 = 1536;
					bottom256 = 1792;
				end
			else
				begin
					if(keySize == 3'b100)
						begin
							bottom = bottom256;
						end
					else if(keySize == 3'b010)
						begin
							bottom = bottom192;
						end
					else
						begin
							bottom = bottom128;
						end
					
						case(bottom)
							0 : 		invNewKey = keyExp[0:127];
							128 : 		invNewKey = keyExp[128:255];
							256 : 		invNewKey = keyExp[256:383];
							384 : 		invNewKey = keyExp[384:511];
							512 :		invNewKey = keyExp[512:639]; 
							640 : 		invNewKey = keyExp[640:767];
							768 : 		invNewKey = keyExp[768:895];
							896 : 		invNewKey = keyExp[896:1023];
							1024 : 		invNewKey = keyExp[1024:1151];
							1152 : 		invNewKey = keyExp[1152:1279];
							1280 : 		invNewKey = keyExp[1280:1407];
							1408 : 		invNewKey = keyExp[1408:1535];
							1536 : 		invNewKey = keyExp[1536:1663];
							1664 : 		invNewKey = keyExp[1664:1791];
							1792 : 		invNewKey = keyExp[1792:1919];
							default :	invNewKey = 128'd0; 		
						endcase
						
					bottom256 = bottom256 - 128;
					bottom192 = bottom192 - 128;
					bottom128 = bottom128 - 128;
				end	
		end				

endmodule