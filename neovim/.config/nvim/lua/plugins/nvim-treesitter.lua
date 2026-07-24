return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    dependencies = { 'RRethy/nvim-treesitter-endwise' },
    config = function()
      require('nvim-treesitter.configs').setup {
        auto_install = true,
        ensure_installed = { 'ruby', 'lua', 'go', 'vim', 'vimdoc', 'query', 'markdown', 'bash', 'json', 'yaml' },
        highlight = { enable = true },
        indent = { enable = false },
      }
    end,
  },
}
