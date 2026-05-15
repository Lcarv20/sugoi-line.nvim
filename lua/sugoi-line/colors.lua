local M = {}

local function to_hex(color)
	if type(color) == "string" then
		return color
	end
	if type(color) == "number" then
		return string.format("#%06x", color)
	end
	return nil
end

local function get_hl_color(name, attr)
	local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = true })
	if not ok or not hl or not hl[attr] then
		return nil
	end
	return to_hex(hl[attr])
end

local function adjust_brightness(hex, amount)
	if not hex or hex == "NONE" then
		return nil
	end
	hex = hex:gsub("^#", "")
	local r = tonumber(hex:sub(1, 2), 16)
	local g = tonumber(hex:sub(3, 4), 16)
	local b = tonumber(hex:sub(5, 6), 16)
	r = math.min(255, math.max(0, r + amount))
	g = math.min(255, math.max(0, g + amount))
	b = math.min(255, math.max(0, b + amount))
	return string.format("#%02x%02x%02x", r, g, b)
end

function M.extract(opts)
	opts = opts or {}
	local is_dark = vim.o.background == "dark"
	local bg = get_hl_color("Normal", "bg") or (is_dark and "#161616" or "#ffffff")
	local fg = get_hl_color("Normal", "fg") or (is_dark and "#eae6e1" or "#000000")
	local pill_bg = opts.pill_bg or adjust_brightness(bg, is_dark and 25 or -25)

	local colors = {
		bg = bg,
		fg = fg,
		pill_bg = pill_bg,

		mode_normal = get_hl_color("DiagnosticError", "fg") or (is_dark and "#f38ba8" or "#d32f2f"),
		mode_insert = get_hl_color("String", "fg") or (is_dark and "#a6e3a1" or "#388e3c"),
		mode_visual = get_hl_color("DiagnosticInfo", "fg") or (is_dark and "#89b4fa" or "#1976d2"),
		mode_cmd = get_hl_color("Statement", "fg") or (is_dark and "#f5c2e7" or "#7b1fa2"),

		diag_error = get_hl_color("DiagnosticError", "fg") or (is_dark and "#f38ba8" or "#d32f2f"),
		diag_warn = get_hl_color("DiagnosticWarn", "fg") or (is_dark and "#f9e2af" or "#f57c00"),
		diag_info = get_hl_color("DiagnosticInfo", "fg") or (is_dark and "#89b4fa" or "#1976d2"),

		git_branch = get_hl_color("Function", "fg") or (is_dark and "#b4befe" or "#1565c0"),
		git_add = get_hl_color("GitSignsAdd", "fg") or (is_dark and "#a6e3a1" or "#388e3c"),
		git_change = get_hl_color("GitSignsChange", "fg") or (is_dark and "#fab387" or "#f57c00"),
		git_remove = get_hl_color("GitSignsDelete", "fg") or (is_dark and "#f38ba8" or "#d32f2f"),

		file_info = get_hl_color("Function", "fg") or (is_dark and "#f5c2e7" or "#7b1fa2"),

		macro_recording = get_hl_color("DiagnosticError", "fg") or (is_dark and "#f38ba8" or "#d32f2f"),
		macro_recorded = get_hl_color("String", "fg") or (is_dark and "#a6e3a1" or "#388e3c"),

		accent = get_hl_color("CursorLineNr", "fg") or (is_dark and "#cba6f7" or "#c09030"),

		tab_fg = get_hl_color("Comment", "fg") or get_hl_color("LineNr", "fg") or (is_dark and "#706860" or "#8b8680"),
		sel_fg = get_hl_color("PmenuSel", "fg") or get_hl_color("Normal", "fg") or (is_dark and "#161616" or "#ffffff"),
		sel_bg = get_hl_color("PmenuSel", "bg")
			or get_hl_color("TabLineSel", "bg")
			or (is_dark and "#F0C040" or "#C09030"),
		logo_fg = "#16924c",
		fill_bg = "NONE",
		block_inactive_bg = pill_bg,
		block_active_bg = get_hl_color("TabLineSel", "bg")
			or get_hl_color("CursorLineNr", "fg")
			or (is_dark and "#F0C040" or "#C09030"),
	}

	if opts.colors then
		for k, v in pairs(opts.colors) do
			colors[k] = v
		end
	end

	return colors
end

return M
