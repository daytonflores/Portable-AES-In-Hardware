module uart(input clock,
				input wire wr_en,
				input wire rx,
				input wire rdy_clr,
				input wire [7:0] din,
				output wire tx,
				output wire tx_busy,
				output wire rdy,
				output wire [7:0] dout);

	wire rxclk_en, txclk_en;
	
	baud_rate_gen uart_baud(clock,
							rxclk_en,
							txclk_en);
	
	transmitter uart_tx(	wr_en,
							clock,
							txclk_en,
							din,
							tx,
							tx_busy);
	
	receiver uart_rx(	rx,
						rdy_clr,
						clock,
						rxclk_en,
						rdy,
						dout);

endmodule