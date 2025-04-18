-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Example configs: https://github.com/LunarVim/starter.lvim
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/

-- Map "gl" to move to the end of the line (like $)
-- lvim.keys.normal_mode["gl"] = "$"
-- lvim.keys.visual_mode["gl"] = "$"

-- Map "gh" to move to the beginning of the line (like ^)
-- lvim.keys.normal_mode["gh"] = "^"
-- lvim.keys.visual_mode["gh"] = "^"

-- Use shift h and l for moving to next/previous buffer
lvim.keys.normal_mode["<S-h>"] = ":bprevious<CR>"
lvim.keys.normal_mode["<S-l>"] = ":bnext<CR>"

-- nvimtree appears on the rigth side of the screen
lvim.builtin.nvimtree.setup.view.side = "right"
lvim.builtin.nvimtree.setup.view.width = 45

-- Leader key + - for horizontal split
lvim.builtin.which_key.mappings["-"] = { ":split<CR>", "Horizontal Split" }
-- Leader key + | for vertical split
lvim.builtin.which_key.mappings["|"] = { ":vsplit<CR>", "Vertical Split" }

-- Add ts supprort for the lsp
lvim.lsp.installer.setup.ensure_installed = { "tsserver" }

-- Define lspconfig
local lspconfig = require("lspconfig")

-- Disable tsserver formatting so Prettier can handle it
lspconfig.tsserver.setup({
  on_attach = function(client)
    -- Disable LSP formatting to allow Prettier to handle formatting
    client.server_capabilities.documentFormattingProvider = false
  end,
})

-- Disable pyright formatting so Black can handle it
lspconfig.pyright.setup({
  on_attach = function(client)
    -- Disable LSP formatting to allow Black to handle formatting
    client.server_capabilities.documentFormattingProvider = false
  end,
})

-- Formatter configuration for Prettier and Black
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup({
  {
    -- Use Prettier for these file types
    name = "prettier",
    filetypes = { "javascript", "typescript", "css", "scss", "html", "json", "yaml", "markdown" },
  },
  {
    -- Use Black for Python files
    name = "black",
    filetypes = { "python" },
  },
})

local linters = require "lvim.lsp.null-ls.linters"
linters.setup {
  { name = "flake8" },
  {
    name = "shellcheck",
    args = { "--severity", "warning" },
  },
}

local code_actions = require "lvim.lsp.null-ls.code_actions"
code_actions.setup {
  {
    name = "proselint",
  },
}

-- Enable auto-formatting on save
lvim.format_on_save.enabled = true
vim.opt.wrap = true

-- Autocomplete suggestions
local cmp = require('cmp')

