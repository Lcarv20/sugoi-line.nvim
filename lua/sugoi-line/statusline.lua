local M = {}

local last_macro = ""
local macro_timer = nil

local ICONS = {
	mode = "",
	pill_start = "🭪",
	right_sep = "",
	left_sep = "",
	diag_error = "",
	diag_warn = "",
	diag_info = "",
	macro_recorded = "󰐊",
	macro_recording = "󰑊",
	git_branch = "",
	git_add = "",
	git_change = "󱨇",
	git_remove = "",
}

local function hl(name, val)
	vim.api.nvim_set_hl(0, name, val)
end

function M.init_hls(colors)
	hl("StatusLine", { bg = "NONE" })
	hl("StatusLineNC", { bg = "NONE" })

	hl("SlinePill", { bg = colors.pill_bg, fg = colors.fg })
	hl("SlinePillSep", { fg = colors.pill_bg, bg = "NONE" })
	hl("SlinePillStart", { fg = colors.accent, bg = colors.pill_bg })

	hl("SlineModeNormal", { fg = colors.mode_normal, bg = colors.pill_bg, bold = true })
	hl("SlineModeInsert", { fg = colors.mode_insert, bg = colors.pill_bg, bold = true })
	hl("SlineModeVisual", { fg = colors.mode_visual, bg = colors.pill_bg, bold = true })
	hl("SlineModeCmd", { fg = colors.mode_cmd, bg = colors.pill_bg, bold = true })

	hl("SlineDiagError", { fg = colors.diag_error, bg = colors.pill_bg })
	hl("SlineDiagWarn", { fg = colors.diag_warn, bg = colors.pill_bg })
	hl("SlineDiagInfo", { fg = colors.diag_info, bg = colors.pill_bg })

	hl("SlineGitBranch", { fg = colors.git_branch, bg = colors.pill_bg, bold = true })
	hl("SlineGitAdd", { fg = colors.git_add, bg = colors.pill_bg })
	hl("SlineGitChange", { fg = colors.git_change, bg = colors.pill_bg })
	hl("SlineGitRemove", { fg = colors.git_remove, bg = colors.pill_bg })

	hl("SlineFileInfo", { fg = colors.file_info, bg = colors.pill_bg, bold = true })

	hl("SlineMacroRecorded", { fg = colors.macro_recorded, bg = colors.pill_bg, bold = true })
	hl("SlineMacroRecording", { fg = colors.macro_recording, bg = colors.pill_bg, bold = true })
end

local function get_mode()
	local mode_map = {
		n = { ICONS.mode, "SlineModeNormal" },
		i = { ICONS.mode, "SlineModeInsert" },
		v = { ICONS.mode, "SlineModeVisual" },
		V = { ICONS.mode, "SlineModeVisual" },
		["\22"] = { ICONS.mode, "SlineModeVisual" },
		c = { ICONS.mode, "SlineModeCmd" },
		t = { ICONS.mode, "SlineModeNormal" },
	}
	local m = mode_map[vim.fn.mode()] or { ICONS.mode, "SlineModeNormal" }
	return string.format(
		"%%#SlinePillStart#%s %%#%s#%s %%#SlinePillSep#%s",
		ICONS.pill_start, m[2], m[1], ICONS.right_sep
	)
end

local function get_location()
	local line_count = vim.fn.line("$")
	local percent = line_count > 0 and math.floor(vim.fn.line(".") * 100 / line_count) or 0
	return string.format(
		" %%#SlinePillSep#%s%%#SlinePill#%%l:%%c  %d%%%%%%#SlinePillSep#%s",
		ICONS.left_sep, percent, ICONS.right_sep
	)
end

local function get_diagnostics()
	local counts = vim.diagnostic.count(0)
	if vim.tbl_isempty(counts) then
		return ""
	end

	local parts = {}
	if counts[vim.diagnostic.severity.ERROR] then
		table.insert(parts, string.format("%%#SlineDiagError#%s %d", ICONS.diag_error, counts[vim.diagnostic.severity.ERROR]))
	end
	if counts[vim.diagnostic.severity.WARN] then
		table.insert(parts, string.format("%%#SlineDiagWarn#%s %d", ICONS.diag_warn, counts[vim.diagnostic.severity.WARN]))
	end
	if counts[vim.diagnostic.severity.INFO] then
		table.insert(parts, string.format("%%#SlineDiagInfo#%s %d", ICONS.diag_info, counts[vim.diagnostic.severity.INFO]))
	end

	if #parts == 0 then
		return ""
	end
	return string.format(
		" %%#SlinePillSep#%s%%#SlinePill#%s%%#SlinePillSep#%s",
		ICONS.left_sep, table.concat(parts, " "), ICONS.right_sep
	)
