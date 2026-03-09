return {
  {
    'preservim/vimux',
    cmd = { 'VimuxRunCommand', 'VimuxPromptCommand' },
  },
  {
    'tpope/vim-projectionist',
    event = 'VeryLazy',
    keys = {
      { '<leader>a', '<cmd>A<cr>', desc = 'Alternate File' },
      { '<leader>A', '<cmd>AV<cr>', desc = 'Alternate File (vsplit)' },
    },
    config = function()
      -- Rails-specific projections
      vim.g.projectionist_heuristics = {
        ['config/application.rb'] = {
          -- Models -> Model specs
          ['app/models/*.rb'] = {
            alternate = 'spec/models/{}_spec.rb',
            type = 'model',
          },
          ['spec/models/*_spec.rb'] = {
            alternate = 'app/models/{}.rb',
            type = 'spec',
          },
          -- Controllers -> Request specs
          ['app/controllers/*_controller.rb'] = {
            alternate = 'spec/requests/{}_spec.rb',
            type = 'controller',
          },
          ['spec/requests/*_spec.rb'] = {
            alternate = 'app/controllers/{}_controller.rb',
            type = 'spec',
          },
          -- Services -> Service specs
          ['app/services/*.rb'] = {
            alternate = 'spec/services/{}_spec.rb',
            type = 'service',
          },
          ['spec/services/*_spec.rb'] = {
            alternate = 'app/services/{}.rb',
            type = 'spec',
          },
          -- Jobs -> Job specs
          ['app/jobs/*.rb'] = {
            alternate = 'spec/jobs/{}_spec.rb',
            type = 'job',
          },
          ['spec/jobs/*_spec.rb'] = {
            alternate = 'app/jobs/{}.rb',
            type = 'spec',
          },
          -- Mailers -> Mailer specs
          ['app/mailers/*.rb'] = {
            alternate = 'spec/mailers/{}_spec.rb',
            type = 'mailer',
          },
          ['spec/mailers/*_spec.rb'] = {
            alternate = 'app/mailers/{}.rb',
            type = 'spec',
          },
          -- Helpers -> Helper specs
          ['app/helpers/*.rb'] = {
            alternate = 'spec/helpers/{}_spec.rb',
            type = 'helper',
          },
          ['spec/helpers/*_spec.rb'] = {
            alternate = 'app/helpers/{}.rb',
            type = 'spec',
          },
          -- Lib -> Lib specs
          ['lib/*.rb'] = {
            alternate = 'spec/lib/{}_spec.rb',
            type = 'lib',
          },
          ['spec/lib/*_spec.rb'] = {
            alternate = 'lib/{}.rb',
            type = 'spec',
          },
        },
      }
    end,
  },
  {
    'vim-test/vim-test',
    dependencies = { 'preservim/vimux', 'tpope/vim-projectionist' },
    keys = {
      { '<leader>Tn', '<cmd>TestNearest<cr>', desc = 'Test Nearest' },
      { '<leader>Tf', '<cmd>TestFile<cr>', desc = 'Test File' },
      { '<leader>Ts', '<cmd>TestSuite<cr>', desc = 'Test Suite' },
      { '<leader>Tl', '<cmd>TestLast<cr>', desc = 'Test Last' },
      { '<leader>Tv', '<cmd>TestVisit<cr>', desc = 'Test Visit' },
    },
    config = function()
      -- Use vimux (tmux) strategy for running tests
      vim.g['test#strategy'] = 'vimux'

      -- Keep the test pane open between runs
      vim.g['test#preserve_screen'] = 1

      -- Run tests in a 20% height horizontal split below
      vim.g.VimuxHeight = '20'
      vim.g.VimuxOrientation = 'v'

      -- Target the bottom 'runner' pane by title (set by tdl)
      vim.g.VimuxUseNearest = 1
      vim.g.VimuxRunnerName = 'runner'

      -- Use 'p' alias for running RSpec in container (prizepicks-rails)
      vim.g['test#ruby#rspec#executable'] = 'p bundle exec rspec'
    end,
  },
}
