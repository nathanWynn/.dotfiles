return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      highlight_overrides = {
        all = function(colors)
          return {
            TermCursor = { fg = "NONE", bg = "NONE" },
            TermCursorNC = { fg = "NONE", bg = "NONE" },
          }
        end,
      },
      flavour = "frappe", -- latte, frappe, macchiato, mocha
      transparent_background = true, -- disables setting the background color.
      styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
        comments = { "italic" }, -- Change the style of comments
        conditionals = { "italic" },
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
        -- miscs = {}, -- Uncomment to turn off hard-coded styles
      },
      integrations = {
        gitsigns = true,
        copilot = true,
        mason = true,
        indent_blankline = {
          enabled = true,
          scope_color = "frappe", -- catppuccin color (eg. `lavender`) Default: text
          colored_indent_levels = true,
        },
      }
    })

    vim.cmd('colorscheme catppuccin')
  end
}