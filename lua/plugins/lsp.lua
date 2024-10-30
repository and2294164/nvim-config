--return {
--    {'VonHeikemen/lsp-zero.nvim', branch = 'v4.x'},
--    {'neovim/nvim-lspconfig'},
--    {'hrsh7th/cmp-nvim-lsp'},
--    {'hrsh7th/nvim-cmp'},
--    -- Reserve a space in the gutter
--    -- This will avoid an annoying layout shift in the screen
--    config = function()
--        vim.opt.signcolumn = 'yes'
--
--        -- Add cmp_nvim_lsp capabilities settings to lspconfig
--        -- This should be executed before you configure any language server
--        local lspconfig_defaults = require('lspconfig').util.default_config
--        lspconfig_defaults.capabilities = vim.tbl_deep_extend(
--        'force',
--        lspconfig_defaults.capabilities,
--        require('cmp_nvim_lsp').default_capabilities()
--        )
--
--        -- This is where you enable features that only work
--        -- if there is a language server active in the file
--        vim.api.nvim_create_autocmd('LspAttach', {
--            desc = 'LSP actions',
--            callback = function(event)
--                local opts = {buffer = event.buf}
--
--                vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
--                vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
--                vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
--                vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
--                vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
--                vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
--                vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
--                vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
--                vim.keymap.set({'n', 'x'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
--                vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
--            end,
--        })
--    end
--}
return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
    },

    config = function()
        local cmp = require('cmp')
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities())

        require("fidget").setup({})
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                "rust_analyzer",
                "pylyzer",
                "harper_ls"
            },
            handlers = {
                function(server_name) -- default handler (optional)
                    require("lspconfig")[server_name].setup {
                        capabilities = capabilities
                    }
                end,

                zls = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.zls.setup({
                        root_dir = lspconfig.util.root_pattern(".git", "build.zig", "zls.json"),
                        settings = {
                            zls = {
                                enable_inlay_hints = true,
                                enable_snippets = true,
                                warn_style = true,
                            },
                        },
                    })
                    vim.g.zig_fmt_parse_errors = 0
                    vim.g.zig_fmt_autosave = 0

                end,
                ["lua_ls"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.lua_ls.setup {
                        capabilities = capabilities,
                        settings = {
                            Lua = {
                                runtime = { version = "Lua 5.1" },
                                diagnostics = {
                                    globals = { "bit", "vim", "it", "describe", "before_each", "after_each" },
                                }
                            }
                        }
                    }
                end,

                ["harper_ls"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.harper_ls.setup {
                        settings = {
                            ["harper-ls"] = {
                                userDictPath = "~/dict.txt",
                                fileDictPath = "~/.harper/",
                                diagnosticSeverity = "hint",

                                linters = {
                                    spell_check = false,
                                    spelled_numbers = false,
                                    an_a = false,
                                    sentence_capitalization = false,
                                    unclosed_quotes = true,
                                    wrong_quotes = false,
                                    long_sentence = false,
                                    repeated_words = false,
                                    spaces = false,
                                    matcher = false,
                                    correct_number_suffic = false,
                                    multiple_sequential_pronouns = false,
                                    linking_verbs = false,
                                    avoid_curses = false,
                                    terminating_conjunctions = false
                                }
                            }
                        }
                    }
                end
            }

        })

        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                ["<C-Space>"] = cmp.mapping.complete(),
            }),
            sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = 'luasnip' }, -- For luasnip users.
            }, {
                { name = 'buffer' },
            })
        })

        vim.diagnostic.config({
            -- update_in_insert = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })
    end
}
