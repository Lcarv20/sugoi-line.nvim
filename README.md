# sugoi-line.nvim

A pill-style statusline and tabline for Neovim.

## Requirements

- Neovim 0.10+
- [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) (optional, for file icons)
- [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) (optional, for git info)
- A Nerd Font (required for icons)

## Installation

**[lazy.nvim](https://lazy.folke.io)**

```lua
{
  "Lcarv20/sugoi-line.nvim",
  config = function()
    require("sugoi-line").setup()
  end,
}
```

**[packer.nvim](https://github.com/wbthomason/packer.nvim)**

```lua
use {
  "Lcarv20/sugoi-line.nvim",
  config = function()
    require("sugoi-line").setup()
  end,
}
```

That's it. No configuration required — colors are derived from your current colorscheme automatically.

## Configuration

```lua
require("sugoi-line").setup({
  pill_bg = nil,       -- custom pill background color (auto-detected by default)
  colors = {
    mode_normal = "#f38ba8",
    mode_insert = "#a6e3a1",
    mode_visual = "#89b4fa",
    mode_cmd = "#f5c2e7",
    diag_error = "#f38ba8",
    diag_warn = "#f9e2af",
    diag_info = "#89b4fa",
    git_branch = "#b4befe",
    git_add = "#a6e3a1",
    git_change = "#fab387",
    git_remove = "#f38ba8",
    file_info = "#f5c2e7",
    macro_recording = "#f38ba8",
    macro_recorded = "#a6e3a1",
    accent = "#cba6f7",
    tab_fg = "#706860",
    sel_fg = "#eae6e1",
    sel_bg = "#F0C040",
    logo_fg = "#F0C040",
  },
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
})
```

## Features

### Statusline

- Mode indicator with color-coded pill
- Cursor location (line:column + percentage)
- Diagnostics (errors, warnings, info)
- LSP progress
- Macro recording/recorded indicator
- File name with icon
- Git branch and hunks

### Tabline

- Pill-style tabs with file names
- Tab numbers
- Tab renaming (`<leader>tr`)
- Tab keymaps: `<leader>tn` (new), `<leader>tc` (close), `<leader>tr` (rename)
