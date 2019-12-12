module keyExpansion(	input rst, 							// input reset
						input enableKeyExpansion, 			// begin keyExpansion
						input [2:0] keySize,				// either 10, 12, or 14 rounds
						output reg [0:1919] keyExp); 		// unsigned 176-byte expanded key		
						
	always @(posedge enableKeyExpansion or posedge rst)
		begin
			if(rst)
				begin
					keyExp = 1920'd0;
				end			
			else
				begin				
					if(keySize == 3'b010)
						begin
							keyExp [0:127] = 128'h000102030405060708090a0b0c0d0e0f;
							keyExp [128:255] = 128'h10111213141516175846f2f95c43f4fe;
							keyExp [256:383] = 128'h544afef55847f0fa4856e2e95c43f4fe;
							keyExp [384:511] = 128'h40f949b31cbabd4d48f043b810b7b342;
							keyExp [512:639] = 128'h58e151ab04a2a5557effb5416245080c;
							keyExp [640:767] = 128'h2ab54bb43a02f8f662e3a95d66410c08;
							keyExp [768:895] = 128'hf501857297448d7ebdf1c6ca87f33e3c;
							keyExp [896:1023] = 128'he510976183519b6934157c9ea351f1e0;
							keyExp [1024:1151] = 128'h1ea0372a995309167c439e77ff12051e;
							keyExp [1152:1279] = 128'hdd7e0e887e2fff68608fc842f9dcc154;
							keyExp [1280:1407] = 128'h859f5f237a8d5a3dc0c02952beefd63a;
							keyExp [1408:1535] = 128'hde601e7827bcdf2ca223800fd8aeda32;
							keyExp [1536:1663] = 128'ha4970a331a78dc09c418c271e3a41d5d;
						end
					else if(keySize == 3'b100)
						begin
							keyExp [0:127] = 128'h000102030405060708090a0b0c0d0e0f;
							keyExp [128:255] = 128'h101112131415161718191a1b1c1d1e1f;
							keyExp [256:383] = 128'ha573c29fa176c498a97fce93a572c09c;
							keyExp [384:511] = 128'h1651a8cd0244beda1a5da4c10640bade;
							keyExp [512:639] = 128'hae87dff00ff11b68a68ed5fb03fc1567;
							keyExp [640:767] = 128'h6de1f1486fa54f9275f8eb5373b8518d;
							keyExp [768:895] = 128'hc656827fc9a799176f294cec6cd5598b;
							keyExp [896:1023] = 128'h3de23a75524775e727bf9eb45407cf39;
							keyExp [1024:1151] = 128'h0bdc905fc27b0948ad5245a4c1871c2f;
							keyExp [1152:1279] = 128'h45f5a66017b2d387300d4d33640a820a;
							keyExp [1280:1407] = 128'h7ccff71cbeb4fe5413e6bbf0d261a7df;
							keyExp [1408:1535] = 128'hf01afafee7a82979d7a5644ab3afe640;
							keyExp [1536:1663] = 128'h2541fe719bf500258813bbd55a721c0a;
							keyExp [1664:1791] = 128'h4e5a6699a9f24fe07e572baacdf8cdea;
							keyExp [1792:1919] = 128'h24fc79ccbf0979e9371ac23c6d68de36;
						end		
					else
						begin
							keyExp [0:127] = 128'h000102030405060708090a0b0c0d0e0f;
							keyExp [128:255] = 128'hd6aa74fdd2af72fadaa678f1d6ab76fe;
							keyExp [256:383] = 128'hb692cf0b643dbdf1be9bc5006830b3fe;
							keyExp [384:511] = 128'hb6ff744ed2c2c9bf6c590cbf0469bf41;
							keyExp [512:639] = 128'h47f7f7bc95353e03f96c32bcfd058dfd;
							keyExp [640:767] = 128'h3caaa3e8a99f9deb50f3af57adf622aa;
							keyExp [768:895] = 128'h5e390f7df7a69296a7553dc10aa31f6b;
							keyExp [896:1023] = 128'h14f9701ae35fe28c440adf4d4ea9c026;
							keyExp [1024:1151] = 128'h47438735a41c65b9e016baf4aebf7ad2;
							keyExp [1152:1279] = 128'h549932d1f08557681093ed9cbe2c974e;
							keyExp [1280:1407] = 128'h13111d7fe3944a17f307a78b4d2b30c5;
						end	
				end	
		end
	
endmodule