end

local function get_lsp_status()
	local status = vim.ui.progress_status()
	if status == "" then
		return ""
	end
	return string.format(
		" %%#SlinePillSep#%s%%#SlinePill#%s%%#SlinePillSep#%s",
		ICONS.left_sep, status, ICONS.right_sep
	)
end

local function make_pill(content)
	return string.format(
		" %%#SlinePillSep#%s%%#SlinePill#%s%%#SlinePillSep#%s",
		ICONS.left_sep, content, ICONS.right_sep
	)
end

local function get_macros()
	local recording_register = vim.fn.reg_recording()
	local recorded_register = vim.fn.reg_recorded()
	local pills = {}

	if recorded_register ~= "" and recording_register == "" then
		last_macro = recorded_register
	end

	if last_macro ~= "" and recording_register ~= last_macro then
		table.insert(pills, make_pill(string.format("%%#SlineMacroRecorded#%s ", ICONS.macro_recorded) .. last_macro))
	end

	if recording_register ~= "" then
		table.insert(pills, make_pill(string.format("%%#SlineMacroRecording#%s ", ICONS.macro_recording) .. recording_register))
	end

	return table.concat(pills, " ")
end

local function get_git()
	local dict = vim.b.gitsigns_status_dict

	if not dict or type(dict) ~= "table" then
		return ""
	end

	local parts = {}
	local branch = dict.head or dict.branch
	if branch and branch ~= "" then
		table.insert(parts, string.format("%%#SlineGitBranch#%s ", ICONS.git_branch) .. branch)
	end
	if dict.added and dict.added > 0 then
		table.insert(parts, string.format("%%#SlineGitAdd#%s ", ICONS.git_add) .. dict.added)
	end
	if dict.changed and dict.changed > 0 then
		table.insert(parts, string.format("%%#SlineGitChange#%s ", ICONS.git_change) .. dict.changed)
	end
	if dict.removed and dict.removed > 0 then
		table.insert(parts, string.format("%%#SlineGitRemove#%s ", ICONS.git_remove) .. dict.removed)
	end

	if #parts == 0 then
		return ""
	end
	return string.format(
		" %%#SlinePillSep#%s%%#SlinePill#%s%%#SlinePillSep#%s",
		ICONS.left_sep, table.concat(parts, " "), ICONS.right_sep
	)
end

local function get_file_info(colors)
	local file = vim.fn.expand("%:t")
	if file == "" then
		return ""
	end

	local icon = ""
	local icon_hl = "SlinePill"
	local ok, devicons = pcall(require, "nvim-web-devicons")
	if ok then
		local i, hl_group = devicons.get_icon(file, vim.fn.expand("%:e"), { default = true })
		if i then
			icon = i
			if hl_group then
				local hl_def = vim.api.nvim_get_hl(0, { name = hl_group, link = false })
				if hl_def and hl_def.fg then
					local fg = string.format("#%06x", hl_def.fg)
					hl("SlineIcon_" .. hl_group, { fg = fg, bg = colors.pill_bg })
					icon_hl = "SlineIcon_" .. hl_group
				end
			end
		end
	end

	return string.format(
		" %%#SlinePillSep#%s%%#%s#%s  %%#SlineFileInfo#%s%%#SlinePillSep#%s",
		ICONS.left_sep, icon_hl, icon, file, ICONS.right_sep
	)
end

function M.render()
	local config = require("sugoi-line").config
	local colors = require("sugoi-line.colors").extract(config)
	M.init_hls(colors)
	local parts = {}
	local function add(part)
		if part ~= "" then
			table.insert(parts, part)
		end
	end
	add(get_mode())
	add(get_location())
	add(get_diagnostics())
	add(get_lsp_status())
	table.insert(parts, "%=")
	add(get_macros())
	table.insert(parts, "%=")
	add(get_file_info(colors))
	add(get_git())
	return table.concat(parts, " ")
end

function M.setup()
	vim.opt.statusline = "%!v:lua.require'sugoi-line.statusline'.render()"

	vim.api.nvim_create_autocmd("RecordingEnter", {
		callback = function()
			if macro_timer then
				macro_timer:stop()
				macro_timer = nil
			end
			vim.cmd("redrawstatus")
		end,
	})

	vim.api.nvim_create_autocmd("RecordingLeave", {
		callback = function()
			last_macro = vim.fn.reg_recorded()
			if macro_timer then
				macro_timer:stop()
			end
			macro_timer = vim.loop.new_timer()
			if macro_timer then
				macro_timer:start(10000, 0, vim.schedule_wrap(function()
					last_macro = ""
					macro_timer = nil
					vim.cmd("redrawstatus")
				end))
			end
			vim.cmd("redrawstatus")
		end,
	})
end

return M
