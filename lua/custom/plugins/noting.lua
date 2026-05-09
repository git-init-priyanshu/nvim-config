local nvim_utils = require "custom.utils.nvim"
local keymaps_utils = require "custom.utils.keymaps"
local constants = require "custom.constants"

return {
  {
    "zk-org/zk-nvim",
    lazy = not constants.in_zk,
    main = "zk",
    event = {
      "BufReadPre " .. vim.fn.expand "~" .. "/Sync/zk/*.md",
      "BufNewFile " .. vim.fn.expand "~" .. "/Sync/zk/*.md",
    },
    keys = {
      {
        "<leader>z",
        "",
        desc = "zk",
        mode = { "n", "v" },
      },

      {
        "<leader>zn",
        "<Cmd>lua require('custom.utils-plugins.zk').new()<CR>",
        desc = "New",
      },
      {
        "<leader>zf",
        "<Cmd>ZkNotes<CR>",
        desc = "Picker", -- notes picker
      },
      {
        "<leader>zm",
        "<Cmd>lua require('custom.utils-plugins.zk').open_main()<CR>",
        desc = "Main",
      },
      {
        "<leader>zb",
        "<Cmd>ZkBacklinks<CR>",
        desc = "Pick Zk Backlinks",
      },
      {
        "<leader>zL",
        "<Cmd>ZkLinks<CR>",
        desc = "Pick Zk Links",
      },
      {
        "<leader>zd",
        "<Cmd>ZkNew { dir = 'journal' }<CR>",
        desc = "New (Daily)",
      },
      {
        "<leader>zl",
        "<Cmd>lua require('custom.utils-plugins.zk').open_last_daily()<CR>",
        desc = "Last (Daily)",
      },
    },
    init = function()
      nvim_utils.autocmd({ "BufEnter" }, {
        group = nvim_utils.augroup "load_zk_mappings",
        pattern = "*.md",
        callback = function(event)
          if require("zk.util").notebook_root(vim.fn.expand "%:p") ~= nil then
            local opts = { noremap = true, buffer = event.buf }
            keymaps_utils.map(
              "n",
              "<leader>zN",
              "<Cmd>lua require('custom.utils-plugins.zk').new(true)<CR>",
              "New (Same Directory)",
              opts
            )
            -- TODO: ZkNewFromTitleSelection
            -- TODO: ZkNewFromContentSelection
            keymaps_utils.map("n", "gf", "<Cmd>lua vim.lsp.buf.definition()<CR>", "Open Link Under Cursor", opts)
            keymaps_utils.map("n", "<CR>", "<Cmd>lua vim.lsp.buf.definition()<CR>", "Open Link Under Cursor", opts)
            keymaps_utils.map("n", "<leader>zi", "<Cmd>ZkInsertLink<CR>", "Insert Link", opts)
          end
        end,
      })
    end,
    opts = {
      picker = "snacks_picker",
    },
  },

  {
    "opdavies/toggle-checkbox.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<leader>mx",
        "<Cmd>ToggleCheckbox<CR>",
        desc = "Toggle checkbox",
      },
    },
    opts = {},
    config = function()
      require "toggle-checkbox"
    end,
  },
}
