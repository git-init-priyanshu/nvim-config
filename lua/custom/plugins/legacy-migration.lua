return {
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit", "Gblame" },
  },

  {
    "mbbill/undotree",
    cmd = { "UndotreeToggle", "UndotreeShow", "UndotreeHide" },
  },

  {
    "pocco81/auto-save.nvim",
    event = { "InsertLeave", "TextChanged" },
    opts = {
      enabled = true,
      execution_message = {
        enabled = false,
      },
    },
  },

  {
    "nvimtools/none-ls-extras.nvim",
    lazy = true,
  },

  {
    "saecki/crates.nvim",
    ft = { "toml" },
    opts = {
      completion = {
        cmp = {
          enabled = true,
        },
      },
    },
  },
}
