local status, jdtls = pcall(require, 'jdtls')
if not status then
  return
end

-- Setup Workspace
local home = os.getenv 'HOME'
local workspace_path = home .. '/.local/share/nvim-kickstart/jdtls-workspace/'
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspace_dir = workspace_path .. project_name

-- Setup Capabilities
local extendedClientCapabilities = jdtls.extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

-- Setup Testing and Debugging
local bundles = {}
local mason_path = vim.fn.glob(vim.fn.stdpath 'data' .. '/mason/')
vim.list_extend(bundles, vim.split(vim.fn.glob(mason_path .. 'packages/java-test/extension/server/*.jar'), '\n'))
vim.list_extend(
  bundles,
  vim.split(
    vim.fn.glob(mason_path .. 'packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar'),
    '\n'
  )
)

-- See `:help vim.lsp.start_client` for an overview of the supported `config` options.
local config = {
  cmd = {
    -- 💀
    'java',

    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xmx1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens',
    'java.base/java.util=ALL-UNNAMED',
    '--add-opens',
    'java.base/java.lang=ALL-UNNAMED',
    '-javaagent:' .. home .. '/.local/share/nvim-kickstart/mason/packages/jdtls/lombok.jar',

    -- 💀
    '-jar',
    vim.fn.glob(home .. '/.local/share/nvim-kickstart/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar'),

    -- 💀
    '-configuration',
    home .. '/.local/share/nvim-kickstart/mason/packages/jdtls/config_linux',

    -- 💀
    -- See `data directory configuration` section in the README
    '-data',
    workspace_dir,
  },

  -- 💀
  -- This is the default if not provided, you can remove it. Or adjust as needed.
  -- One dedicated LSP server & client will be started per unique root_dir
  root_dir = require('jdtls.setup').find_root { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' },

  -- Here you can configure eclipse.jdt.ls specific settings
  -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
  -- for a list of options
  settings = {
    java = {
      eclipse = {
        downloadSources = true,
      },
      configuration = {
        updateBuildConfiguration = 'interactive',
        runtimes = {
          {
            name = 'JavaSE-11',
            path = home .. '/.asdf/installs/java/openjdk-11.0.2',
          },
          {
            name = 'JavaSE-17',
            path = home .. '/.asdf/installs/java/openjdk-17.0.2',
          },
          {
            name = 'JavaSE-21',
            path = home .. '/.asdf/installs/java/openjdk-21.0.2',
          },
        },
      },
      maven = {
        downloadSources = true,
      },
      referencesCodeLens = {
        enabled = true,
      },
      implementationsCodeLens = {
        enabled = true,
      },
      references = {
        includeDecompiledSources = true,
      },
      inlayHints = {
        parameterNames = {
          enabled = 'all', -- literals, all, none
        },
      },
      format = {
        insertSpaces = true,
        tabSize = 4,
      },
    },
    signatureHelp = { enabled = true },
    extendedClientCapabilities = extendedClientCapabilities,
  },

  -- Language server `initializationOptions`
  -- You need to extend the `bundles` with paths to jar files
  -- if you want to use additional eclipse.jdt.ls plugins.
  --
  -- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
  --
  -- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
  init_options = {
    bundles = bundles,
  },
}

config['on_attach'] = function(_, _)
  local _, _ = pcall(vim.lsp.codelens.refresh)
  require('jdtls').setup_dap { hotcodeeplace = 'auto' }
  local status_ok, jdtls_dap = pcall(require, 'jdtls.dap')
  if status_ok then
    jdtls_dap.setup_dap_main_class_configs()
  end
end

vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
  pattern = { '*.java' },
  callback = function()
    local _, _ = pcall(vim.lsp.codelens.refresh)
  end,
})

-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
require('jdtls').start_or_attach(config)

vim.keymap.set('n', '<leader>co', "<Cmd>lua require('jdtls').organize_imports()<CR>", { desc = '[O]rganize Imports' })

vim.keymap.set('n', 'gs', function()
  require('jdtls').super_implementation()
end, { desc = '[G]oto [S]uper' })

vim.keymap.set('n', 'gS', function()
  require('jdtls.tests').goto_subjects()
end, { desc = 'Goto Subjects' })

vim.keymap.set('n', '<leader>cxv', "<Cmd>lua require('jdtls').extract_variable()<CR>", { desc = 'Extract [V]ariable' })
vim.keymap.set('n', '<leader>cxc', "<Cmd>lua require('jdtls').extract_constant()<CR>", { desc = 'Extract [C]onstant' })
vim.keymap.set('n', '<leader>cxm', "<Cmd>lua require('jdtls').extract_method(true)<CR>", { desc = 'Extract [M]ethod' })

vim.keymap.set('n', '<leader>tt', function()
  require('jdtls.dap').test_class()
end, { desc = 'Run All [T]est' })

vim.keymap.set('n', '<leader>tr', function()
  require('jdtls.dap').test_nearest_method()
end, { desc = '[R]un Nearest Test' })

vim.keymap.set('n', '<leader>tT', function()
  require('jdtls.dap').pick_test()
end, { desc = 'Run [T]est' })
