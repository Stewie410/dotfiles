local wezterm = require("wezterm") --[[@as Wezterm]]
local gpu = require("util.gpu")

local base = {
  fps = 60,
  scheme = "Campbell (Gogh)",
  colors = nil,
  animation = {
    cursor = "Linear",
    text = "Linear",
    rapid = "Linear",
  },
  font = {
    face = { "FiraCode Nerd Font" },
    size = 9,
  },
}
base.colors = wezterm.get_builtin_color_schemes()[base.scheme]

---@type Config
---@diagnostic disable-next-line: missing-fields
return {
  max_fps = base.fps,
  front_end = "WebGpu",
  webgpu_power_preference = "HighPerformance",
  webgpu_preferred_adapter = gpu:pick_best(),

  animation_fps = base.fps,

  default_cursor_style = "BlinkingBlock",
  cursor_blink_ease_in = base.animation.cursor,
  cursor_blink_ease_out = base.animation.cursor,

  text_blink_ease_in = base.animation.text,
  text_blink_ease_out = base.animation.text,
  text_blink_rapid_ease_in = base.animation.rapid,
  text_blink_rapid_ease_out = base.animation.rapid,

  ui_key_cap_rendering = "Emacs",

  enable_scroll_bar = false,

  tab_max_width = 25,
  switch_to_last_active_tab_when_closing_tab = true,
  hide_tab_bar_if_only_one_tab = false,
  tab_bar_at_bottom = true,
  use_fancy_tab_bar = false,
  show_new_tab_button_in_tab_bar = false,
  show_tab_index_in_tab_bar = true,

  font = wezterm.font_with_fallback(base.font.face),
  font_size = base.font.size,
  command_palette_font_size = base.font.size,
  char_select_font_size = base.font.size,
  use_cap_height_to_scale_fallback_fonts = true,
  adjust_window_size_when_changing_font_size = false,
  allow_square_glyphs_to_overflow_width = "Never",

  color_scheme = base.scheme,
  command_palette_bg_color = "black",
  char_select_bg_color = "black",
  ---@diagnostic disable-next-line: missing-fields
  inactive_pane_hsb = {
    saturation = 0.9,
    brightness = 0.9,
  },
}
