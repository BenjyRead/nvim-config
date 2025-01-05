--:%y to yank whole file

-- Disable Ctrl+Z closing neovim
vim.keymap.set('n', '<C-z>', '<Nop>')

--adding yanked stuff to clipboard automatically
vim.opt.clipboard = 'unnamedplus'

--relative lines
vim.wo.relativenumber = true

--current line is real current line
vim.opt.number = true

-- TODO: reload config

--Map leader key to space

vim.g.mapleader = ' '

--Leader+rtp to add cwd to runtime path
--TODO: check if this works

vim.api.nvim_set_keymap('n', '<Leader>rtp', ':lua vim.o.runtimepath = vim.o.runtimepath .. "," .. vim.fn.getcwd()<CR>',
    { noremap = true, silent = true })

--tab stuff

--NOTE: ChatGPT alleged vscode settings

-- Set tab size to 4 spaces
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4

-- Use spaces instead of tabs
vim.o.expandtab = true

-- Automatically detect indentation (optional)
vim.cmd([[filetype plugin indent on]])

-- Enable smart indentation
vim.o.smartindent = true

-- different tab settings for java files (google-java-format is weird)
vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = { "java" },
    callback = function()
        vim.o.tabstop = 2
        vim.o.shiftwidth = 2
        vim.o.softtabstop = 2
    end,
})

--Expand errors in lsp?
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })

--ctrl+backspace works as intended
-- TODO: doesnt work sometimes (sometimes when words or too big for example sometimes DataIntegrityViolationException doesnt work)

vim.api.nvim_set_keymap('i', '<C-H>', '<C-W>', { noremap = true })

--TODO: autocomplete deletes characters when autocompleting before it

--TODO: add 'end' to lua function automatically

-- Search ignorescase
vim.o.ignorecase = true;

-- fixing tab autocomplete (wildmenu) bindings being unintuitive

vim.cmd('cnoremap <expr> <up> wildmenumode() ? "\\<left>" : "\\<up>"')
vim.cmd('cnoremap <expr> <down> wildmenumode() ? "\\<right>" : "\\<down>"')
vim.cmd('cnoremap <expr> <left> wildmenumode() ? "\\<up>" : "\\<left>"')
vim.cmd('cnoremap <expr> <right> wildmenumode() ? " \\<bs>\\<C-Z>" : "\\<right>"')


--map ctrl+z to undo (u)

-- In normal mode
vim.keymap.set('n', '<C-z>', 'u', { noremap = true, silent = true })

-- In insert mode
vim.keymap.set('i', '<C-z>', '<C-o>u<C-g>u', { noremap = true, silent = true })

-- TODO: stop comments from generating when you press enter at the end of a commented line

--TODO: Ctrl+Forward goes to end of line instead of start of next line

--TODO: home goes to start of first character, not start of line

