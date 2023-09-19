{
  description = "A simple Neovim configuration with plugins";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Configure nvim with plugins and custom settings
        nvim = pkgs.neovim.override {
          configure = {
            customRC = ''
              " set
              lua << EOF
                vim.opt.nu = true
                vim.opt.relativenumber = true

                vim.opt.tabstop = 2
                vim.opt.softtabstop = 2
                vim.opt.shiftwidth = 2
                vim.opt.expandtab = true

                vim.opt.smartindent = true

                vim.opt.wrap = false

                vim.opt.swapfile = false
                vim.opt.backup = false
                vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
                vim.opt.undofile = true

                vim.opt.hlsearch = false
                vim.opt.incsearch = true

                vim.opt.termguicolors = true

                vim.opt.scrolloff = 8
                vim.opt.signcolumn = "yes"
                vim.opt.isfname:append("@-@")

                vim.opt.updatetime = 50

                vim.opt.colorcolumn = "80"

                vim.g.mapleader = " "
              EOF
              
              " Settings for catppuccin
              lua << EOF
                function ColorMyPencils(color)
                  color = color or "catppuccin-mocha"
                  vim.cmd.colorscheme(color)
                  vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
                  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
                end

                ColorMyPencils()
              EOF
              
              " Settings for fugitive
              lua << EOF
                vim.keymap.set('n', '<leader>gs', vim.cmd.Git)
              EOF

              " Settings for harpoon
              lua << EOF
                local mark = require("harpoon.mark")
                local ui = require("harpoon.ui")

                vim.keymap.set('n', '<leader>a', mark.add_file)
                vim.keymap.set('n', '<C-e>', ui.toggle_quick_menu)

                vim.keymap.set('n', '<C-h>', function() ui.nav_file(1) end)
                vim.keymap.set('n', '<C-t>', function() ui.nav_file(2) end)
                vim.keymap.set('n', '<C-n>', function() ui.nav_file(3) end)
                vim.keymap.set('n', '<C-s>', function() ui.nav_file(4) end)
              EOF

              " Settings for lsp
              lua << EOF
                local lsp = require('lsp-zero')

                lsp.preset('recommended')

                lsp.ensure_installed({
                  'tsserver',
                  'eslint',
                  'rust_analyzer',
                })

                local cmp = require('cmp')
                local cmp_select = { behavior = cmp.SelectBehavior_Select }
                local cmp_mappings = lsp.defaults.cmp_mappings({
                  ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                  ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                  ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                  ['<C-Space>'] = cmp.mapping.complete(),
                })

                lsp.set_preferences({
                  sign_icons = { }
                })

                lsp.setup_nvim_cmp({
                  mapping = cmp_mappings
                })

                lsp.on_attach(function(client, bufnr)
                  local opts = { buffer = bufnr, remap = false }
                  vim.keymap.set('n', 'gd', function() vim.lsp.buf.definition() end, opts)
                  vim.keymap.set('n', 'K', function() vim.lsp.buf.hover() end, opts)
                  vim.keymap.set('n', '<leader>vws', function() vim.lsp.buf.workspace_symbol() end, opts)
                  vim.keymap.set('n', '<leader>vd', function() vim.diagnostic.open_float() end, opts)

                  vim.keymap.set('n', '[d', function() vim.diagnostic.goto_next() end, opts)
                  vim.keymap.set('n', ']d', function() vim.diagnostic.goto_prev() end, opts)
                  vim.keymap.set('n', '<leader>vca', function() vim.lsp.buf.code_action() end, opts)
                  vim.keymap.set('n', '<leader>vrr', function() vim.lsp.buf.references() end, opts)
                  vim.keymap.set('n', '<leader>vrn', function() vim.lsp.buf.rename() end, opts)
                  vim.keymap.set('n', '<C-h>', function() vim.lsp.buf.signature_help() end, opts)
                end)

                lsp.setup()
              EOF

              " Settings for Undotree
              lua << EOF
                vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)
              EOF

              " Settings for telescope-nvim
              lua << EOF
                local builtin = require('telescope.builtin')
                vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
                vim.keymap.set('n', '<C-p>', builtin.git_files, {})
                vim.keymap.set('n', '<leader>ps', function()
                  builtin.grep_string({ search = vim.fn.input("Grep > ") })
                end)
              EOF

              " Settings for lualine
              lua << EOF
                require('lualine').setup()
              EOF
              
              " Settings for undotree
              lua << EOF
                vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)
              
              EOF
              
              " Settings for treesitter
              lua << EOF
                require'nvim-treesitter.configs'.setup {
                  highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                  },
                }
              EOF
              
              " Settings for metals
              lua << EOF
                -------------------------------------------------------------------------------
                -- These are example settings to use with nvim-metals and the nvim built-in
                -- LSP. Be sure to thoroughly read the `:help nvim-metals` docs to get an
                -- idea of what everything does. Again, these are meant to serve as an example,
                -- if you just copy pasta them, then should work,  but hopefully after time
                -- goes on you'll cater them to your own liking especially since some of the stuff
                -- in here is just an example, not what you probably want your setup to be.
                --
                -- Unfamiliar with Lua and Neovim?
                --  - Check out https://github.com/nanotee/nvim-lua-guide
                --
                -- The below configuration also makes use of the following plugins besides
                -- nvim-metals, and therefore is a bit opinionated:
                --
                -- - https://github.com/hrsh7th/nvim-cmp
                --   - hrsh7th/cmp-nvim-lsp for lsp completion sources
                --   - hrsh7th/cmp-vsnip for snippet sources
                --   - hrsh7th/vim-vsnip for snippet sources
                --
                -- - https://github.com/wbthomason/packer.nvim for package management
                -- - https://github.com/mfussenegger/nvim-dap (for debugging)
                -------------------------------------------------------------------------------
                local api = vim.api
                local cmd = vim.cmd
                local map = vim.keymap.set

                ----------------------------------
                -- PLUGINS -----------------------
                ----------------------------------
                cmd([[packadd packer.nvim]])
                require("packer").startup(function(use)
                  use({ "wbthomason/packer.nvim", opt = true })

                  use({
                    "hrsh7th/nvim-cmp",
                    requires = {
                      { "hrsh7th/cmp-nvim-lsp" },
                      { "hrsh7th/cmp-vsnip" },
                      { "hrsh7th/vim-vsnip" },
                    },
                  })
                  use({
                    "scalameta/nvim-metals",
                    requires = {
                      "nvim-lua/plenary.nvim",
                      "mfussenegger/nvim-dap",
                    },
                  })
                end)

                ----------------------------------
                -- OPTIONS -----------------------
                ----------------------------------
                -- global
                vim.opt_global.completeopt = { "menuone", "noinsert", "noselect" }

                -- LSP mappings
                map("n", "gD",  vim.lsp.buf.definition)
                map("n", "K",  vim.lsp.buf.hover)
                map("n", "gi", vim.lsp.buf.implementation)
                map("n", "gr", vim.lsp.buf.references)
                map("n", "gds", vim.lsp.buf.document_symbol)
                map("n", "gws", vim.lsp.buf.workspace_symbol)
                map("n", "<leader>cl", vim.lsp.codelens.run)
                map("n", "<leader>sh", vim.lsp.buf.signature_help)
                map("n", "<leader>rn", vim.lsp.buf.rename)
                map("n", "<leader>f", vim.lsp.buf.format)
                map("n", "<leader>ca", vim.lsp.buf.code_action)

                map("n", "<leader>ws", function()
                  require("metals").hover_worksheet()
                end)

                -- all workspace diagnostics
                map("n", "<leader>aa", vim.diagnostic.setqflist)

                -- all workspace errors
                map("n", "<leader>ae", function()
                  vim.diagnostic.setqflist({ severity = "E" })
                end)

                -- all workspace warnings
                map("n", "<leader>aw", function()
                  vim.diagnostic.setqflist({ severity = "W" })
                end)

                -- buffer diagnostics only
                map("n", "<leader>d", vim.diagnostic.setloclist)

                map("n", "[c", function()
                  vim.diagnostic.goto_prev({ wrap = false })
                end)

                map("n", "]c", function()
                  vim.diagnostic.goto_next({ wrap = false })
                end)

                -- Example mappings for usage with nvim-dap. If you don't use that, you can
                -- skip these
                map("n", "<leader>dc", function()
                  require("dap").continue()
                end)

                map("n", "<leader>dr", function()
                  require("dap").repl.toggle()
                end)

                map("n", "<leader>dK", function()
                  require("dap.ui.widgets").hover()
                end)

                map("n", "<leader>dt", function()
                  require("dap").toggle_breakpoint()
                end)

                map("n", "<leader>dso", function()
                  require("dap").step_over()
                end)

                map("n", "<leader>dsi", function()
                  require("dap").step_into()
                end)

                map("n", "<leader>dl", function()
                  require("dap").run_last()
                end)

                -- completion related settings
                -- This is similiar to what I use
                local cmp = require("cmp")
                cmp.setup({
                  sources = {
                    { name = "nvim_lsp" },
                    { name = "vsnip" },
                  },
                  snippet = {
                    expand = function(args)
                      -- Comes from vsnip
                      vim.fn["vsnip#anonymous"](args.body)
                    end,
                  },
                  mapping = cmp.mapping.preset.insert({
                    -- None of this made sense to me when first looking into this since there
                    -- is no vim docs, but you can't have select = true here _unless_ you are
                    -- also using the snippet stuff. So keep in mind that if you remove
                    -- snippets you need to remove this select
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    -- I use tabs... some say you should stick to ins-completion but this is just here as an example
                    ["<Tab>"] = function(fallback)
                      if cmp.visible() then
                        cmp.select_next_item()
                      else
                        fallback()
                      end
                    end,
                    ["<S-Tab>"] = function(fallback)
                      if cmp.visible() then
                        cmp.select_prev_item()
                      else
                        fallback()
                      end
                    end,
                  }),
                })

                ----------------------------------
                -- LSP Setup ---------------------
                ----------------------------------
                local metals_config = require("metals").bare_config()

                -- Example of settings
                metals_config.settings = {
                  showImplicitArguments = true,
                  excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
                }

                -- *READ THIS*
                -- I *highly* recommend setting statusBarProvider to true, however if you do,
                -- you *have* to have a setting to display this in your statusline or else
                -- you'll not see any messages from metals. There is more info in the help
                -- docs about this
                -- metals_config.init_options.statusBarProvider = "on"

                -- Example if you are using cmp how to make sure the correct capabilities for snippets are set
                metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()

                -- Debug settings if you're using nvim-dap
                local dap = require("dap")

                dap.configurations.scala = {
                  {
                    type = "scala",
                    request = "launch",
                    name = "RunOrTest",
                    metals = {
                      runType = "runOrTestFile",
                      --args = { "firstArg", "secondArg", "thirdArg" }, -- here just as an example
                    },
                  },
                  {
                    type = "scala",
                    request = "launch",
                    name = "Test Target",
                    metals = {
                      runType = "testTarget",
                    },
                  },
                }

                metals_config.on_attach = function(client, bufnr)
                  require("metals").setup_dap()
                end

                -- Autocmd that will actually be in charging of starting the whole thing
                local nvim_metals_group = api.nvim_create_augroup("nvim-metals", { clear = true })
                api.nvim_create_autocmd("FileType", {
                  -- NOTE: You may or may not want java included here. You will need it if you
                  -- want basic Java support but it may also conflict if you are using
                  -- something like nvim-jdtls which also works on a java filetype autocmd.
                  pattern = { "scala", "sbt", "java" },
                  callback = function()
                    require("metals").initialize_or_attach(metals_config)
                  end,
                  group = nvim_metals_group,
                })
              EOF

              " remaps
              lua << EOF
                vim.g.mapleader = " "

                -- open project file browser
                vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

                -- move selection up and down
                vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
                vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

                -- move next line to end of current line. keep cursor in place!
                vim.keymap.set('n', 'J', 'mzJ`z')

                -- half page jumping. keep cursor in middle of screen
                vim.keymap.set('n', '<C-d>', '<C-d>zz')
                vim.keymap.set('n', '<C-u>', '<C-u>zz')

                -- keep search terms in the middle
                vim.keymap.set('n', 'n', 'nzzzv')
                vim.keymap.set('n', 'N', 'Nzzzv')

                -- preserve clipboard when pasting over selection
                vim.keymap.set('x', '<leader>p', '"_dp')

                -- yank into system clipboard
                vim.keymap.set('n', '<leader>y', '"+y')
                vim.keymap.set('v', '<leader>y', '"+y')
                vim.keymap.set('n', '<leader>Y', '"+Y')

                -- deletes to void register
                vim.keymap.set('n', '<leader>d', '"_d')
                vim.keymap.set('v', '<leader>d', '"_d')

                -- disable capital Q
                vim.keymap.set('n', 'Q', '<noop>')

                vim.keymap.set('n', '<C-f>', '<cmd>silent !tmux neww tmux-sessionizer<CR>')
                vim.keymap.set('n', '<leader>f', function()
                  vim.lsp.buf.format()
                end)

                vim.keymap.set('n', '<C-k>', '<cmd>cnext<CR>zz')
                vim.keymap.set('n', '<C-j>', '<cmd>cprev<CR>zz')
                vim.keymap.set('n', '<leader>k', '<cmd>lnext<CR>zz')
                vim.keymap.set('n', '<leader>j', '<cmd>lprev<CR>zz')

                vim.keymap.set('n', '<leader>s', ":%s/\\<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>")
                vim.keymap.set('n', '<leader>x', "<cmd>!chmod +x %<CR>", { silent = true })

                -- quick open packer config
                vim.keymap.set('n', '<leader>vpp', '<cmd>e ~/.dotfiles/nvim/lua/pseudoble/packer.lua<CR>');
                vim.keymap.set('n', '<leader><leader>', function() vim.cmd("so") end)



              EOF
            '';
            packages.myVimPackage = with pkgs.vimPlugins; {
              start = [
                catppuccin-nvim
                nvim-tree-lua
                vim-startify
                vim-nix
                packer-nvim
                vim-tmux-navigator
                telescope-nvim
                plenary-nvim
                nvim-treesitter
                nvim-treesitter-parsers.typescript
                nvim-treesitter-parsers.lua
                nvim-treesitter-parsers.rust
                nvim-treesitter-parsers.scala
                nvim-treesitter-parsers.ocaml
                nvim-treesitter-parsers.ocamllex
                nvim-treesitter-parsers.javascript
                nvim-treesitter-parsers.java
                nvim-treesitter-parsers.nix
                nvim-treesitter-parsers.yaml
                nvim-treesitter-parsers.xml
                undotree
                vim-fugitive
                nvim-lspconfig
                nvim-cmp
                cmp-nvim-lsp
                lualine-nvim
                nvim-dap
                nvim-metals
                copilot-vim
                harpoon
                luasnip
                lsp-zero-nvim
                nvim-web-devicons
              ];
            };
          };
        };
      in
      {
        packages = {
          nvim = nvim;
          default = nvim;
        };
        defaultPackage = nvim;
        apps.default = { type = "app"; program = "${nvim}/bin/nvim"; };
      }
    );
}
