return {
  'akinsho/bufferline.nvim',
  version = '*',
  dependencies = { 'nvim-tree/nvim-web-devicons', 'catppuccin/nvim' },
  event = 'VeryLazy',
  config = function()
    require('bufferline').setup {
      options = {
        diagnostics = 'nvim_lsp',
        diagnostics_indicator = function(count, level)
          local icon = level:match 'error' and '󰅚 ' or '󰀪 '
          return ' ' .. icon .. count
        end,
        show_buffer_close_icons = true,
        show_close_icon = false,
        separator_style = 'thin',
        always_show_bufferline = false,
        offsets = {
          {
            filetype = 'snacks_layout_box',
            text = 'Explorer',
            highlight = 'Directory',
            text_align = 'left',
          },
        },
      },
    }
  end,
  keys = {
    { '<S-h>', '<cmd>BufferLineCyclePrev<cr>', desc = 'Prev Buffer' },
    { '<S-l>', '<cmd>BufferLineCycleNext<cr>', desc = 'Next Buffer' },
    { '<leader>bp', '<cmd>BufferLineTogglePin<cr>', desc = 'Pin Buffer' },
    { '<leader>bP', '<cmd>BufferLineGroupClose ungrouped<cr>', desc = 'Close Non-Pinned Buffers' },
    { '<leader>bo', '<cmd>BufferLineCloseOthers<cr>', desc = 'Close Other Buffers' },
    { '<leader>bl', '<cmd>BufferLineCloseRight<cr>', desc = 'Close Buffers to the Right' },
    { '<leader>bh', '<cmd>BufferLineCloseLeft<cr>', desc = 'Close Buffers to the Left' },
    { '<leader>b1', '<cmd>BufferLineGoToBuffer 1<cr>', desc = 'Go to Buffer 1' },
    { '<leader>b2', '<cmd>BufferLineGoToBuffer 2<cr>', desc = 'Go to Buffer 2' },
    { '<leader>b3', '<cmd>BufferLineGoToBuffer 3<cr>', desc = 'Go to Buffer 3' },
    { '<leader>b4', '<cmd>BufferLineGoToBuffer 4<cr>', desc = 'Go to Buffer 4' },
    { '<leader>b5', '<cmd>BufferLineGoToBuffer 5<cr>', desc = 'Go to Buffer 5' },
  },
}