vim.api.nvim_create_user_command(
-- apparently I have to make this uppercase :(
    'CD',
    function()
        local filedir = vim.fn.expand('%:p:h')
        vim.cmd('lcd ' .. filedir) --NOTE: lcd is local cd, for windows use cd (try cd if doesnt work)
        print(filedir)
    end,
    { desc = 'cd into current file directory' }
)

--map ctrl + s to :w
vim.keymap.set('i', '<C-s>', '<Esc>:w<CR>i', { noremap = true })
vim.keymap.set('n', '<C-s>', ':w<CR>', { noremap = true })


--remove trailing whitespace on write

--Not a clue how this code works

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    pattern = { "*" },
    callback = function()
        local save_cursor = vim.fn.getpos(".")
        pcall(function() vim.cmd [[%s/\s\+$//e]] end)
        vim.fn.setpos(".", save_cursor)
    end,
})

-- unbind middle click to paste from clipboard
vim.api.nvim_set_keymap('n', '<MiddleMouse>', '<Nop>', { noremap = true })


--Ctrl+V for pasting from clipboard (not buffer)
--TODO: doesn't work

-- Insert mode
vim.api.nvim_set_keymap('i', '<C-V>', '<C-R>+', { noremap = false })

-- Normal mode
vim.api.nvim_set_keymap('n', '<C-V>', '"+p', { noremap = false })

-- TODO: Highlight + Tab to indent (sticks to every 4th line)

-- TODO: Highlight + Shift+Tab to unindent (sticks to every 4th line)

-- TODO: On Ctrl+/ (ggc) comment, move cursor as many characters as the comment syntax has (ie: move 2 characters for -- in lua)


--install lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

--plugins
require("lazy").setup({
    {
        "williamboman/mason.nvim"
    },
    {
        'EdenEast/nightfox.nvim',
    },

    -- Some plugins dont need configuration
    'zbirenbaum/copilot.lua',

    {
        "neovim/nvim-lspconfig"
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        opts = {},
    },
    {
        "williamboman/mason-lspconfig.nvim"
    },
    {
        'lewis6991/gitsigns.nvim'
    },
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' }
    },
    {
        "folke/neodev.nvim",
        opts = {}
    },
    {
        "nvim-tree/nvim-web-devicons"
    },
    {
        "romgrk/barbar.nvim",
        dependencies = {
            'lewis6991/gitsigns.nvim',     -- OPTIONAL: for git status
            'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
        },

        init = function() vim.g.barbar_auto_setup = false end,
        opts = {
            animation = true,
            icons = {
                filetype = {
                    enabled = true
                }
            },
        },
    },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require 'nvim-treesitter.install'.prefer_git = false
            require 'nvim-treesitter.install'.compilers = { 'clang', 'gcc' }

            require 'nvim-treesitter.configs'.setup {
                ensure_installed = {
                    "c",
                    "python",
                    "vim",
                    "lua",
                    "rust",
                    "javascript",
                    "java",
                    "sql",
                    "html",
                    "gitignore",
                    "json",
                    "yaml",
                    "dockerfile",
                    "requirements",
                    "kotlin",
                },
                highlight = {
                    enable = true,
                },
            }
        end,
        dependencies = {
            'nvim-treesitter/nvim-treesitter-textobjects',
        }
    },
    {
        'numToStr/Comment.nvim',
        opts = {

        },
        lazy = false,
    },
    {
        "nvim-tree/nvim-tree.lua",
    },
    {
        "nvim-telescope/telescope.nvim",
        --TOOD: add ripgrep
        dependencies = {
            'nvim-lua/plenary.nvim',
        },
    },
    {
        "nvim-telescope/telescope-frecency.nvim",
        config = function()
            require('telescope').load_extension('frecency')
        end,
        dependencies = {
            "nvim-tree/nvim-web-devicons"
        },

    },
    {
        "danymat/neogen",
        config = true,
        --Only stable versions
        version = '*',
    },
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            -- Snippet Engine & its associated nvim-cmp source
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",

            -- source path
            "hrsh7th/cmp-path",

            -- Adds LSP completion capabilities
            "hrsh7th/cmp-nvim-lsp",

            -- Adds buffer completion capabilities
            "hrsh7th/cmp-buffer",

            -- Adds a number of user-friendly snippets
            "rafamadriz/friendly-snippets",
        },
    },
    {
        'stevearc/conform.nvim',
        opts = {},
    },
    {
        --TODO: what does this do idk check it tho
        'mfussenegger/nvim-lint',
    },
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        }
    },
    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        config = true
        -- use opts = {} for passing setup options
        -- this is equalent to setup({}) function
    },
    {
        'mrcjkb/rustaceanvim',
        version = '^4', -- Recommended
        lazy = false,   -- This plugin is already lazy
    },
    -- {
    --     'benlubas/molten-nvim',
    --     dependencies = {
    --         '3rd/image.nvim',
    --         'willothy/wezterm.nvim'
    --     },
    -- },
    {
        'nvim-java/nvim-java',
        dependencies = {
            'nvim-java/lua-async-await',
            'nvim-java/nvim-java-refactor',
            'nvim-java/nvim-java-core',
            'nvim-java/nvim-java-test',
            'nvim-java/nvim-java-dap',
            'MunifTanjim/nui.nvim',
            'neovim/nvim-lspconfig',
            'mfussenegger/nvim-dap',
            {
                'williamboman/mason.nvim',
                opts = {
                    registries = {
                        'github:nvim-java/mason-registry',
                        'github:mason-org/mason-registry',
                    },
                },
            }
        },
        config = function()
            require('java').setup()
        end,
    },
    {
        'stevearc/oil.nvim',
        opts = {},

        -- Optional dependencies
        dependencies = { "nvim-tree/nvim-web-devicons" },
        -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons

        config = function()
            require('oil').setup({
                view_options = {
                    show_parent = true,
                    show_hidden = true,
                }
            })

            vim.api.nvim_set_keymap('n', '<leader>o', '<cmd>Oil<CR>', { noremap = true, silent = true })
        end,
    },
    -- {
    --     'BenjyRead/lsp_lines.nvim',
    --     config = function()
    --         require('lsp_lines').setup()
    --         -- Disable virtual_text since it's redundant due to lsp_lines.
    --         vim.diagnostic.config({
    --             virtual_text = false,
    --         })
    --     end,
    -- },
    {
        dir = "~/Documents/neovim_plugin_stuff/simple-nvim-plugin",
        config = function()
            require('simple-nvim-plugin')
        end,
    },
    --TODO: get markdown editing setup
    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
        -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
        -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {},
    }
})






--TODO: bind something convienient to endline

