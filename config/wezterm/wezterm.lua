local wezterm = require("wezterm")
local config = wezterm.config_builder()

local colors = {
	fg = "#d0d7de",
	bg = "#0d1117",
	comment = "#8b949e",
	red = "#ff7b72",
	green = "#3fb950",
	yellow = "#d29922",
	blue = "#539bf5",
	magenta = "#bc8cff",
	cyan = "#39c5cf",
	selection = "#415555",
	caret = "#58a6ff",
	invisibles = "#2f363d",
}

config.keys = {
	-- Copier avec CTRL+C (si du texte est sélectionné)
	{ key = "C", mods = "CTRL", action = wezterm.action.CopyTo("Clipboard") },
	-- Coller avec CTRL+V
	{ key = "V", mods = "CTRL", action = wezterm.action.PasteFrom("Clipboard") },
	-- Alternative : Copier avec CTRL+SHIFT+C (si besoin)
	{ key = "C", mods = "CTRL|SHIFT", action = wezterm.action.CopyTo("Clipboard") },
	-- Alternative : Coller avec CTRL+SHIFT+V (si besoin)
	{ key = "V", mods = "CTRL|SHIFT", action = wezterm.action.PasteFrom("Clipboard") },
}

config.color_scheme = "Catppuccin Macchiato"
-- config.font = "JetBrainsMonoNL NF"

-- Performance settings
config.max_fps = 120
config.animation_fps = 1
config.window_background_opacity = 0.98
config.enable_scroll_bar = false
config.use_fancy_tab_bar = false
config.term = "xterm-256color"
config.warn_about_missing_glyphs = false
config.enable_wayland = false
config.front_end = "OpenGL"
config.webgpu_power_preference = "HighPerformance"
config.prefer_egl = true
config.freetype_load_target = "Light"
config.freetype_render_target = "HorizontalLcd"
config.hide_tab_bar_if_only_one_tab = false

config.window_frame = {
	font = wezterm.font({ family = "JetBrainsMonoNL NF", weight = "Regular", style = "Italic" }),
	font_size = 12.0,
	active_titlebar_bg = colors.bg,
}

return config
