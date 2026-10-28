LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.base_pack.ALL;
USE work.uv201_pack.ALL;

ENTITY reset_video_source IS
  PORT (
    clk, reset_na, timing_reset_na : IN std_logic;
    raw_vblank, ce_pix, de, hs, vs, hb, vb : OUT std_logic;
    hpos : OUT unsigned(7 DOWNTO 0);
    vpos : OUT unsigned(8 DOWNTO 0);
    r, g, b : OUT uv8
  );
END ENTITY;

ARCHITECTURE test OF reset_video_source IS
  SIGNAL brclk_ena, hblank, vblank : std_logic;
  SIGNAL x : unsigned(7 DOWNTO 0);
  SIGNAL y : unsigned(8 DOWNTO 0);
BEGIN
  clocks : ENTITY work.uv202_clkgen
    PORT MAP (clk => clk, reset_na => reset_na OR timing_reset_na,
              mclk_ena => OPEN, brclk_ena => brclk_ena,
              brclk_phase => OPEN, cpu_ena => OPEN, cpu_sample => OPEN);

  timing : ENTITY work.uv202_timing
    PORT MAP (clk => clk, reset_na => reset_na OR timing_reset_na,
              brclk_ena => brclk_ena, progressive => '0',
              hblank => hblank, vblank => vblank, field => OPEN,
              hpos => x, vpos => y, burst => OPEN, csync => OPEN,
              scanline => OPEN, line_start => OPEN,
              hblank_falling => OPEN, hblank_rising => OPEN);

  render : ENTITY work.uv201_render
    PORT MAP (clk => clk, reset_na => reset_na, timing_reset_na => timing_reset_na,
              brclk_ena => brclk_ena,
              hblank => hblank, vblank => vblank, hpos => x, vpos => y,
              fifo_valid => '0', fifo_entry => UV201_FIFO_ENTRY_ZERO,
              fifo_pop => OPEN, final_mod => x"00", background => x"07",
              x_zoom => '0', video_en => '1', ce_pix => ce_pix, idx => OPEN,
              r => r, g => g, b => b, de => de, hs => hs, vs => vs,
              hb => hb, vb => vb);

  raw_vblank <= vblank;
  hpos <= x;
  vpos <= y;
END ARCHITECTURE;