-- Remap > and < to behave like Tab and Shift-Tab TODO: doesnt work
vim.api.nvim_set_keymap('n', '>', '>>_', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<', '<<_', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '>', '>gv', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<', '<gv', { noremap = true, silent = true })

--Molten (python notebook) keybinds
--TODO: doesnt work
--TODO: better decriptions

-- vim.keymap.set("n", "<leader>mi", ":MoltenInit<CR>",
--     { silent = true, desc = "[M]olten [I]nitialize" })
-- vim.keymap.set("n", "<leader>e", ":MoltenEvaluateOperator<CR>",
--     { silent = true, desc = "run operator selection" })
-- vim.keymap.set("n", "<leader>rl", ":MoltenEvaluateLine<CR>",
--     { silent = true, desc = "evaluate line" })
-- vim.keymap.set("n", "<leader>rr", ":MoltenReevaluateCell<CR>",
--     { silent = true, desc = "re-evaluate cell" })
-- vim.keymap.set("v", "<leader>r", ":<C-u>MoltenEvaluateVisual<CR>gv",
--     { silent = true, desc = "evaluate visual selection" })



-- TODO: fedora terminal has a conflict with these alt binds

-- Alt+ -> and Alt+ <- to switch between tabs

--Normal mode

vim.api.nvim_set_keymap('n', '<M-Right>', ':BufferNext<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<M-Left>', ':BufferPrevious<CR>', { noremap = true, silent = true })

