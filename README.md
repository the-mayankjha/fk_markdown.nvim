<div align="center">
  <img alt="fk_markdown.nvim banner" width="600" src="banner.png" />
  <p>
    <a href="https://github.com/the-mayankjha/fk_markdown.nvim/stargazers"><img alt="GitHub stars" src="https://img.shields.io/github/stars/the-mayankjha/fk_markdown.nvim?style=social"/></a>
    <a href="https://github.com/the-mayankjha/fk_markdown.nvim/blob/main/LICENSE"><img alt="License: MIT" src="https://img.shields.io/github/license/the-mayankjha/fk_markdown.nvim"/></a>
    <img alt="Neovim 0.9+" src="https://img.shields.io/badge/Neovim-0.9%2B-43f0ad?logo=neovim&logoColor=white"/>
    <img alt="Lua" src="https://img.shields.io/badge/Lua-Lua-2b7489?logo=lua&logoColor=white"/>
  </p>
</div>
A lightweight Neovim plugin for rendering and customizing Markdown elements with flexible Lua configuration. Provides beautiful, customizable rendering of headers, code blocks, tables, callouts, lists, and more.



## ✨ Features

<div align="center" style="margin: 30px 0;">
  <img alt="fk_markdown.nvim features showcase" width="80%" src="feature.png" />
</div>

- 🎨 **Fully customizable** — Configure every element with highlight groups, sizes, and styles
- ⚡ **Lightweight** — Minimal overhead with efficient rendering
- 🔧 **Per-element configuration** — Separate config docs for each Markdown element
- 📝 **Wide support** — Headers, emphasis, links, tables, code blocks, quotes, callouts, lists, and images
- 🎯 **Treesitter integration** — Enhanced syntax highlighting for code blocks



## 📦 Installation

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'the-mayankjha/fk_markdown.nvim',
  config = function()
    require('fk_markdown').setup({
      -- configuration here (see examples below)
    })
  end
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'the-mayankjha/fk_markdown.nvim'
```

Then in your `init.lua`:

```lua
require('fk_markdown').setup({
  -- configuration here
})
```

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'the-mayankjha/fk_markdown.nvim',
  config = function()
    require('fk_markdown').setup({
      -- configuration here
    })
  end
}
```

### Using [rocks.nvim](https://github.com/nvim-neorocks/rocks.nvim)

```bash
:Rocks install fk_markdown.nvim
```

---

## ⚙️ Quick Setup

Minimal configuration to get started:

```lua
require('fk_markdown').setup({})
```

For a more personalized setup, see the **Feature Configuration** section below.


## 🎨 Feature Configuration

### Headers

