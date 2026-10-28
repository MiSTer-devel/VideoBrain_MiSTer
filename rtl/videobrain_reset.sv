module videobrain_reset (
    input wire clk,
    input wire reset,
    input wire vblank,
    input wire master_control,
    input wire menu_control,
    output wire master_reset
);

reg vblank_d = 1;
reg pressed = 0, pressed_d = 0;
reg menu_d = 0, menu_pending = 0;

// u39 samples the active-low key on /vblank, u26 ors q2 and /q1
always @(posedge clk) begin
    vblank_d <= vblank;
    menu_d <= menu_control;
    if (reset) begin
        pressed <= 0;
        pressed_d <= 0;
        menu_pending <= 0;
    end else begin
        // OSD commands can finish before the next field samples the key.
        if (menu_control && !menu_d) menu_pending <= 1;
        if (vblank_d && !vblank) begin
            pressed <= master_control | menu_pending | (menu_control && !menu_d);
            pressed_d <= pressed;
            menu_pending <= 0;
        end
    end
end

assign master_reset = pressed && !pressed_d;

endmodule
