local M = {}

M.config = {
	pill_bg = nil,
	colors = {},
	statusline = {
		enable = true,
		globalstatus = true,
		disabled_filetypes = {
			"snacks_picker_list",
			"snacks_picker_input",
			"snacks_layout_box",
			"oil",
			"neo-tree",
			"NvimTree",
			"netrw",
		},
	},
	tabline = {
		enable = true,
		show_tab_number = true,
	},
}

function M.setup(opts)
	opts = opts or {}
	M.config = vim.tbl_deep_extend("force", M.config, opts)

	if M.config.statusline.enable then
		require("sugoi-line.statusline").setup(M.config.statusline)
	end

	if M.config.tabline.enable then
		require("sugoi-line.tabline").setup(M.config.tabline)
	end

	vim.api.nvim_create_autocmd("ColorScheme", {
		callback = function()
			vim.schedule(function()
				local colors = require("sugoi-line.colors").extract(M.config)
				if M.config.statusline.enable then
					require("sugoi-line.statusline").init_hls(colors)
					vim.cmd("redrawstatus")
				end
				if M.config.tabline.enable then
					require("sugoi-line.tabline").init_hls(colors)
					vim.cmd("redrawtabline")
				end
			end)
		end,
	})
end

return M
