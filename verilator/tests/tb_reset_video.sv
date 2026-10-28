`timescale 1ns/1ps
module tb_reset_video;
reg clk = 0;
always #5 clk = ~clk;
reg external_reset = 1;
reg [127:0] status = 0;
reg [10:0] ps2_key = 0;
wire raw_vblank, ce, de, hs, vs, hb, vb;
wire [7:0] x, r, g, b;
wire [8:0] y;
integer pixels = 0, h_edges = 0, v_edges = 0, reset_edges = 0;
integer ce_gap = 0;
reg hs_d = 0, vs_d = 0, reset_d = 0;

emu dut (.RESET(external_reset));
reset_video_source source (
    .clk(clk), .reset_na(~dut.reset), .timing_reset_na(~dut.system_reset),
    .raw_vblank(raw_vblank), .ce_pix(ce),
    .de(de), .hs(hs), .vs(vs), .hb(hb), .vb(vb),
    .hpos(x), .vpos(y), .r(r), .g(g), .b(b)
);

initial begin
    force dut.clk_sys = clk;
    force dut.pll_locked = 1'b1;
    force dut.buttons = 2'b00;
    force dut.status = status;
    force dut.ps2_key = ps2_key;
    force dut.ioctl_download = 1'b0;
    force dut.OSD_STATUS = 1'b0;
    // Close the feedback loop through the real timing and renderer.
    force dut.raw_vblank = raw_vblank;
    force dut.ce_pix = ce;
    force dut.vid_de = de;
    force dut.vid_hs = hs;
    force dut.vid_vs = vs;
    force dut.vid_hb = hb;
    force dut.vid_vb = vb;
    force dut.vid_r = r;
    force dut.vid_g = g;
    force dut.vid_b = b;
end

always @(negedge clk) begin
    if (ce) pixels = pixels + 1;
    if (hs && !hs_d) h_edges = h_edges + 1;
    if (vs && !vs_d) v_edges = v_edges + 1;
    if (dut.master_reset && !reset_d) reset_edges = reset_edges + 1;
    hs_d = hs;
    vs_d = vs;
    reset_d = dut.master_reset;
    if (dut.system_reset || ce) ce_gap = 0;
    else ce_gap = ce_gap + 1;
    if (!dut.system_reset && ce_gap > 8)
        $fatal(1, "Reset stopped pixel enables sent to MiSTer");
    if (dut.reset_control.vblank !== raw_vblank)
        $fatal(1, "Reset release does not use raw timing");
end

task check_pulse;
    integer start_pixels, start_h, start_v;
    wait (dut.master_reset === 1'b1);
    @(negedge clk);
    start_pixels = pixels; start_h = h_edges; start_v = v_edges;
    if (dut.power_cycle !== 0) $fatal(1, "Master Control power cycled");
    wait (dut.master_reset === 1'b0);
    @(negedge clk);
    if (pixels - start_pixels < 59000 || pixels - start_pixels > 60000 ||
        h_edges - start_h < 260 || v_edges - start_v < 1)
        $fatal(1, "Video sync or pixel stream stopped during reset");
endtask

task menu_reset;
    // A brief OSD command entirely between field samples must be retained.
    @(negedge clk); status[27] = 1;
    @(negedge clk); status[27] = 0;
    check_pulse;
endtask

integer count;
initial begin
    repeat (8) @(negedge clk);
    external_reset = 0;
    @(negedge raw_vblank);
    repeat (100) @(negedge clk);
    menu_reset;
    menu_reset;
    ps2_key = {!ps2_key[10], 1'b1, 9'h076};
    check_pulse;
    count = reset_edges;
    repeat (500000) @(negedge clk);
    if (reset_edges != count || dut.reset !== 0)
        $fatal(1, "Held Esc repeated or latched reset");
    ps2_key = {!ps2_key[10], 1'b0, 9'h076};
    repeat (2) @(negedge raw_vblank);
    ps2_key = {!ps2_key[10], 1'b1, 9'h076};
    check_pulse;
    // The main Reset action must still take the power-cycle path.
    status[0] = 1;
    repeat (3) @(negedge clk);
    if (dut.power_cycle !== 1 || dut.reset !== 1)
        $fatal(1, "Menu Reset did not power cycle");
    status[0] = 0;
    repeat (20) @(negedge clk);
    if (dut.reset !== 0) $fatal(1, "Menu Reset did not release");
    @(negedge raw_vblank);
    $display("Menu and Esc reset feedback, pixel stream, sync and recovery passed");
    $finish;
end

initial begin
    #30000000;
    $fatal(1, "Reset feedback test timed out");
end
endmodule
