---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
--[[
    __                     __   _    __
   / /   ____  _________ _/ /  | |  / /___ ___________
  / /   / __ \/ ___/ __ `/ /   | | / / __ `/ ___/ ___/
 / /___/ /_/ / /__/ /_/ / /    | |/ / /_/ / /  (__  )
/_____/\____/\___/\__,_/_/     |___/\__,_/_/  /____/

--]]
local vim = vim
local fn = vim.fn
local api = vim.api
local cwd = vim.loop.cwd
local has_lsp, lsp = pcall(require, "lspconfig")
if not has_lsp then
    return
end
local has_lsp_utils, lsp_utils = pcall(require, "libraries._lsp")
if not has_lsp_utils then
    return
end

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
--[[
   ______                      __     __  _                ____        __  _
  / ____/___  ____ ___  ____  / /__  / /_(_)___  ____     / __ \____  / /_(_)___  ____  _____
 / /   / __ \/ __ `__ \/ __ \/ / _ \/ __/ / __ \/ __ \   / / / / __ \/ __/ / __ \/ __ \/ ___/
/ /___/ /_/ / / / / / / /_/ / /  __/ /_/ / /_/ / / / /  / /_/ / /_/ / /_/ / /_/ / / / (__  )
\____/\____/_/ /_/ /_/ .___/_/\___/\__/_/\____/_/ /_/   \____/ .___/\__/_/\____/_/ /_/____/
                    /_/                                     /_/
--]]
--NOTE: COQ
-- require('plugins._coq') --> We load custom coq init in lua._coq.lua

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
--[[
    __    _____    ____           ______                   ____    _
   / /   / ___/   / __ \         / ____/  ____    ____    / __/   (_)   ____ _   _____
  / /    \__ \   / /_/ /        / /      / __ \  / __ \  / /_    / /   / __ `/  / ___/
 / /___ ___/ /  / ____/        / /___   / /_/ / / / / / / __/   / /   / /_/ /  (__  )
/_____//____/  /_/             \____/   \____/ /_/ /_/ /_/     /_/    \__, /  /____/
                                                                     /____/
--]]
--UI CONFIG ref: https://github.com/neovim/nvim-lspconfig/wiki/UI-customization#change-diagnostic-symbols-in-the-sign-column-gutter

-- FORMATTING
-- async formatting
-- https://www.reddit.com/r/neovim/comments/jvisg5/lets_talk_formatting_again/
vim.lsp.handlers["textDocument/formatting"] = lsp_utils.get_async_format_fn()

-- Diagnostics [NVIM 0.6 only]
vim.diagnostic.config(
    {
        virtual_text = false,
        underline = true,
        float = {
            source = "virtual",
            border = "rounded",
            header = "",
            prefix = ""
        },
        severity_sort = true,
        -- Could be '●', '▎', 'x', '■'
        --[[ virtual_text = {
      prefix = "»",
      spacing = 4,
    }, ]]
        signs = true,
        update_in_insert = false
    }
)

-- Creating a custom user command in 0.7
-- Enable and disable diagnostics decorations
local diagnostics_active = false
vim.api.nvim_create_user_command(
    "Diagnostics",
    function()
        diagnostics_active = not diagnostics_active
        if diagnostics_active then
            vim.diagnostic.show()
        else
            vim.diagnostic.hide()
        end
    end,
    {
        nargs = "*",
        desc = "Toggle neovim lsp in window diagnostics"
    }
)

-- SET DIAG GUTTER SIGNS
local signs = {Error = "✘", Warning = "", Hint = "", Information = ""}
for type, icon in pairs(signs) do
    local hl = "LspDiagnosticsSign" .. type
    vim.fn.sign_define(hl, {text = icon, texthl = hl, numhl = ""})
end

-- DISPLAY LSP DIAGS IN COMMAND LINE
-- vim.cmd [[ autocmd! CursorHold * lua require("libraries._lsp").echo_diagnostics() ]]

