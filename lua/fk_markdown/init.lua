local settings = require('fk_markdown.settings')

---@class render.md.Init: render.md.Api
local M = {}

---@class (exact) render.md.Config: render.md.partial.Config, render.md.state.Config
---@field preset render.md.config.Preset
---@field overrides render.md.overrides.Config

---@class (exact) render.md.partial.Config: render.md.base.Config
---@field debounce integer
---@field anti_conceal render.md.anti.conceal.Config
---@field bullet render.md.bullet.Config
---@field callout render.md.callout.Configs
---@field checkbox render.md.checkbox.Config
---@field code render.md.code.Config
---@field dash render.md.dash.Config
---@field document render.md.document.Config
---@field heading render.md.heading.Config
---@field html render.md.html.Config
---@field indent render.md.indent.Config
---@field inline_highlight render.md.inline.highlight.Config
---@field latex render.md.latex.Config
---@field image render.md.image.Config
---@field link render.md.link.Config
---@field padding render.md.padding.Config
---@field paragraph render.md.paragraph.Config
---@field pipe_table render.md.table.Config
---@field quote render.md.quote.Config
---@field render render.md.render.Config
---@field sign render.md.sign.Config
---@field win_options render.md.window.Configs
---@field yaml render.md.yaml.Config

---@class (exact) render.md.state.Config
---@field log_level render.md.log.Level
---@field log_runtime boolean
---@field file_types string[]
---@field max_file_size number
---@field ignore fun(buf: integer): boolean
---@field nested boolean
---@field change_events string[]
---@field restart_highlighter boolean
---@field injections render.md.injection.Configs
---@field patterns render.md.pattern.Configs
---@field on render.md.on.Config
---@field completions render.md.completions.Config
---@field custom_handlers table<string, render.md.Handler>

---@private
---@type boolean
M.initialized = false

---@type render.md.Config
M.default = {
    -- Whether markdown should be rendered by default.
    enabled = true,
    -- Vim modes that will show a rendered view of the markdown file, :h mode(), for all enabled
    -- components. Individual components can be enabled for other modes. Remaining modes will be
    -- unaffected by this plugin.
    render_modes = { 'n', 'c', 't' },
    -- Milliseconds that must pass before updating marks, updates occur.
    -- within the context of the visible window, not the entire buffer.
    debounce = 100,
    -- Pre configured settings that will attempt to mimic various target user experiences.
    -- User provided settings will take precedence.
    -- | obsidian | mimic Obsidian UI                                          |
    -- | lazy     | will attempt to stay up to date with LazyVim configuration |
    -- | none     | does nothing                                               |
    preset = 'none',
    -- The level of logs to write to file: vim.fn.stdpath('state') .. '/fk_markdown.log'.
    -- Only intended to be used for plugin development / debugging.
    log_level = 'error',
    -- Print runtime of main update method.
    -- Only intended to be used for plugin development / debugging.
    log_runtime = false,
    -- Filetypes this plugin will run on.
    file_types = { 'markdown' },
    -- Maximum file size (in MB) that this plugin will attempt to render.
    -- File larger than this will effectively be ignored.
    max_file_size = 10.0,
    -- Takes buffer as input, if it returns true this plugin will not attach to the buffer.
    ignore = function()
        return false
    end,
    -- Whether markdown should be rendered when nested inside markdown, i.e. markdown code block
    -- inside markdown file.
    nested = true,
    -- Additional events that will trigger this plugin's render loop.
    change_events = {},
    -- Whether the treesitter highlighter should be restarted after this plugin attaches to its
    -- first buffer for the first time. May be necessary if this plugin is lazy loaded to clear
    -- highlights that have been dynamically disabled.
    restart_highlighter = false,
    injections = settings.injections.default,
    patterns = settings.patterns.default,
    anti_conceal = settings.anti_conceal.default,
    padding = settings.padding.default,
    latex = settings.latex.default,
    image = settings.image.default,
    on = settings.on.default,
    completions = settings.completions.default,
    heading = settings.heading.default,
    paragraph = settings.paragraph.default,
    code = settings.code.default,
    dash = settings.dash.default,
    document = settings.document.default,
    bullet = settings.bullet.default,
    checkbox = settings.checkbox.default,
    quote = settings.quote.default,
    render = settings.render.default,
    pipe_table = settings.pipe_table.default,
    callout = settings.callout.default,
    link = settings.link.default,
    sign = settings.sign.default,
    inline_highlight = settings.inline_highlight.default,
    indent = settings.indent.default,
    html = settings.html.default,
    win_options = settings.win_options.default,
    overrides = settings.overrides.default,
    custom_handlers = settings.handlers.default,
    yaml = settings.yaml.default,
    preview = settings.preview.default,
}

