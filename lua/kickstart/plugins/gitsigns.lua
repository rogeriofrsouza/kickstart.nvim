-- See `:help gitsigns` to understand what the configuration keys do
return {
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '┃' },
        change = { text = '┃' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
        untracked = { text = '┆' },
      },
      on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end

        -- Navigation
        map('n', ']h', function()
          if vim.wo.diff then
            vim.cmd.normal { ']h', bang = true }
          else
            gitsigns.nav_hunk 'next'
          end
        end, 'Next hunk')

        map('n', '[h', function()
          if vim.wo.diff then
            vim.cmd.normal { '[h', bang = true }
          else
            gitsigns.nav_hunk 'prev'
          end
        end, 'Prev hunk')

        -- Actions
        map('n', '<leader>ghs', gitsigns.stage_hunk, 'Stage hunk')
        map('n', '<leader>ghr', gitsigns.reset_hunk, 'Reset hunk')
        map('v', '<leader>ghs', function()
          gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, 'Stage hunk')
        map('v', '<leader>ghr', function()
          gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, 'Reset hunk')

        map('n', '<leader>ghS', gitsigns.stage_buffer, 'Stage buffer')
        map('n', '<leader>ghu', gitsigns.undo_stage_hunk, 'Undo stage hunk')
        map('n', '<leader>ghR', gitsigns.reset_buffer, 'Reset buffer')
        map('n', '<leader>ghp', gitsigns.preview_hunk, 'Preview hunk')

        map('n', '<leader>ghb', function()
          gitsigns.blame_line { full = true }
        end, 'Blame line')
        map('n', '<leader>ghB', gitsigns.toggle_current_line_blame, 'Toggle line blame')

        map('n', '<leader>ghd', gitsigns.diffthis, 'Diff this')
        map('n', '<leader>ghD', function()
          gitsigns.diffthis '~'
        end, 'Diff this ~')

        -- Text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', 'Gitsigns select hunk')
      end,
    },
  },
}
