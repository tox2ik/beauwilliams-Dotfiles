local function init()
  require("impatient")
  require("libraries._module")
  require("settings._optimisations")
  require("settings._mappings")
  require("settings._commands")
  require("settings._abbreviations")
  require("settings._theme")
  require("settings._options")
  require("settings._autocmds")
  require("plugins._plugins")
  require("plugins._statusline")
  require("plugins._cmp")
  require("plugins._mason")
  require("plugins._startify")
  require("plugins._telescope")
  require("plugins._treesitter")
  require("plugins._my_terminal")
  require("plugins._nvimtree")
  require("plugins._discord")
  require("plugins._goto-preview")
  require("plugins._nvim-notify")
  require("plugins._hydra")
  require("plugins._aerial")
  require("plugins._symbols-outline")
  require("plugins._dial")
  require("plugins._noice")
  require("lsp._lsp_config")
  return nil
end
init()
return nil