Render Markdown headers (#, ##, ###, etc.) with customizable sizes, bold styling, and highlight groups.

<div style="display: flex; gap: 20px; align-items: flex-start; margin-bottom: 20px;">
  <div style="flex: 0 0 45%;">
    <img alt="Headers with icon rendering" width="100%" src="https://github.com/user-attachments/assets/2ff2f9b9-4c31-417d-8f43-77e617cc690f" />
  </div>
  <div style="flex: 1; display: flex; flex-direction: column; justify-content: center;">
    <p align="center">
  <em>Headers with custom styling </em>
</p>
    <div>

**Configuration:**

```lua
require('fk_markdown').setup({
  heading = {
    enabled = true,
    icon = true,
    render_modes = false,
    atx = true,
    setext = true,
    sign = true,

    background = {
        enabled = false,
        font_color = {
            "#1e66f5", "#fe640b", "#40a02b", "#179299", "#8839ef", "#8839ef", 
        },
    },
},

})
```

**Options:**
- `enable` — true or false
  - `icon` — render icon yes or no instead of # headers 
  - `sign` — sign enable yes or no 
  - `hl` — Highlight group name
  - `background.enabled` = render background for header groups
    - `bg_color` = header group background color
    - `font_color` = header group font color


[Full header configuration docs →](doc/configuration/header.md)



### Code Blocks

Render fenced code blocks with syntax highlighting, optional line numbers, borders, and custom gutters.

<div style="display: flex; gap: 20px; align-items: flex-start; margin-bottom: 20px;">
  <div style="flex: 0 0 45%;">
    <img alt="Code blocks with syntax highlighting and borders" width="100%" src="https://github.com/user-attachments/assets/fcd53006-4cbc-46d1-bdc5-f5cc7da41c55" />
  </div>
  <div style="flex: 1; display: flex; flex-direction: column; justify-content: center;">
      <p align="center">
      <em>Code blocks with line numbers and custom styling</em>
      </p>
    <div>

**Configuration:**

```lua
require('fk_markdown').setup({
   code = {
        enabled = true,
        style = 'wide', 
        background = {
            enabled = false,
            color = "#181825",
        },
        padding = {
            top = 1,
            bottom = 0,
            left = 1,
            right = 2,
        },
        border = {
            enabled = true,
            type = dynamic,
            
        },
        title = {
            enabled = true,
            type = dynamic, 
        },
  }
})
```


[Full codeblock configuration docs →](doc/configuration/codeblock.md)


---

### Tables

Render Markdown tables with configurable borders, alignment, and alternating row highlights.

<div style="display: flex; gap: 20px; align-items: flex-start; margin-bottom: 20px;">
  <div style="flex: 0 0 45%;">
    <img alt="Markdown tables with borders and row highlighting" width="100%" src="https://github.com/user-attachments/assets/3706dc15-80e3-4c3b-aece-4042ed55928e" />
  </div>
  <div style="flex: 1; display: flex; flex-direction: column; justify-content: center;">
    <p align="center">
      <em>Tables with borders and alternating row colors</em>
    </p>
    <div>

**Configuration:**

```lua
require('fk_markdown').setup({
  table = {
    border = {
      enable = true,
      style = 'single'  -- 'single', 'double', or 'none'
    },
    align = {
      default = 'left'  -- 'left', 'center', or 'right'
    },
    alternate_rows = true,
  }
})
```

**Options:**
- `border` — Table border configuration
  - `enable` — Toggle borders
  - `style` — Border character style
- `align` — Cell alignment defaults
  - `default` — Default alignment for all cells
- `alternate_rows` — Alternate row background colors (boolean)

[Full table configuration docs →](doc/configuration/table.md)

    </div>
  </div>
</div>

---

### Callouts

Render informational callouts with icons, custom colors, and titles (info, warn, error, success).

<div style="display: flex; gap: 20px; align-items: flex-start; margin-bottom: 20px;">
  <div style="flex: 0 0 45%;">
    <img alt="Callouts with icons and colors" width="100%" src="https://github.com/user-attachments/assets/d81b57b4-cad3-45b3-bc25-f9d1f88438e8" />
  </div>
  <div style="flex: 1; display: flex; flex-direction: column; justify-content: center;">
    <p align="center">
      <em>Callouts for info, warning, error, and success messages</em>
    </p>
    <div>

**Configuration:**

```lua
require('fk_markdown').setup({
quote = {
        enabled = true,
        -- 'compact' = simple left-bar (default render-markdown style)
        -- 'boxy'    = Notion-like container with bg fill + accent bar
        style = 'boxy',
        -- Background fill color (hex or highlight group name).
        -- Set to 'NONE' or omit to disable background fill.
        bg = "NONE",
        -- Foreground / text color override (hex or highlight group name).
        -- If nil, uses the callout's own highlight group color.
        -- nil = use Normal fg (white from colorscheme). Set hex to override.
        fg = "#cad3f5",
        -- Left accent border bar. true = shown (default), false = hidden.
        border = true,
    },

})
```

**Options:**
- `icons` — Emoji/symbols for each callout type
- `highlights` — Highlight group for each callout type
- `border` — Border styling
  - `enable` — Toggle borders around callouts
  - `style` — `'rounded'` or `'square'`

[Full callout configuration docs →](doc/configuration/callout.md)

    </div>
  </div>
</div>

---

### Emphasis (Bold / Italic / Underline)

Customize text emphasis with highlight groups and font features.

<div style="display: flex; gap: 20px; align-items: flex-start; margin-bottom: 20px;">
  <div style="flex: 0 0 45%;">
    <img alt="Bold, italic, and underlined text" width="100%" src="https://github.com/user-attachments/assets/561dd3ee-287e-40cd-8bfd-5eddfe80aa9f" />
  </div>
  <div style="flex: 1; display: flex; flex-direction: column; justify-content: center;">
    <p align="center">
      <em>Text emphasis with custom highlight groups</em>
    </p>
    <div>


---

### Bulleted & Numbered Lists

Customize bullet characters, indentation, and nested list rendering.

<div style="display: flex; gap: 20px; align-items: flex-start; margin-bottom: 20px;">
  <div style="flex: 0 0 45%;">
    <img alt="Bulleted and numbered lists" width="100%" src="https://github.com/user-attachments/assets/205f6f10-0ba4-4e60-9d77-4704bff78354" />
  </div>
  <div style="flex: 1; display: flex; flex-direction: column; justify-content: center;">
    <p align="center">
      <em>Lists with custom bullets and indentation</em>
    </p>
    <div>


---

### Links

Control link styling and enable click/mapping support.

<div style="display: flex; gap: 20px; align-items: flex-start; margin-bottom: 20px;">
  <div style="flex: 0 0 45%;">
    <img alt="Styled links" width="100%" src="https://github.com/user-attachments/assets/45c48f26-09a7-4903-b20d-732fcccf5918" />
  </div>
  <div style="flex: 1; display: flex; flex-direction: column; justify-content: center;">
    <p align="center">
      <em>Links with custom highlighting and decoration</em>
    </p>
    <div>

---

### Blockquotes

Render blockquotes with a vertical bar, custom highlight, and optional author labels.

<div style="display: flex; gap: 20px; align-items: flex-start; margin-bottom: 20px;">
  <div style="flex: 0 0 45%;">
    <img alt="Blockquotes with vertical bar" width="100%" src="https://github.com/user-attachments/assets/87c292d5-1010-4cab-83c3-2f32e710eb92" />
  </div>
  <div style="flex: 1; display: flex; flex-direction: column; justify-content: center;">
    <p align="center">
      <em>Blockquotes with custom styling</em>
    </p>
    <div>



---

### Images

Configure inline image placeholders and optional preview support.

<div style="display: flex; gap: 20px; align-items: flex-start; margin-bottom: 20px;">
  <div style="flex: 0 0 45%;">
    <img alt="Image placeholders" width="100%" src="https://github.com/user-attachments/assets/d856031d-81bf-437b-b295-d78dcdaf4c30" />
  </div>
  <div style="flex: 1; display: flex; flex-direction: column; justify-content: center;">
   <em align="center">
     <em>Image placeholders with custom sizing</em>
   </em>
    <div>


---

## 🚀 Complete Configuration Example

```lua
require('fk_markdown').setup({
heading = {
    enabled = true,
    icon = false,
    render_modes = false,
    atx = true,
    setext = true,
    sign = true,

    icons = {
        '󰲡 ',
        '󰲣 ',
        '󰲥 ',
        '󰲧 ',
        '󰲩 ',
        '󰲫 ',
    },

    background = {
        enabled = false,
         -- Light / pastel Catppuccin-style backgrounds
        bg_color = {
            "#dce7ff", -- H1 — soft blue
            "#ffe4d6", -- H2 — soft peach
            "#e4f3df", -- H3 — soft green
            "#d9f4f0", -- H4 — soft teal
            "#eee4ff", -- H5 — soft mauve
            "#eee4ff", -- H6 — soft mauve
        },

        -- Stronger Catppuccin accent text
        font_color = {
            "#1e66f5", -- H1 Blue
            "#fe640b", -- H2 Peach
            "#40a02b", -- H3 Green
            "#179299", -- H4 Teal
            "#8839ef", -- H5 Mauve
            "#8839ef", -- H6 Mauve
        },
  
    },
},
    code = {
        enabled = true,
        style = 'wide', -- 'wide' or 'compact'
        background = {
            enabled = false,
            color = "#181825",
        },
        padding = {
            top = 1,
            bottom = 0,
            left = 1,
            right = 2,
        },
        border = {
            enabled = true,
            type = dynamic,
            
        },
        title = {
            enabled = true,
            type = dynamic, 
        },
        icon = {
            enabled = true,
            -- Not currently used by renderer, but structurally valid for future
            pill = true,
            pill_style = 'wide',
        },
        info = {
            position = 'left',
        },
    },
    quote = {
        enabled = true,
        -- 'compact' = simple left-bar (default render-markdown style)
        -- 'boxy'    = Notion-like container with bg fill + accent bar
        style = 'boxy',
        -- Background fill color (hex or highlight group name).
        -- Set to 'NONE' or omit to disable background fill.
        bg = "NONE",
        -- Foreground / text color override (hex or highlight group name).
        -- If nil, uses the callout's own highlight group color.
        -- nil = use Normal fg (white from colorscheme). Set hex to override.
        fg = "#cad3f5",
        -- Left accent border bar. true = shown (default), false = hidden.
        border = true,
    },
})
```

---

## 📖 Documentation

For detailed configuration of individual elements, see:

- **[Header Configuration](doc/configuration/header.md)** — Size, bold, highlight groups, and underlines
- **[Table Configuration](doc/configuration/table.md)** — Borders, alignment, and row alternation
- **[Codeblock Configuration](doc/configuration/codeblock.md)** — Line numbers, borders, and gutters
- **[Callout Configuration](doc/configuration/callout.md)** — Icons, highlights, and borders
- **[General Configuration](doc/configuration.md)** — Emphasis, lists, links, images, and quotations

Additional resources:
- **[Custom Handlers](doc/custom-handlers.md)** — Extend rendering with custom Lua functions
- **[Limitations](doc/limitations.md)** — Known limitations and workarounds
- **[Troubleshooting](doc/troubleshooting.md)** — Common issues and solutions

---

## 🔧 Requirements

- Neovim 0.9+
- (Optional) Treesitter for enhanced syntax highlighting in code blocks

---

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. **Adding features** — Create an issue first to discuss the feature
2. **Updating screenshots** — Replace placeholder images in `doc/images/` with real ones
3. **Documentation** — Keep docs updated with configuration changes
4. **Testing** — Test your changes in different terminal emulators and color schemes

To update a screenshot:
1. Take a screenshot of the feature in Neovim
2. Save it to `doc/images/` with the appropriate name (e.g., `headers.png`, `codeblock.png`)
3. Update the filename reference in the README and documentation

---

## 📄 License

Licensed under the MIT License. See LICENSE for details.

---

## 🙏 Acknowledgments

Built with ❤️ for the Neovim community. Thanks to all contributors and users!
