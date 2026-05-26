local constants = require "custom.constants"
local lazy_utils = require "custom.utils.lazy"
local lazyvim_utils = require "custom.utils.lazyvim"
local lang_utils = require "custom.utils.lang"

-- Install `lazy.nvim` plugin manager
lazy_utils.install()

-- Load `lazy.nvim` keymaps
lazy_utils.load_mappings()

-- Load `LazyVim` if possible
lazyvim_utils.load()

-- Configure and install plugins
require("lazy").setup {
  spec = {
    {
      "folke/lazy.nvim",
      version = "*",
    },
    lazy_utils.find_local_nolazy_spec() or {},
    -- Necessary to import extras from LazyVim
    {
      "LazyVim/LazyVim",
      lazy = false,
      version = false,
      commit = "d72127eb936f7f05d88d4fc316bc7e89080d69d8", -- v15.12.2
      priority = 10000,
      config = function()
        lazyvim_utils.setup()
      end,
    },
    {
      "folke/snacks.nvim",
      priority = 1000,
      lazy = false,
      opts = {},
      -- snacks.picker shells out to these binaries: `fd` for find-file, `rg` for grep
      build = function()
        local deps = { rg = "ripgrep", fd = "fd" }
        local missing = {}
        for bin, pkg in pairs(deps) do
          if vim.fn.executable(bin) == 0 then
            table.insert(missing, pkg)
          end
        end
        if #missing == 0 then
          return
        end
        if vim.fn.executable "brew" == 1 then
          vim.notify("Installing picker deps: " .. table.concat(missing, ", "), vim.log.levels.INFO)
          vim.fn.system(vim.list_extend({ "brew", "install" }, missing))
        else
          vim.notify(
            "snacks.picker needs these on PATH: " .. table.concat(missing, ", "),
            vim.log.levels.WARN
          )
        end
      end,
      config = function(_, opts)
        local notify = vim.notify
        require("snacks").setup(opts)
        -- HACK: restore vim.notify after snacks setup and let noice.nvim take over
        -- this is needed to have early notifications show up in noice history
        if lazy_utils.has "noice.nvim" then
          vim.notify = notify
        end
      end,
    },

    { import = "custom.plugins" },
  },
  defaults = {
    lazy = true,
    version = false,
  },
  dev = {
    path = vim.fn.stdpath "config" .. "/lua",
  },
  ui = {
    size = {
      width = constants.width_fullscreen,
      height = constants.height_fullscreen,
    },
  },
  install = { colorscheme = { "monokai", "habamax" } },
  checker = { enabled = true, notify = false },
  change_detection = { enabled = false },
  performance = {
    rtp = {
      disabled_plugins = lang_utils.list_merge({
        "2html_plugin",
        "bugreport",
        "compiler",
        "ftplugin",
        "getscript",
        "getscriptPlugin",
        "gzip",
        "logipat",
        "matchparen",
        "optwin",
        "rplugin",
        "rrhelper",
        "synmenu",
        "tar",
        "tarPlugin",
        "tohtml",
        "tutor",
        "vimball",
        "vimballPlugin",
        "zip",
        "zipPlugin",
      }, constants.disable_netrw and {
        "netrw",
        "netrwFileHandlers",
        "netrwPlugin",
        "netrwSettings",
      } or {}),
    },
  },
}
