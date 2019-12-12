module transmitter(input wire wr_en,
				   input wire clk_50m,
				   input wire clken,
				   input wire tParity,
				   input wire [7:0] din,
				   output reg tx,
				   output wire tx_busy);

	initial begin
		 tx = 1'b1;
	end

	parameter STATE_IDLE	= 3'b000;
	parameter STATE_START	= 3'b001;
	parameter STATE_DATA	= 3'b010;
	parameter STATE_STOP	= 3'b011;
	parameter STATE_PARITY = 3'b100;

	reg [7:0] data = 8'h00;
	reg [2:0] bitpos = 3'h0;
	reg [2:0] state = STATE_IDLE;

	always @(posedge clk_50m) begin
		case (state)
		STATE_IDLE: begin
			if (wr_en) begin
				state <= STATE_START;
				data <= din;
				bitpos <= 3'h0;
			end
		end
		STATE_START: begin
			if (clken) begin
				tx <= 1'b0;
				state <= STATE_DATA;
			end
		end
		STATE_DATA: begin
			if (clken) begin
				if (bitpos == 3'h7)begin
						state <= STATE_PARITY;
				end
				else
					bitpos <= bitpos + 3'h1;
				tx <= data[bitpos];
			end
		end
		STATE_PARITY: begin
			if (clken) begin
				tx <= tParity;
				state <= STATE_STOP;
			end
		end
		STATE_STOP: begin
			if (clken) begin
				tx <= 1'b1;
				state <= STATE_IDLE;
			end
		end
		default: begin
			tx <= 1'b1;
			state <= STATE_IDLE;
		end
		endcase
	end

	assign tx_busy = (state != STATE_IDLE);

endmodule