return {
  'nvim-telescope/telescope-file-browser.nvim',
  dependencies = { 'nvim-telescope/telescope.nvim', 'nvim-lua/plenary.nvim' },
  keys = {
    {
      '<space>fB',
      ':Telescope file_browser<CR>',
      desc = 'File Browser (root dir)',
      { noremap = true },
    },
    {
      '<space>fb',
      ':Telescope file_browser path=%:p:h select_buffer=true<CR>',
      desc = 'File Browser (cwd)',
      { noremap = true },
    },
  },
}