-- DISPLAY LSP DIAGS AS POPUP OVERLAY
-- vim.cmd [[autocmd! CursorHold * lua vim.diagnostic.open_float(nil,{focusable=false,scope="cursor"})]]

-- DISPLAY LSP DIAGS AS VIRTUAL LINES
vim.cmd [[autocmd! CursorHold * lua vim.diagnostic.config({ virtual_lines = { only_current_line = true } })]]

--DISPLAY LSP FN SIGNATURE POPUP OVERLAY
vim.cmd [[autocmd InsertCharPre * Lspsaga signature_help]]

--CAPABILITIES
local custom_capabilities = function()
    --[[ NOTE: COQ
	capabilities.textDocument.completion.completionItem.snippetSupport = true
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	local coq = require('coq')
	coq.lsp_ensure_capabilities() ]]
    local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())
    return capabilities
end

-- You will likely want to reduce updatetime which affects CursorHold
-- note: this setting is global and should be set only once
-- vim.o.updatetime = 250
-- vim.cmd [[autocmd! CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]]

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
--[[
    ___   __  __             __       ______                 __  _
   /   | / /_/ /_____ ______/ /_     / ____/_  ______  _____/ /_(_)___  ____
  / /| |/ __/ __/ __ `/ ___/ __ \   / /_  / / / / __ \/ ___/ __/ / __ \/ __ \
 / ___ / /_/ /_/ /_/ / /__/ / / /  / __/ / /_/ / / / / /__/ /_/ / /_/ / / / /
/_/  |_\__/\__/\__,_/\___/_/ /_/  /_/    \__,_/_/ /_/\___/\__/_/\____/_/ /_/

--]]
--When our LSP starts, this is what happens. Completion enabled, set some mappings, print lsp starting message
local custom_attach = function(client, bufnr)
    --> Added client,bufnr works also without, inspo from https://github.com/kuator/nvim/blob/master/lua/plugins/lsp.lua
    -- INITS
    require("plugins._lightbulb") --> CODE ACTION LIGHTBULB
    require("lsp-status").on_attach(client) --> REQUIRED for lsp statusbar current function.. WROTE MY OWN..
    require("lsp_basics").make_lsp_commands(client, bufnr) --> adds commands such as :LspFormat
    require("aerial").on_attach(client)
    -- require('lsp_signature').on_attach(client) --> Signature popups and info
    -- require('virtualtypes').on_attach() -- A Neovim plugin that shows type annotations as virtual text
end

local custom_init = function(server)
    -- DEBUGGING
    -- vim.lsp.set_log_level('debug') --> ENABLE LOGGING, located in ~/.cache
    -- SWAG
    -- print("LSP Started.. Let's get this bread")
    -- vim.notify("Started "..vim.lsp.get_active_clients()[3].config.name..". Let's get this bread!", 2 , { title = "Language Server"})
    vim.notify("Started " .. vim.bo.ft .. " language server. Let's get this bread!", 2, {title = "Language Server"})
end

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
--[[
    __                                                                   ______                   ____    _
   / /   ____ _   ____    ____ _  __  __  ____ _   ____ _  ___          / ____/  ____    ____    / __/   (_)   ____ _   _____
  / /   / __ `/  / __ \  / __ `/ / / / / / __ `/  / __ `/ / _ \        / /      / __ \  / __ \  / /_    / /   / __ `/  / ___/
 / /___/ /_/ /  / / / / / /_/ / / /_/ / / /_/ /  / /_/ / /  __/       / /___   / /_/ / / / / / / __/   / /   / /_/ /  (__  )
/_____/\__,_/  /_/ /_/  \__, /  \__,_/  \__,_/   \__, /  \___/        \____/   \____/ /_/ /_/ /_/     /_/    \__, /  /____/
                       /____/                   /____/                                                      /____/
--]]
--NOTE: The rest of this file deals with language specific configurations
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------

