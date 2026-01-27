return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  {
    "coder/claudecode.nvim",
    config = true,
    keys = {
      { "<leader>cc", "<cmd>ClaudeCodeToggle<cr>", desc = "Toggle Claude Code" },
      { "<leader>cf", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude Code" },
      { "<leader>ca", "<cmd>ClaudeCodeSendAccept<cr>", desc = "Accept diff" },
      { "<leader>cd", "<cmd>ClaudeCodeSendReject<cr>", desc = "Reject diff" },
    },
  },

  -- Markdown rendering in terminal
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = { "markdown" },
    opts = {},
  },

  -- Image display (uses Kitty graphics protocol - works with Ghostty)
  {
    "3rd/image.nvim",
    ft = { "markdown", "norg" },
    opts = {
      backend = "kitty",
      integrations = {
        markdown = { enabled = true },
      },
      max_width = 100,
      max_height = 30,
    },
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },
}
