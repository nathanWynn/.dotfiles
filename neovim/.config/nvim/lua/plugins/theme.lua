return {
  "sainnhe/everforest",
  priority = 1000,
  config = function()
    vim.g.everforest_background = 'medium'
    vim.g.everforest_enable_italic = 1
    vim.g.everforest_transparent_background = 2
    vim.cmd('colorscheme everforest')
  end
}
