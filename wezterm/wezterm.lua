local wezterm = require("wezterm")

-- Use config builder when available
local config = {}
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- =========================================================
-- Cross-platform PATH fix (macOS GUI apps lack shell PATH)
-- =========================================================
if wezterm.target_triple:find("apple") then
  -- macOS (Intel + Apple Silicon Homebrew)
  config.set_environment_variables = {
    PATH = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin",
  }
else
  -- Linux (Fedora, etc.)
  config.set_environment_variables = {
    PATH = "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin",
  }
end

-- =========================================================
-- Appearance
-- =========================================================
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 13

-- Catppuccin (bundled in modern WezTerm)
config.color_scheme = "Catppuccin Mocha"

-- Remove UI noise
config.enable_tab_bar = false
config.use_fancy_tab_bar = false
config.enable_scroll_bar = false
config.window_decorations = "RESIZE"

-- No animations or blinking
config.animation_fps = 0
config.cursor_blink_rate = 0

-- Solid background (no transparency quirks)
config.window_background_opacity = 1.0

-- =========================================================
-- Rendering
-- =========================================================
-- GPU rendering; falls back automatically if unsupported
config.front_end = "WebGpu"

-- =========================================================
-- tmux-first behavior
-- =========================================================
config.default_prog = {
  "tmux",
  "new-session",
  "-A",
  "-s",
  "main",
}

-- Let tmux own everything
config.disable_default_key_bindings = true
config.keys = {}
config.mouse_bindings = {}
config.scrollback_lines = 0

-- =========================================================
-- Platform polish
-- =========================================================
-- macOS: respect native fullscreen (Ctrl+Cmd+F)
config.native_macos_fullscreen_mode = true

return config