---@param opts? render.md.UserConfig
function M.setup(opts)
local function translate_opts(user_opts)
    if not user_opts then return {} end
    local rm_opts = vim.deepcopy(user_opts)

    local function resolve_color(val, is_bg)
        if not val or val == 'NONE' then return 'NONE' end
        if val:sub(1, 1) == '#' then return val end
        local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = val, link = false })
        if ok and hl then
            if is_bg and hl.bg then return string.format('#%06x', hl.bg) end
            if not is_bg and hl.fg then return string.format('#%06x', hl.fg) end
        end
        return val
    end

    -- ── Heading ─────────────────────────────────────────────────
    if user_opts.heading then
        local hd = user_opts.heading
        rm_opts.heading.position = 'overlay'
        
        if hd.icon == false then
            rm_opts.heading.icons = {}
        end

        if hd.background then
            local bg_en = hd.background.enabled
            local bgs = hd.background.bg_color or {}
            local fgs = hd.background.font_color or {}
            for i = 1, 6 do
                local fg_val = resolve_color(fgs[i], false)
                local bg_val = bg_en and resolve_color(bgs[i], true) or 'NONE'
                vim.api.nvim_set_hl(0, 'RenderMarkdownH' .. i, { fg = fg_val, bold = true })
                if bg_en then
                    vim.api.nvim_set_hl(0, 'RenderMarkdownH' .. i .. 'Bg', { fg = fg_val, bg = bg_val })
                end
            end
            rm_opts.heading.foregrounds = {
                'RenderMarkdownH1', 'RenderMarkdownH2', 'RenderMarkdownH3',
                'RenderMarkdownH4', 'RenderMarkdownH5', 'RenderMarkdownH6',
            }
            if bg_en then
                rm_opts.heading.backgrounds = {
                    'RenderMarkdownH1Bg', 'RenderMarkdownH2Bg', 'RenderMarkdownH3Bg',
                    'RenderMarkdownH4Bg', 'RenderMarkdownH5Bg', 'RenderMarkdownH6Bg',
                }
            else
                rm_opts.heading.backgrounds = {}
            end
        end
    end

    -- ── Code ────────────────────────────────────────────────────
    if user_opts.code then
        local cd = user_opts.code
        
        -- Normalization of flat structure to new nested structure
        local border = type(cd.border) == 'table' and cd.border or { enabled = cd.border }
        local title = type(cd.title) == 'table' and cd.title or { enabled = cd.lang }
        local icon = type(cd.icon) == 'table' and cd.icon or { enabled = cd.icon }
        local padding = type(cd.padding) == 'table' and cd.padding or {
            top = cd.top_padding,
            bottom = cd.bottom_padding,
            left = cd.left_padding,
            right = cd.right_padding,
        }
        local bg = type(cd.background) == 'table' and cd.background or { enabled = cd.background, color = cd.background_color }

        if cd.enabled == false then
            rm_opts.code.sign = false
            rm_opts.code.width = 'none'
        end

        rm_opts.code.style = 'full'
        rm_opts.code.width = cd.style == 'compact' and 'block' or 'full'
        
        rm_opts.code.border = border.enabled ~= false and 'thin' or 'none'
        
        local border_col = border.color or cd.border_color
        local border_type = border.type or cd.type
        if border_col and border_type ~= 'dynamic' then
            vim.api.nvim_set_hl(0, 'FkMarkdownCodeBorder', { fg = resolve_color(border_col, false) })
            rm_opts.code.fk_border_hl = 'FkMarkdownCodeBorder'
        end

        rm_opts.code.language_name = title.enabled ~= false
        
        local title_col = title.color or cd.text_color
        local title_type = title.type or cd.type
        if title_col and title_type ~= 'dynamic' then
            vim.api.nvim_set_hl(0, 'FkMarkdownCodeText', { fg = resolve_color(title_col, false) })
            rm_opts.code.fk_text_hl = 'FkMarkdownCodeText'
        end

        rm_opts.code.language_icon = icon.enabled ~= false

        rm_opts.code.left_pad       = (padding.left or 0) + 1
        rm_opts.code.right_pad      = padding.right or 1
        rm_opts.code.language_pad   = 2
        rm_opts.code.fk_top_pad     = padding.top or 0
        rm_opts.code.fk_bottom_pad  = padding.bottom or 0
        rm_opts.code.fk_right_pad   = padding.right or 0
        rm_opts.code.min_width      = 80
        -- Transparent language_border so it doesn't overwrite our ╭───╮
        rm_opts.code.language_border = ' '

        if bg.enabled == false then
            rm_opts.code.disable_background = true
        else
            rm_opts.code.disable_background = false
            local bg_color = bg.color or "#181825"
            vim.api.nvim_set_hl(0, 'RenderMarkdownCode', { bg = resolve_color(bg_color, true) })
        end
    end

    -- ── Quote / Callout ─────────────────────────────────────────
    if user_opts.quote then
        local qt = user_opts.quote
        -- Pass boxy-specific fields through untouched so quote.lua can read them
        rm_opts.quote.style      = qt.style or 'compact'
        rm_opts.quote.bg         = resolve_color(qt.bg, true)
        rm_opts.quote.fg         = resolve_color(qt.fg, false)
        rm_opts.quote.bg_enabled = qt.bg ~= nil and qt.bg ~= 'NONE'
        rm_opts.quote.border     = qt.border ~= false
        rm_opts.quote.icon       = qt.icon or '▋'
    end

    -- ── Web Preview ─────────────────────────────────────────────
    if user_opts.preview then
        local pv = user_opts.preview
        rm_opts.preview = type(rm_opts.preview) == 'table' and rm_opts.preview or {}

        -- Handle shorthand boolean syntax_highlight = true | false
        if pv.syntax_highlight == false or pv.syntax == false or pv.highlight == false or pv.code_highlight == false then
            rm_opts.preview.syntax_highlight = { enabled = false }
        elseif pv.syntax_highlight == true or pv.syntax == true or pv.highlight == true or pv.code_highlight == true then
            rm_opts.preview.syntax_highlight = { enabled = true }
        end

        local syn = type(pv.syntax_highlight) == 'table' and pv.syntax_highlight
            or (type(pv.syntax) == 'table' and pv.syntax)
            or (type(pv.highlight) == 'table' and pv.highlight)
            or (type(pv.code) == 'table' and pv.code)

        if syn then
            rm_opts.preview.syntax_highlight = rm_opts.preview.syntax_highlight or {}
            if syn.enabled ~= nil then
                rm_opts.preview.syntax_highlight.enabled = syn.enabled
            end
            if syn.theme ~= nil then
                rm_opts.preview.syntax_highlight.theme = syn.theme
            end
            if syn.colors ~= nil and type(syn.colors) == 'table' then
                rm_opts.preview.syntax_highlight.colors = {}
                for k, v in pairs(syn.colors) do
                    local is_bg = k == 'background' or k == 'bg'
                    rm_opts.preview.syntax_highlight.colors[k] = resolve_color(v, is_bg)
                end
            end
        end

        -- Direct colors table under preview: preview = { colors = { ... } }
        if pv.colors and type(pv.colors) == 'table' then
            rm_opts.preview.syntax_highlight = rm_opts.preview.syntax_highlight or {}
            rm_opts.preview.syntax_highlight.colors = rm_opts.preview.syntax_highlight.colors or {}
            for k, v in pairs(pv.colors) do
                local is_bg = k == 'background' or k == 'bg'
                rm_opts.preview.syntax_highlight.colors[k] = resolve_color(v, is_bg)
            end
        end

        -- LaTeX math rendering in preview
        if pv.latex ~= nil then
            rm_opts.preview.latex = rm_opts.preview.latex or {}
            if type(pv.latex) == 'boolean' then
                rm_opts.preview.latex.enabled = pv.latex
            elseif type(pv.latex) == 'table' then
                if pv.latex.enabled ~= nil then
                    rm_opts.preview.latex.enabled = pv.latex.enabled
                end
                if pv.latex.code_blocks ~= nil then
                    rm_opts.preview.latex.code_blocks = pv.latex.code_blocks
                end
            end
        end
    end

    return rm_opts