cmp.setup({
  mapping = {
    ['<C-j>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
    ['<C-k>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
    ['<C-Space>'] = cmp.mapping.complete(), -- Trigger suggestions manually
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Confirm the selected suggestion
    ['<Tab>'] = vim.NIL,
    ['<S-Tab>'] = vim.NIL,
  },
})

-- Plugins
lvim.plugins = {
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    version = '*',
    event = 'VeryLazy',
    config = function()
      require("nvim-treesitter.configs").setup({
        textobjects = {
          select = {
            enable = true,

            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,

            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              -- You can optionally set descriptions to the mappings (used in the desc parameter of
              -- nvim_buf_set_keymap) which plugins like which-key display
              ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
              -- You can also use captures from other query groups like `locals.scm`
              ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
            },
            -- You can choose the select mode (default is charwise 'v')
            --
            -- Can also be a function which gets passed a table with the keys
            -- * query_string: eg '@function.inner'
            -- * method: eg 'v' or 'o'
            -- and should return the mode ('v', 'V', or '<c-v>') or a table
            -- mapping query_strings to modes.
            selection_modes = {
              ['@parameter.outer'] = 'v', -- charwise
              ['@function.outer'] = 'V',  -- linewise
              ['@class.outer'] = '<c-v>', -- blockwise
            },
            -- If you set this to `true` (default is `false`) then any textobject is
            -- extended to include preceding or succeeding whitespace. Succeeding
            -- whitespace has priority in order to act similarly to eg the built-in
            -- `ap`.
            --
            -- Can also be a function which gets passed a table with the keys
            -- * query_string: eg '@function.inner'
            -- * selection_mode: eg 'v'
            -- and should return true or false
            include_surrounding_whitespace = true,
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ["<leader>a"] = "@parameter.inner",
          },
          swap_previous = {
            ["<leader>A"] = "@parameter.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            ["]m"] = "@function.outer",
            ["]]"] = { query = "@class.outer", desc = "Next class start" },
            --
            -- You can use regex matching (i.e. lua pattern) and/or pass a list in a "query" key to group multiple queries.
            ["]o"] = "@loop.*",
            -- ["]o"] = { query = { "@loop.inner", "@loop.outer" } }
            --
            -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
            -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
            ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
            ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
          },
          goto_next_end = {
            ["]M"] = "@function.outer",
            ["]["] = "@class.outer",
          },
          goto_previous_start = {
            ["[m"] = "@function.outer",
            ["[["] = "@class.outer",
          },
          goto_previous_end = {
            ["[M"] = "@function.outer",
            ["[]"] = "@class.outer",
          },
          -- Below will go to either the start or the end, whichever is closer.
          -- Use if you want more granular movements
          -- Make it even more gradual by adding multiple queries and regex.
          goto_next = {
            ["]d"] = "@conditional.outer",
          },
          goto_previous = {
            ["[d"] = "@conditional.outer",
          }
        },
      })
    end,
  },
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end
  },
  
  {
    "princejoogie/dir-telescope.nvim",
    -- telescope.nvim is a required dependency
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("dir-telescope").setup({
        -- these are the default options set
        hidden = true,
        no_ignore = false,
        show_preview = true,
        follow_symlinks = false,
      })
      lvim.builtin.which_key.mappings["sd"] = {
        ":GrepInDirectory<CR>",
        "Grep In Directory"
      }
    end,
  },

  {
    "sainnhe/sonokai",
    config = function()
      vim.g.sonokai_style = 'andromeda'
      vim.g.sonokai_better_performance = 1
    end,
  },
  {  
    "loctvl842/monokai-pro.nvim",
    config = function()
      require("monokai-pro").setup({
        transparent_background = false,
        terminal_colors = true,
        devicons = true, -- highlight the icons of `nvim-web-devicons`
        styles = {
          comment = { italic = true },
          keyword = { italic = true }, -- any other keyword
          type = { italic = true }, -- (preferred) int, long, char, etc
          storageclass = { italic = true }, -- static, register, volatile, etc
          structure = { italic = true }, -- struct, union, enum, etc
          parameter = { italic = true }, -- parameter pass in function
          annotation = { italic = true },
          tag_attribute = { italic = true }, -- attribute of tag in reactjs
        },
        filter = "machine", -- classic | octagon | pro | machine | ristretto | spectrum
        -- Enable this will disable filter option
        day_night = {
          enable = false, -- turn off by default
          day_filter = "pro", -- classic | octagon | pro | machine | ristretto | spectrum
          night_filter = "spectrum", -- classic | octagon | pro | machine | ristretto | spectrum
        },
        inc_search = "background", -- underline | background
        background_clear = {
          -- "float_win",
          "toggleterm",
          "telescope",
          -- "which-key",
          "renamer",
          "notify",
          -- "nvim-tree",
          -- "neo-tree",
          -- "bufferline", -- better used if background of `neo-tree` or `nvim-tree` is cleared
        },-- "float_win", "toggleterm", "telescope", "which-key", "renamer", "neo-tree", "nvim-tree", "bufferline"
        plugins = {
          bufferline = {
            underline_selected = false,
            underline_visible = false,
          },
          indent_blankline = {
            context_highlight = "default", -- default | pro
            context_start_underline = false,
          },
        },
        ---@param c Colorscheme
        override = function(c) end,
        ---@param cs Colorscheme
        ---@param p ColorschemeOptions
        ---@param Config MonokaiProOptions
        ---@param hp Helper
        -- override = function(cs: Colorscheme, p: ColorschemeOptions, Config: MonokaiProOptions, hp: Helper),
      })
      end,
  },

  {
    'abecodes/tabout.nvim',
    config = function()
      require('tabout').setup {
        tabkey = '<Tab>',             -- key to trigger tabout, set to an empty string to disable
        backwards_tabkey = '<S-Tab>', -- key to trigger backwards tabout, set to an empty string to disable act_as_tab = true,            -- shift content if tab out is not possible
        act_as_shift_tab = false,     -- reverse shift content if tab out is not possible (if your keyboard/terminal supports <S-Tab>)
        default_tab = '<C-t>',        -- shift default action (only at the beginning of a line, otherwise <TAB> is used)
        default_shift_tab = '<C-d>',  -- reverse shift default action,
        enable_backwards = true,      -- well ...
        completion = false,           -- if the tabkey is used in a completion pum
        tabouts = {
          { open = "'", close = "'" },
          { open = '"', close = '"' },
          { open = '`', close = '`' },
          { open = '(', close = ')' },
          { open = '[', close = ']' },
          { open = '{', close = '}' }
        },
        ignore_beginning = true, --[[ if the cursor is at the beginning of a filled element it will rather tab out than shift the content ]]
        exclude = {} -- tabout will ignore these filetypes
      }
    end,
    dependencies = { -- These are optional
      "nvim-treesitter/nvim-treesitter",
      "L3MON4D3/LuaSnip",
      "hrsh7th/nvim-cmp"
    },
    lazy = true,             -- Set this to true if the plugin is optional
    event = 'InsertCharPre', -- Set the event to 'InsertCharPre' for better compatibility
    priority = 1000,
  },

  {
    "L3MON4D3/LuaSnip",
    keys = function()
      -- Disable default tab keybinding in LuaSnip
      return {}
    end,
  },

  {
    "airblade/vim-gitgutter",
  },

  {
    "f-person/git-blame.nvim",
    event = "VeryLazy",
  },

  {
    "ggandor/leap.nvim",
    config = function()
      local leap = require("leap")
      leap.add_default_mappings()

      -- Map the `s` key for leap in normal and visual modes
      vim.keymap.set({ "n", "x", "o" }, "s", function()
        leap.leap({ target_windows = { vim.fn.win_getid() } })
      end, { desc = "Leap forward to a target" })

      -- Optional: Map `S` for backward leap
      vim.keymap.set({ "n", "x", "o" }, "S", function()
        leap.leap({ backward = true, target_windows = { vim.fn.win_getid() } })
      end, { desc = "Leap backward to a target" })
    end,
    event = "BufReadPost", -- Load the plugin when a buffer is read
    lazy = true, -- Enable lazy loading for performance
    priority = 1000, -- Ensure it loads in a predictable order
  },

  {
    "folke/trouble.nvim",
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      -- {
      --  "<leader>cs",
      --   "<cmd>Trouble symbols toggle focus=false<cr>",
      --   desc = "Symbols (Trouble)",
      -- },
      -- {
      --   "<leader>cl",
      --   "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
      --   desc = "LSP Definitions / references / ... (Trouble)",
      -- },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
  },

  {
    "okuuva/auto-save.nvim",
    version = '^1.0.0',                       -- see https://devhints.io/semver, alternatively use '*' to use the latest tagged release
    cmd = "ASToggle",                         -- optional for lazy loading on command
    event = { "InsertLeave", "TextChanged" }, -- optional for lazy loading on trigger events
    config = function()
      require("auto-save").setup {
        enabled = true,                                  -- start auto-save when the plugin is loaded (i.e. when your package manager loads it)
        trigger_events = {                               -- See :h events
          immediate_save = { "BufLeave", "FocusLost" },  -- vim events that trigger an immediate save
          defer_save = { "InsertLeave", "TextChanged" }, -- vim events that trigger a deferred save (saves after `debounce_delay`)
          cancel_deferred_save = { "InsertEnter" },      -- vim events that cancel a pending deferred save
        },
        -- function that takes the buffer handle and determines whether to save the current buffer or not
        -- return true: if buffer is ok to be saved
        -- return false: if it's not ok to be saved
        -- if set to `nil` then no specific condition is applied
        condition = nil,
        write_all_buffers = false, -- write all buffers when the current one meets `condition`
        noautocmd = false,         -- do not execute autocmds when saving
        lockmarks = false,         -- lock marks when saving, see `:h lockmarks` for more details
        debounce_delay = 2000,     -- delay after which a pending save is executed
        -- log debug messages to 'auto-save.log' file in neovim cache directory, set to `true` to enable
        debug = false,
      }
    end,
  },
}

-- Theme choice
lvim.colorscheme = 'monokai-pro'