--SERVER INSTALLATION NOTES
--NOTE: VIMLS Installed by lspconfig, copy in .langservers, get it here https://github.com/iamcco/vim-language-server
--NOTE: Must install rust-analyzer first and add it to your path --> kept in .langservers
--curl -L https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-mac -o ~/.local/bin/rust-analyzer
--chmod +x ~/.local/bin/rust-analyzer
-- INSTALL COMMANDS
-- npm i -g vscode-langservers-extracted [installs html,css,json with most up to date from vscode]
-- pip3 install 'python-language-server[all]' - DEPRECATED
-- pipx install 'python-lsp-server[all]'
-- npm i -g typescript typescript-language-server
-- npm i -g bash-language-server
-- npm install -g vim-language-server
-- npm i -g vscode-langservers-extracted
-- npm install -g dockerfile-language-server-nodejs
-- npm install -g vim-language-server
-- cs install metals
-- npm install -g yaml-language-server

local servers = {
    "bashls",
    "cssls",
    "vimls",
    "rust_analyzer",
    "pylsp",
    "dockerls",
    "yamlls",
    "gopls",
    "marksman",
    -- 'solidity_ls'
    "solc"
}

for _, server in ipairs(servers) do
    lsp[server].setup(
        {
            on_attach = custom_attach,
            on_init = custom_init,
            capabilities = custom_capabilities()
        }
    )
end

-- these servers activate even when not in .git repo etc
local servers_rootcwd = {
    "metals",
    "vimls",
    "jsonls"
}

for _, server in ipairs(servers_rootcwd) do
    lsp[server].setup(
        {
            on_attach = custom_attach,
            on_init = custom_init,
            capabilities = custom_capabilities(),
            root_dir = cwd
        }
    )
end

-- LANG CONFS
require("lsp._null") --Null ls, additional formatters, diags and more..
-- require('lsp._solang').setup(custom_attach, custom_init)
require("lsp._lua").setup(custom_attach, custom_init)
require("lsp._html").setup(custom_attach, custom_init, custom_capabilities)
require("lsp._typescript").setup(custom_attach, custom_init)
require("lsp._omnisharp").setup(custom_attach, custom_init)

