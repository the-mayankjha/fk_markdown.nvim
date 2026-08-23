# ⚙️ Configuration Guide

`fk_markdown.nvim` exposes a clean, modular configuration table. You can pass these options into the `setup()` function to perfectly tailor your Markdown rendering experience.

Below is the complete default structure with explanations for every option.

## 📝 Full Configuration Schema

```lua
require('fk_markdown').setup({
    
    -- ── Headings ──────────────────────────────────────────
    heading = {
        enabled = true,
        
        -- Set to `false` to disable custom icons and show native '#' markers
        icon = true, 
        
        render_modes = false,
        atx = true,
        setext = true,
        sign = true,
        
        -- Custom icons injected before the heading text (H1 to H6)
        icons = {
            '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ',
        },
        
        background = {
            enabled = false,
            
            -- Background fill colors for H1 -> H6
            bg_color = { 
                "#1e1e2e", "#1e1e2e", "#1e1e2e", 
                "#1e1e2e", "#1e1e2e", "#1e1e2e" 
            },
            
            -- Foreground text colors for H1 -> H6
            font_color = { 
                "#f38ba8", "#fab387", "#f9e2af", 
                "#a6e3a1", "#74c7ec", "#cba6f7" 
            }
        },  
    },

    -- ── Code Blocks ───────────────────────────────────────
    code = {
        enabled = true,
        
        -- 'wide' spans the full window width, 'compact' tightly wraps the text
        style = 'wide',
        
        background = {
            enabled = false,
            -- Hex color for the background fill of the code block
            color = "#181825",
        },
        
        -- Granular spacing using virtual lines and inline spacing
        padding = {
            top = 1,    -- Empty lines between top border and code
            bottom = 1, -- Empty lines between code and bottom border
            left = 1,   -- Spaces between left border (│) and code
            right = 2,  -- Extra width added to the right side (best for 'compact' style)
        },
        
        border = {
            enabled = true,
            -- "dynamic" automatically matches the DevIcon color of the language.
            -- "static" forces the border to use the hex color defined below.
            type = "dynamic", 
            color = "#f38ba8",
        },
        
        title = {
            -- Show the language name pill (e.g. "javascript")
            enabled = true,
            -- "dynamic" uses DevIcon color. "static" uses the color defined below.
            -- NOTE: The icon itself always retains its native DevIcon color!
            type = "dynamic", 
            color = "#a6e3a1",
        },
        
        icon = {
            enabled = true,
            pill = true,
            pill_style = 'wide',
        },
        
        info = {
            position = 'left',
        },
    },

    -- ── Quotes / Callouts ─────────────────────────────────
    quote = {
        enabled = true,
        
        -- 'boxy' provides a robust background-filled callout container.
        -- 'compact' provides a standard simple left-bar style.
        style = 'boxy',
        
        -- Left accent bar toggle
        border = true,
        
        -- Quote background color. Set to "NONE" to make it transparent.
        bg = "NONE",
        
        -- Quote text foreground color.
        fg = "#cad3f5",
    }
})
```

## 🎨 Advanced Theming Tips

### Dynamic vs Static Colors
The most powerful feature of `fk_markdown.nvim` is its `type = "dynamic"` engine for code blocks. 

If you leave your border and title types as `dynamic`, `fk_markdown` will query `nvim-web-devicons` for the exact language of the code block you are looking at. A `javascript` block will sport yellow borders, while a `ruby` block will glow red.

If you prefer a cohesive, unified aesthetic across all code blocks regardless of language, simply switch the type to `"static"` and provide your favorite hex colors:

```lua
border = {
    enabled = true,
    type = "static",
    color = "#89b4fa", -- All borders will be solid blue
},
title = {
    enabled = true,
    type = "static",
    color = "#cdd6f4", -- All language text will be standard white
}
```
*Note: Even when you apply static overrides, the language icon (``, ``) will securely retain its colorful DevIcon identity!*

## 🔄 Inherited render-markdown.nvim Options

Because `fk_markdown.nvim` is a specialized wrapper, **all** native `render-markdown.nvim` options are fully supported and seamlessly inherited. 

The custom schemas defined above (`heading`, `code`, `quote`) are carefully intercepted and dynamically translated to our advanced render engine. Any other configuration blocks you pass into `setup()` are natively preserved and passed directly to the core renderer.

Here is a quick overview of all the standard categories you can configure alongside your `fk_markdown` settings:

```lua
require('fk_markdown').setup({
    -- fk_markdown custom overrides
    code = { ... },
    heading = { ... },
    quote = { ... },

    -- Standard render-markdown.nvim options
    anti_conceal = { enabled = true, ... },
    bullet = { enabled = true, icons = { '●', '○', '◆', '◇' }, ... },
    checkbox = { enabled = true, ... },
    dash = { enabled = true, icon = '─', ... },
    pipe_table = { enabled = true, preset = 'none', style = 'full', ... },
    callout = { ... },
    latex = { enabled = true, ... },
    link = { enabled = true, image = '󰥶 ', ... },
    sign = { enabled = true, ... },
    indent = { enabled = false, ... },
    html = { enabled = true, ... },
    
    -- Engine Options
    render_modes = false,
    max_file_size = 10.0,
    debounce = 100,
    win_options = {
        conceallevel = { default = 0, rendered = 3 },
        concealcursor = { default = '', rendered = '' },
    },
    overrides = { ... },
    custom_handlers = { ... },
})
```

For extremely detailed, property-by-property documentation of the inherited elements (like `bullet`, `checkbox`, `pipe_table`, etc.), please refer to the official [render-markdown.nvim README](https://github.com/MeanderingProgrammer/render-markdown.nvim).
