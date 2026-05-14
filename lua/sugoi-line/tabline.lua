local M = {}

local ICONS = {
	nvim = "  ",
	left_sep = "",
	right_sep = "",
	active_dot = "",
	inactive_dot = "",
}

local function hl(name, val)
	vim.api.nvim_set_hl(0, name, val)
end

local function get_tab_name(handle)
	if not vim.api.nvim_tabpage_is_valid(handle) then
		return "[No Name]"
	end
	local ok, t = pcall(function()
		return vim.t[handle]
	end)
	if ok and t and t.tabname then
		return t.tabname
	end
	local ok2, bufs = pcall(vim.fn.tabpagebuflist, handle)
	if not ok2 or type(bufs) ~= "table" or #bufs == 0 then
		return "[No Name]"
	end
	local ok3, winnr = pcall(vim.fn.tabpagewinnr, handle)
	if not ok3 or winnr == 0 then
		return "[No Name]"
	end
	local buf = bufs[winnr]
	if not buf then
		return "[No Name]"
	end
	local name = vim.fn.bufname(buf)
	if name == "" then
		return "[No Name]"
	end
	return vim.fn.fnamemodify(name, ":t")
end

function M.init_hls(colors)
	hl("TlineFill", { bg = colors.fill_bg })
	hl("TabLineFill", { bg = "NONE" })
	hl("TabLine", { bg = "NONE" })

	hl("TlineTabPill", { fg = colors.tab_fg, bg = colors.pill_bg })
	hl("TlineSelPill", { fg = colors.sel_fg, bg = colors.sel_bg, bold = true })
	hl("TlinePillSep", { fg = colors.pill_bg, bg = "NONE" })
	hl("TlineSelPillSep", { fg = colors.sel_bg, bg = "NONE" })

	hl("TlineLogo", { fg = colors.logo_fg, bg = "NONE" })
end

function M.render()
	local config = require("sugoi-line").config
	local colors = require("sugoi-line.colors").extract(config)
	M.init_hls(colors)

	local parts = {}
	local tabs = vim.api.nvim_list_tabpages()
	local current_handle = vim.api.nvim_get_current_tabpage()
	local show_tab_number = config.tabline.show_tab_number ~= false

	table.insert(parts, string.format("%%#TlineLogo# %s ", ICONS.nvim))

	for _, handle in ipairs(tabs) do
		local tabnr = vim.api.nvim_tabpage_get_number(handle)
		local is_current = handle == current_handle
		local tab_hl = is_current and "TlineSelPill" or "TlineTabPill"
		local sep_hl = is_current and "TlineSelPillSep" or "TlinePillSep"
		local name = get_tab_name(handle)
		local dot = is_current and ICONS.active_dot or ICONS.inactive_dot
		local num = show_tab_number and string.format(" %d ", tabnr) or ""

		table.insert(parts, string.format(
			"%%#%s#%s%%%dT%%#%s#%s%s %%#%s#%s%%T",
			sep_hl, ICONS.left_sep, tabnr, tab_hl, dot, num .. name, sep_hl, ICONS.right_sep
		))
	end

	table.insert(parts, "%#TlineFill#%T")
	return table.concat(parts, " ")
end

function M.setup(opts)
	opts = opts or {}

	vim.o.showtabline = 1
	vim.o.tabline = "%!v:lua.require'sugoi-line.tabline'.render()"

	vim.keymap.set("n", "<leader>t", "", { desc = "tabs" })
	vim.keymap.set("n", "<leader>tn", ":tabnew<cr>", { desc = "new" })
	vim.keymap.set("n", "<leader>tc", ":tabclose<cr>", { desc = "close" })
	vim.keymap.set("n", "<leader>tr", function()
		vim.ui.input({ prompt = "Tab name: " }, function(input)
			if not input then
				return
			end
			local handle = vim.api.nvim_get_current_tabpage()
			if input ~= "" then
				vim.t[handle].tabname = input
			else
				vim.t[handle].tabname = nil
			end
			vim.cmd("redrawtabline")
		end)
	end, { desc = "rename" })
end

return M
