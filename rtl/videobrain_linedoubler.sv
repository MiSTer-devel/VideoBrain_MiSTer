module videobrain_linedoubler (
    input wire clk,
    input wire reset,
    input wire ce_pix,
    input wire [7:0] r, g, b,
    input wire hs, vs, hb, vb,
    output reg ce_out = 0,
    output wire [7:0] r_out, g_out, b_out,
    output wire hs_out, vs_out, hb_out, vb_out
);

// Source pixels arrive every four clocks, with 228 samples per line.
reg [27:0] lines [0:511];
reg [27:0] pixel = {4'b0011, 24'd0};
reg hs_d = 0;
reg captured = 0, reading = 0;
reg write_bank = 0, read_bank = 0;
reg [7:0] write_x = 0, read_x = 0;
reg half_phase = 0;

wire line_start = ce_pix && hs && !hs_d;
wire read_enable = (line_start && captured) || (reading && half_phase);
wire [8:0] read_addr = line_start ? {write_bank, 8'd0} : {read_bank, read_x};
wire [8:0] write_addr = line_start ? {write_bank ^ captured, 8'd0} : {write_bank, write_x};

// Read the completed line twice while the other bank captures the next one.
always @(posedge clk) begin
    if (!reset && ce_pix && (captured || line_start))
        lines[write_addr] <= {hs, vs, hb, vb, r, g, b};
    if (!reset && read_enable) pixel <= lines[read_addr];
    if (reset) pixel <= {4'b0011, 24'd0};
end

always @(posedge clk) begin
    ce_out <= !reset && read_enable;
    if (reset) begin
        hs_d <= 0;
        captured <= 0;
        reading <= 0;
        write_bank <= 0;
        read_bank <= 0;
        write_x <= 0;
        read_x <= 0;
        half_phase <= 0;
    end else begin
        half_phase <= ~half_phase;
        if (ce_pix) begin
            hs_d <= hs;
            if (captured) write_x <= (write_x == 227) ? 8'd0 : write_x + 1'b1;
        end
        if (read_enable) read_x <= (read_x == 227) ? 8'd0 : read_x + 1'b1;
        if (line_start) begin
            captured <= 1;
            write_x <= 1;
            half_phase <= 0;
            if (captured) begin
                reading <= 1;
                read_bank <= write_bank;
                write_bank <= ~write_bank;
                read_x <= 1;
            end
        end
    end
end

assign {hs_out, vs_out, hb_out, vb_out, r_out, g_out, b_out} = pixel;

endmodule