vim.cmd(
    [[au FileType java lua require('jdtls').start_or_attach({filetypes = {'java'},cmd = {'/Users/admin/.config/nvim/lua/lsp/launch_jdtls.sh', '/Users/admin/workspaces/nvim/eclipse-workspace/' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')},on_init = custom_init, on_attach = custom_attach})]]
) -- NOTE: sets workspace per project..
-- vim.cmd[[au FileType java lua require('jdtls').start_or_attach({cmd = {'launch_jdtls.sh'},on_init = custom_init, on_attach = custom_attach})]]
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
--[[
    ______               __          ____     ____           ______    _     __
   / ____/   ____   ____/ /         / __ \   / __/          / ____/   (_)   / /  ___
  / __/     / __ \ / __  /         / / / /  / /_           / /_      / /   / /  / _ \
 / /___    / / / // /_/ /         / /_/ /  / __/          / __/     / /   / /  /  __/
/_____/   /_/ /_/ \__,_/          \____/  /_/            /_/       /_/   /_/   \___/
--]]
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
--[[
    __  __     __                   ______                 __  _
   / / / /__  / /___  ___  _____   / ____/_  ______  _____/ /_(_)___  ____  _____
  / /_/ / _ \/ / __ \/ _ \/ ___/  / /_  / / / / __ \/ ___/ __/ / __ \/ __ \/ ___/
 / __  /  __/ / /_/ /  __/ /     / __/ / /_/ / / / / /__/ /_/ / /_/ / / / (__  )
/_/ /_/\___/_/ .___/\___/_/     /_/    \__,_/_/ /_/\___/\__/_/\____/_/ /_/____/
            /_/
--]]
--A custom mapper function to make mapping our lsp functions to vim key sequences less verbose
--[[ local mapper = function(mode, key, result)
	api.nvim_buf_set_keymap(0, mode, key, '<cmd>lua ' .. result .. '<cr>', { noremap = true, silent = true })
end ]]

-- NOTE: Below is just some stuff I will keep for review later / found interesting

--Configure the exclusion pattterns
--[[
local exclude_patterns = {
  '**/node_modules/**/*',
  '**/bin/**/*',
  '**/obj/**/*',
  '/tmp/**/*'
}]]

--local configs = require('lspconfig/configs')

--root_dir = vim.loop.cwd

--lsp.sumneko_lua.setup {on_attach = custom_attach,
--root_dir = vim.loop.cwd --Sets global cwd
--}

--handlers = {
--['client/registerCapability'] = function(_, _, _, _)
--return {
--result = nil;
--error = nil;
--}
--end
--}

--another lua config that does not work either
--lsp.sumneko_lua.setup{
--on_attach=custom_attach,
--settings = {
--Lua = {
--runtime = { version = "LuaJIT", path = vim.split(package.path, ';'), },
--completion = { keywordSnippet = "Enable", },
--diagnostics = { enable = true, globals = {
--"vim", "describe", "it", "before_each", "after_each" },
--},
--workspace = {
--library = {
--[fn.expand("$VIMRUNTIME/lua")] = true,
--[fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
--}
--}
--}
--}
--}

--lsp.sumneko_lua.setup{}
--lsp.sumneko_lua.setup{on_attach=custom_attach}

--local function lsp_setup()
--require('completion').on_attach()
--require('diagnostic').on_attach()
--end

--for lsp_key, lsp_settings in pairs({
--[[ NOTE: Normally, more LSPs would go here. ]]
--['jdtls'] = { --------------------------- Java
--['root_dir'] = lsp.util.root_pattern('.git', 'pom.xml', 'build.xml'),
--['init_options'] = {
--['jvm_args'] = {['java.format.settings.url'] = fn.stdpath('config')..'/eclipse-formatter.xml'},
--['workspace'] = fn.stdpath('cache')..'/java-workspaces'
--}
--},
--}) do -- Setup all of the language servers.
--[[ NOTE: Normally, there are more cases being handled. ]]
--local on_attach_setting = lsp_settings.on_attach

--lsp_settings.on_attach = function()
--lsp_setup()
--if on_attach_setting then on_attach_setting() end
--end

--lsp[lsp_key].setup(lsp_settings)
--end

--[[
	/*
	 * Imports
	 */
--]]

--local completion = require('completion')
--local lspconfig  = require('lspconfig')
--local vim = vim
--local vim.fn  = fn

--[[
	/*
	 * Pre-load data
	 */
--]]

--local OS_NAME = vim.loop.os_uname()['sysname']
--local ON_WINDOWS = fn.has('win32') == 1

--local paths = {
--['HOME_DIR'] = ON_WINDOWS and fn.environ()['userprofile']
--or fn.environ()['HOME'],
--['lsp'] = {}
--}
--paths.REPO_DIR = paths.HOME_DIR..'Repos/'
--paths.lsp.LUA  = paths.REPO_DIR..'lua-language-server/'
--paths.lsp.LUA_BIN = ON_WINDOWS and 'lua-language-server.exe' or 'lua-language-server'
--paths.lsp.C_SHARP = paths.HOME_DIR..'.cache/omnisharp-vim/omnisharp-roslyn/'
--paths.lsp.VIM_SCRIPT = paths.REPO_DIR..'vim-language-server/'

--[[
	/*
	 * Config
	 */
--]]

--Configure the diagnostics
--vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
--vim.lsp.diagnostic.on_publish_diagnostics,
--{
--signs = true,
--virtual_text =
--{
--prefix = '‹!›',
--spacing = 1
--},
--}
--)

--Configure the exclusion pattterns
--local exclude_patterns = {
--'**/node_modules/**/*',
--'**/bin/**/*',
--'**/obj/**/*',
--'/tmp/**/*'
--}

--local function setup_lsp() -- † Add chain completion
--local ft = vim.bo.ft

--if not vim.g.completion_chain_complete_list[ft] then
--vim.g.completion_chain_complete_list = vim.tbl_extend('keep',
--vim.g.completion_chain_complete_list,
--{[ft] = vim.g.lsp_chain_complete_list}
--)
--end

--completion.on_attach()
--end -- ‡

--for index, lsp in pairs({
--'bashls', ------------------------------- Bash
--['omnisharp'] = ------------------------- C#
--{ -- †
--['cmd'] = {paths.lsp.C_SHARP..(ON_WINDOWS and 'omnisharp/OmniSharp.exe' or 'run'), '-lsp'},
--['filetypes'] = {'cache', 'cs', 'csproj', 'dll', 'nuget', 'props', 'sln', 'targets'},
--['log_level'] = 2,
--['root_dir'] = lspconfig.util.root_pattern('*.sln'),
--['settings'] =
--{
--['FileOptions'] =
--{
--['ExcludeSearchPatterns'] = exclude_patterns,
--['SystemExcludeSearchPatterns'] = exclude_patterns
--},
--['FormattingOptions'] =
--{
--['EnableEditorConfigSupport'] = true
--},
--['ImplementTypeOptions'] =
--{
--['InsertionBehavior'] = 'WithOtherMembersOfTheSameKind',
--['PropertyGenerationBehavior'] = 'PreferAutoProperties'
--},
--['RenameOptions'] =
--{
--['RenameInComments'] = true,
--['RenameInStrings']  = true,
--['RenameOverloads']  = true
--},
--['RoslynExtensionsOptions'] =
--{
--['EnableAnalyzersSupport'] = true,
--['EnableDecompilationSupport'] = true
--}
--}
--}, -- ‡
--'ccls', --------------------------------- C/C++/Objective-C
--'cssls', -------------------------------- CSS / SCSS / LESS
--'dartls', ------------------------------- Dart
--'gopls', -------------------------------- Go
--'html', --------------------------------- HTML
--['jdtls'] = ----------------------------- Java
--{ -- †
--['root_dir'] = lspconfig.util.root_pattern('.git', 'pom.xml', 'build.xml'),
--['init_options'] =
--{
--['jvm_args'] = {['java.format.settings.url'] = fn.stdpath('config')..'/eclipse-formatter.xml'},
--['workspace'] = fn.stdpath('cache')..'/java-workspaces'
--}
--}, -- ‡
--'jsonls', ------------------------------- JSON
--'julials', ---------------------------- Julia
--['sumneko_lua'] =  ---------------------- Lua
--{ -- †
--['cmd'] = {paths.lsp.LUA..'bin/'..OS_NAME..'/'..paths.lsp.LUA_BIN, '-E', '-W', paths.lsp.LUA..'main.lua'},
--['settings'] =
--{ ['Lua'] =
--{
--['diagnostics'] = {['globals'] = 'vim'},
--['runtime'] =
--{
--['path'] = vim.split(package.path, ';'),
--['version'] = 'LuaJIT',
--},
--['workspace'] =
--{ ['library'] =
--{
--[fn.expand '$VIMRUNTIME/lua'] = true,
--[fn.expand '$VIMRUNTIME/lua/vim/lsp'] = true
--}},
--}}
--}, -- ‡
--'pyls_ms', ------------------------------ Python
--'rust_analyzer', ------------------------ Rust
--'sqlls',
--'tsserver', ----------------------------- TypeScript
--'texlab', ------------------------------- TeX
--'vimls',
--['vimls'] =  ---------------------------- Vimscript
--{ -- †
--['cmd'] = {'node', paths.lsp.VIM_SCRIPT..'out/index.js', "--stdio"},
--}, -- ‡
--'yamlls' -------------------------------- YAML
--}) do -- Setup all of the language servers. †
--local uses_default_config = (type(index) == 'number')

--if uses_default_config then -- Enable the LSP with defaults.
--The `lsp` is an index in this case.
--lspconfig[lsp].setup{['on_attach'] = setup_lsp}
--else -- Use the LSP's configuration.
--local on_attach_setting = lsp.on_attach

--lsp.on_attach = function()
--setup_lsp()
--if on_attach_setting then on_attach_setting() end
--end

--lspconfig[index].setup(lsp)
--end
--end -- ‡

----------LINTER/DIAG INSPO
-- maybe switch to efm-language-server in the future
--[[  nvim_lsp.diagnosticls.setup{
    filetypes={'javascript', 'python', 'markdown'},
    init_options = {
      linters = {
        flake8 = {
          command = get_python_tool('flake8');
          args = {'--stdin-display-name'; '%filepath'; '-'};
          sourceName = 'flake8';
          debounce = 250;
          formatLines = 1;
          formatPattern = {'^[^:]+:(\\d+):((\\d+):)?\\s+(.+)$';
          {line = 1; column = 3; message = 4}};
          rootPatterns = {''};
        },
        eslint = {
          command = './node_modules/.bin/eslint',
          rootPatterns = {'.git'},
          debounce = 100,
          args = {
            '--stdin',
            '--stdin-filename',
            '%filepath',
            '--format',
            'json'
          },
          sourceName = 'eslint',
          parseJson = {
            errorsRoot = '[0].messages',
            line = 'line',
            column = 'column',
            endLine = 'endLine',
            endColumn = 'endColumn',
            message = '${message} [${ruleId}]',
            security = 'severity'
          },
          securities = {
            [2] = 'error',
            [1] = 'warning',
          },
        },
        markdownlint = {
          command = 'markdownlint',
          rootPatterns = { '.git' },
          isStderr = true,
          debounce = 100,
          args = { '--stdin' },
          offsetLine = 0,
          offsetColumn = 0,
          sourceName = 'markdownlint',
          securities = {
            undefined = 'hint'
          },
          formatLines = 1,
          formatPattern = {
            '^.*:(\\d+)\\s+(.*)$',
            {
              line = 1,
              column = -1,
              message = 2,
            }
          }
        },
      },
      filetypes = {
        javascript = 'eslint',
        python = 'flake8',
        markdown = 'markdownlint',
      },
      formatters = {
        prettier = {
          command = "./node_modules/.bin/prettier",
          args = {"--stdin-filepath" ,"%filepath", '--single-quote', '--print-width 120'}
        }
      },
      formatFiletypes = {
        javascript = "prettier"
      },
    }
  }

  -- doesn't work, somehow
  nvim_lsp.angularls.setup{
    on_attach = on_attach
  }
end--]]

--[[
       __
      / /___ __   ______ _
 __  / / __ `/ | / / __ `/
/ /_/ / /_/ /| |/ / /_/ /
\____/\__,_/ |___/\__,_/
--]]

--[[ require'lspconfig'.java_language_server.setup{
    on_attach = custom_attach,
    on_init = custom_init,
    root_dir = cwd,
    cmd = "~/.config/nvim/.langservers/java-language-server/dist/lang_server_mac.sh",
    -- capabilities = Custom_capabilities()
} ]]

--NOTE: NOT WORKING
--lsp.jdtls.setup{}
--lsp.jdtls.setup {on_attach = custom_attach,
--root_dir = cwd
--}

--configs.jdtls.handlers == {
--['client/registerCapability'] = function(_, _, _, _)
--return {
--result = nil
--error = nil;
--}
--end
--},

--root_dir = lsp.util.root_pattern('.git', 'pom.xml', 'build.xml')

--local root_pattern = lsp.util.root_pattern

--lsp.jdtls.setup{
--root_dir = root_pattern(".git"),
--on_attach = custom_attach,
--capabilities = capabilities,
--}

--local function root_patterns(...)
--local searchers = {}

--for _, patterns in ipairs({...}) do
--local searcher = root_pattern(unpack(patterns))
--searchers[#searchers + 1] = searcher
--end

--return function(startpath)
--for _, searcher in ipairs(searchers) do
--local root = searcher(startpath)
--if root then return root end
--end
--end
--end