end
    -- This handles discrepancies in initialization order of different plugin managers, some
    -- run the plugin directory first (lazy.nvim) while others run setup first (vim-plug).
    -- To support both we want to pickup the last non-empty configuration. This works because
    -- the plugin directory supplies an empty configuration which will be skipped if state
    -- has already been initialized by the user.
    if M.initialized and vim.tbl_count(opts or {}) == 0 then
        return
    end
    M.initialized = true
    local config = M.resolve_config(translate_opts(opts) or {})
    require('fk_markdown.state').setup(config)
    require('fk_markdown.preview.command').init()
end

---@private
---@param user render.md.UserConfig
---@return render.md.Config
function M.resolve_config(user)
    local preset = require('fk_markdown.lib.presets').get(user)
    local config = vim.tbl_deep_extend('force', M.default, preset, user)
    -- section indentation is built to support headings
    if config.indent.enabled then
        config.pipe_table.border_virtual = true
    end
    -- override settings incompatible with neovim version with compatible alternatives
    local compat = require('fk_markdown.lib.compat')
    if config.code.border == 'hide' and not compat.has_11 then
        config.code.border = 'thin'
    end
    -- use lazy.nvim file type configuration if available and no user value is specified
    if not user.file_types then
        local lazy_file_types = require('fk_markdown.lib.env').lazy('ft')
        if #lazy_file_types > 0 then
            config.file_types = lazy_file_types
        end
    end
    return config
end

return setmetatable(M, {
    __index = function(_, key)
        -- Allows API methods to be accessed from top level
        return require('fk_markdown.api')[key]
    end,
})