--Insert mode
vim.api.nvim_set_keymap('i', '<M-Right>', '<Esc>:BufferNext<CR>i', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<M-Left>', '<Esc>:BufferPrevious<CR>i', { noremap = true, silent = true })

-- Alt+1,2..=9 to switch between tabs (terminal limitation)

for i = 1, 9, 1 do
    x = tostring(i)
    -- Normal mode
    vim.api.nvim_set_keymap('n', '<M-' .. x .. '>', ':BufferGoto ' .. x .. '<CR>', { noremap = true, silent = true })
    -- Insert mode
    vim.api.nvim_set_keymap('i', '<M-' .. x .. '>', '<Esc>:BufferGoto ' .. x .. '<CR>i',
        { noremap = true, silent = true })
end

require('nightfox').setup()

vim.cmd('colorscheme carbonfox')

require('todo-comments').setup()

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`

local cmp = require("cmp")
local luasnip = require("luasnip")

require("luasnip.loaders.from_vscode").lazy_load()
luasnip.config.setup({})

cmp.setup({

    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },

    completion = {
        completeopt = "menu,menuone,noinsert",
    },

    --TODO: not a clue what this does but it's important
    mapping = cmp.mapping.preset.insert({

        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete({}),

        ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        }),

        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
    }),

    sources = {
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer" },
        { name = "path" },
    },

})

require 'nvim-web-devicons'.setup({
    default = true
})

--put all linters here with language
require("lint").linters_by_ft = {
    java = { "checkstyle" },
    rust = { "cargo" },
}

require("conform").setup({
    formatters_by_ft = {
        lua = { "stylua" },
        -- Conform will run multiple formatters sequentially
        python = { "ruff" },
        -- Use a sub-list to run only the first available formatter
        javascript = { { "prettier" } },
        -- sql = {
        --     "sql_formatter",
        -- },
        --TODO: this slows down conform to a halt for some reason
        -- NOTE: might be due to nvim-java/jdtls having a different formatter
        -- java = { "google-java-format" },
    },
    format_on_save = {
        -- These options will be passed to conform.format()
        lsp_fallback = true,
    },
})

-- indent-blankline
require("ibl").setup({
    indent = {
        char = '|',
    },
})

require('gitsigns').setup()


require("Comment").setup({})

--TODO: if copilot prompt is under 3 characters, ignore
require('copilot').setup({

    filetypes = {
        ['.'] = true,
    },

    suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
            accept = '<M-a>',
            --TODO: find a better bind (Alt+Right/Left is used for tab switching)
            -- next = '<M-Right>',
            -- prev = '<M-Left>',
            dismiss = '<M-d>',
        },
    }
})

-- Map Ctrl+/ to toggle Line-comment
-- TODO: Move cursor forward so many spaces after commenting

--Normal mode
vim.keymap.set("n", "<C-_>", function() require('Comment.api').toggle.linewise.current() end,
    { noremap = true, silent = true })

--Insert mode
vim.keymap.set("i", "<C-_>", function() require('Comment.api').toggle.linewise.current() end,
    { noremap = true, silent = true })

--Visual mode
vim.keymap.set("v", "<C-_>", function() require('Comment.api').toggle.linewise.current() end,
    { noremap = true, silent = true })

-- Key mapping for ':Telescope find_files' with leader + space in Normal mode
vim.api.nvim_set_keymap('n', '<Leader><Space>', '<cmd>Telescope find_files<cr>', { noremap = true, silent = true })

-- Key mapping for ':Telescope live_grep' with leader + g in Normal mode (search in files)

vim.api.nvim_set_keymap('n', '<Leader>g', '<cmd>Telescope live_grep<cr>', { noremap = true, silent = true })

-- manually install any LSP that do not require settings
-- NOTE: this is a dictionary in lua
local servers = {
    rust_analyzer = {},
    ts_ls = {},
    html = {},
}

require('lualine').setup {
    options = {
        theme = 'carbonfox',
    }
}

require("mason").setup()

local mason_lspconfig = require("mason-lspconfig")
require("mason-lspconfig").setup({
    -- TODO: idk what vim.tbl_keys does
    ensure_installed = vim.tbl_keys(servers),
})

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
-- TODO: not a clue what this does
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
--  TODO: not a clue what this does
local on_attach = function(_, bufnr)
    -- NOTE: Remember that lua is a real programming language, and as such it is possible
    -- to define small helper and utility functions so you don't have to repeat yourself
    -- many times.
    --
    -- In this case, we create a function that lets us more easily define mappings specific
    -- for LSP related items. It sets the mode, buffer and description for us each time.

    local nmap = function(keys, func, desc)
        if desc then
            desc = "LSP: " .. desc
        end

        vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
    end

    nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
    nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

    nmap("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

    --F12 Go to definition
    nmap("<F12>", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
    vim.keymap.set("i", "<F12>", require("telescope.builtin").lsp_definitions,
        { buffer = bufnr, desc = "LSP: [G]oto [D]efinition" })

    nmap("F12", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

    nmap("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
    nmap("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
    nmap("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
    nmap("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
    nmap("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

    -- See `:help K` for why this keymap
    nmap("K", vim.lsp.buf.hover, "Hover Documentation")
    nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

    -- Lesser used LSP functionality
    nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
    nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
    nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
    nmap("<leader>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, "[W]orkspace [L]ist Folders")

    -- -- Create a command `:Format` local to the LSP buffer
    -- vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
    -- 	vim.lsp.buf.format()
    -- end, { desc = "Format current buffer with LSP" })
    -- vim.keymap.set({ "n", "x" }, "gq", function()
    -- 	vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
    -- end, { desc = "Format the buffer with LSP" })
end




mason_lspconfig.setup_handlers({
    function(server_name)
        require("lspconfig")[server_name].setup({
            --TODO: what do these do
            --TODO: remove overflow problems with long error messages

            capabilities = capabilities,
            on_attach = on_attach,           --Function to be run when LSP connects to buffer
            settings = servers[server_name], --Settings for the LSP (servers is a dictionary defined above)
            -- filetypes = (servers[server_name].filetypes or {}).filetypes,
        })
    end,
})

-- highlighting multiple files in telescope find files and pressing enter to open them all

local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

local function multiopen(prompt_bufnr)
    local picker = action_state.get_current_picker(prompt_bufnr)
    local multi = picker:get_multi_selection()

    if not vim.tbl_isempty(multi) then
        actions.close(prompt_bufnr)
        for _, j in pairs(multi) do
            if j.path ~= nil then
                local path = vim.fn.fnameescape(j.path)
                if j.lnum ~= nil then
                    vim.cmd(string.format("silent! edit +%d %s", j.lnum, path))
                else
                    vim.cmd(string.format("silent! edit %s", path))
                end
            end
        end
    else
        actions.select_default(prompt_bufnr)
    end
end

require('telescope').setup {
    defaults = {
        mappings = {
            i = {
                ["<CR>"] = multiopen,
            },
            n = {
                ["<CR>"] = multiopen,
            },
        },
    }
}


require('nvim-tree').setup({
    view = {
        width = 40,
        --Bit jarring at first, but doesn't move where the text is
        side = 'right',
    },
    update_focused_file = {
        enable = true,
    },
    renderer = {
        group_empty = true,
    },
})

--TODO: mod.txt uses json tree sitter


-- Ctrl+N to open nvim-tree
vim.api.nvim_set_keymap('n', '<C-n>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-n>', '<Esc>:NvimTreeToggle<CR>i', { noremap = true, silent = true })


--TODO: vim.lsp.diagnostic.config settings

--TODO: Ctrl+w + arrows to change windows instead of hjkl like vim weirdos

-- vim.api.nvim_set_keymap('n', '<C-w><Left>', '<Cmd>wincmd h<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<C-w><Down>', '<Cmd>wincmd j<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<C-w><Up>', '<Cmd>wincmd k<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<C-w><Right>', '<Cmd>wincmd l<CR>', { noremap = true, silent = true })
