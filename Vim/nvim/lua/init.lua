require("impatient")
require("settings._mappings")
require("plugins._plugins")
require("settings._theme")
require("settings._options")
require("settings._autocmds")
require("plugins._startify")
require("plugins._hexokinase")
require("plugins._telescope")
require("plugins._treesitter")
require("plugins._nvimtree")
require("plugins._discord")
require("lsp._lsp_config")
local statusline = require("statusline")
statusline.enable = true
statusline.lsp_diagnostics = true
statusline.ale_diagnostics = false
vim.api.nvim_create_autocmd('BufEnter', {
    command = "if winnr('$') == 1 && bufname() == 'NvimTree_' . tabpagenr() | quit | echo 'hello' | endif",
    nested = true,
})

return statusline
