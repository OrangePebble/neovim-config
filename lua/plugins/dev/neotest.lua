return {
  "nvim-neotest/neotest",
  version = "5.9", -- Newest version can't find the "neotest-vim-test" module.
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim", -- https://github.com/nvim-neotest/neotest/issues/361
    "nvim-treesitter/nvim-treesitter",
    { "nvim-neotest/neotest-vim-test", dependencies = { "vim-test/vim-test" } },
  },
  config = function()
    -- Defaults: https://github.com/nvim-neotest/neotest/blob/deadfb1af5ce458742671ad3a013acb9a6b41178/lua/neotest/config/init.lua#L159
    require("neotest").setup({
      adapters = {
        -- Adapter for most languages
        -- For unavailable languages or more functionality for some languages, look at:
        --  https://github.com/nvim-neotest/neotest#supported-runners
        require("neotest-vim-test")({
          ignore_file_types = {},
        }),
      },
    })
  end
}
