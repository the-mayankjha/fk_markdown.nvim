# 🌟 fk_markdown.nvim

> A highly polished, aesthetically-driven Markdown renderer for Neovim with Notion-like styling and granular customization.

<div align="center">

[![Lua](https://img.shields.io/badge/Lua-5.1+-00007C?style=for-the-badge&logo=lua)](https://www.lua.org)
[![Neovim](https://img.shields.io/badge/Neovim-0.9+-green.svg?style=for-the-badge&logo=neovim)](https://neovim.io)

[Features](#-features) • [Installation](#-installation) • [Configuration](#%EF%B8%8F-configuration) • [Examples](#-examples) • [Troubleshooting](#-troubleshooting)

</div>

---

## 📋 Overview

`fk_markdown.nvim` is a specialized, enhanced reimagining of the fantastic [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim). It provides a premium Markdown rendering experience with sophisticated visual styling, deep customization capabilities, and zero compromise on performance.

Whether you're writing documentation, taking notes, or drafting blog posts in Neovim, `fk_markdown.nvim` transforms raw Markdown into a beautifully rendered document that rivals modern note-taking applications like Notion.

---

## ✨ Features

### 🎯 Core Rendering

- **Beautiful Bounded Code Blocks** – Code blocks render as enclosed terminal-style boxes with elegant Unicode borders (`╭──╮`, `│`, `╰──╯`) and overlay language tabs, not flat backgrounds
- **Dynamic DevIcon Inheritance** – Code block borders and titles automatically inherit colors from `nvim-web-devicons`, matching the language's identity (Python blocks have blue/yellow borders, Rust has orange, JavaScript has yellow, etc.)
- **Notion-Style Callouts** – Blockquotes transform into gorgeous, customizable callout boxes with solid left-accent borders and flexible background options
- **Gradient Headings** – Full control over `H1`–`H6` with custom foreground colors, backgrounds, and indicator icons for visual hierarchy

### 🎨 Customization

- **Absolute Padding Control** – Add virtual blank lines inside code blocks with granular `top`, `bottom`, `left`, and `right` padding configurations
- **Modular Configuration Schema** – A clean, deeply nested configuration system that's logical and easy to maintain
- **Static & Dynamic Color Modes** – Apply language-specific colors automatically (`"dynamic"`) or enforce a cohesive aesthetic with fixed values (`"static"`)
- **Full render-markdown.nvim Compatibility** – All parent options are seamlessly inherited and supported

### ⚡ Performance

- **Efficient Rendering** – Optimized updates tied to visible window changes, not entire buffer re-renders
- **Configurable Debouncing** – Control render loop timing via the `debounce` parameter (default: 100ms)
- **File Size Limits** – Automatic safety limits to prevent performance degradation on massive files

---

## 🚀 Installation

### Prerequisites

- Neovim ≥ 0.9
- `nvim-treesitter` – For syntax highlighting and parsing
- `nvim-web-devicons` – For language-specific icon colors

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "the-mayankjha/fk_markdown.nvim",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        require("fk_markdown").setup({
            -- Your custom configuration here
        })
    end,
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'the-mayankjha/fk_markdown.nvim'

" In your init.vim or init.lua
lua require('fk_markdown').setup({})
```

### Using [packer.nvim](https://github.com/wbthomson/packer.nvim)

```lua
use {
    "the-mayankjha/fk_markdown.nvim",
    requires = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        require("fk_markdown").setup({})
    end,
}
```

---

## ⚙️ Configuration

`fk_markdown.nvim` provides a powerful, nested configuration schema that gives you granular control over how Markdown elements are rendered. Below is the complete default configuration with explanations for every option.

### Quick Start

```lua
require('fk_markdown').setup({
    heading = {
        enabled = true,
        icon = true,
        icons = {
            '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ',
        },
        background = {
            enabled = false,
            bg_color = { 
                "#1e1e2e", "#1e1e2e", "#1e1e2e", 
                "#1e1e2e", "#1e1e2e", "#1e1e2e" 
            },
            font_color = { 
                "#f38ba8", "#fab387", "#f9e2af", 
                "#a6e3a1", "#74c7ec", "#cba6f7" 
            }
        },  
    },
    code = {
        enabled = true,
        style = 'wide',
        background = {
            enabled = false,
            color = "#181825",
        },
        padding = {
            top = 1,
            bottom = 1,
            left = 1,
            right = 2,
        },
        border = {
            enabled = true,
            type = "dynamic",
            color = "#f38ba8",
        },
        title = {
            enabled = true,
            type = "dynamic",
            color = "#a6e3a1",
        },
        icon = {
            enabled = true,
            pill = true,
            pill_style = 'wide',
        },
    },
    quote = {
        enabled = true,
        style = 'boxy',
        border = true,
        bg = "NONE",
        fg = "#cad3f5",
    }
})
```

### Detailed Options

For an exhaustive guide to all configuration options, including advanced color theming, inherited `render-markdown.nvim` settings, and property-by-property documentation, see **[CONFIGURATION.md](./CONFIGURATION.md)**.

#### Key Concepts

**Dynamic vs. Static Colors**

The most powerful feature is dynamic color inheritance. When you set `type = "dynamic"` for code block borders or titles, `fk_markdown` queries `nvim-web-devicons` for the exact language of each code block. A JavaScript block will automatically sport yellow borders, Python gets blue, Rust gets orange, etc.

For a cohesive, unified aesthetic across all code blocks regardless of language, simply switch to `type = "static"` and provide your own hex colors:

```lua
code = {
    border = {
        enabled = true,
        type = "static",
        color = "#89b4fa",  -- All borders are solid blue
    },
    title = {
        enabled = true,
        type = "static",
        color = "#cdd6f4",  -- All language text is white
    }
}
```

---

## 📖 Examples

### Example 1: Minimal Setup (Out of the Box)

```lua
require('fk_markdown').setup({})
```

This uses all sensible defaults: beautiful bounded code blocks, Notion-style callouts, and gradient headings.

### Example 2: Catppuccin Theme Integration

```lua
require('fk_markdown').setup({
    heading = {
        enabled = true,
        icon = true,
        background = {
            enabled = true,
            bg_color = { 
                "#1e1e2e", "#1e1e2e", "#1e1e2e", 
                "#1e1e2e", "#1e1e2e", "#1e1e2e" 
            },
            font_color = { 
                "#f38ba8", "#fab387", "#f9e2af", 
                "#a6e3a1", "#74c7ec", "#cba6f7" 
            }
        },
    },
    code = {
        enabled = true,
        style = 'wide',
        background = {
            enabled = true,
            color = "#11111b",
        },
        border = {
            enabled = true,
            type = "dynamic",
        },
        padding = {
            top = 1,
            bottom = 1,
            left = 2,
            right = 2,
        },
    },
    quote = {
        enabled = true,
        style = 'boxy',
        bg = "#313244",
        fg = "#cad3f5",
    }
})
```

### Example 3: Compact & Minimal

```lua
require('fk_markdown').setup({
    code = {
        enabled = true,
        style = 'compact',  -- Tightly wraps text instead of full width
        padding = {
            top = 0,
            bottom = 0,
            left = 1,
            right = 1,
        },
    },
    quote = {
        enabled = true,
        style = 'compact',  -- Simple left-bar instead of boxy
        border = true,
    }
})
```

---

## 🔗 Integration with render-markdown.nvim

`fk_markdown.nvim` is fully compatible with all options from the parent `render-markdown.nvim` plugin. The custom schemas (`heading`, `code`, `quote`) are carefully intercepted and translated to the advanced rendering engine, while all other configuration blocks pass through seamlessly.

You can combine `fk_markdown` custom options with standard `render-markdown.nvim` settings:

```lua
require('fk_markdown').setup({
    -- fk_markdown custom options
    code = { ... },
    heading = { ... },
    quote = { ... },
    
    -- Standard render-markdown.nvim options
    bullet = { enabled = true, icons = { '●', '○', '◆', '◇' } },
    checkbox = { enabled = true },
    dash = { enabled = true, icon = '─' },
    pipe_table = { enabled = true, preset = 'none' },
    latex = { enabled = true },
    link = { enabled = true, image = '󰥶 ' },
})
```

For detailed documentation on inherited options, refer to the [render-markdown.nvim README](https://github.com/MeanderingProgrammer/render-markdown.nvim).

---

## 🎨 Theming & Colors

### Supported Color Formats

- **Hex Colors**: `"#f38ba8"` (recommended)
- **Named Highlights**: Reference existing Neovim highlight groups by name (resolved at setup time)
- **Special Values**: `"NONE"` for transparent backgrounds

### Example: Custom Catppuccin Theme

```lua
require('fk_markdown').setup({
    heading = {
        background = {
            font_color = {
                "#f38ba8",  -- H1: Flamingo (red)
                "#fab387",  -- H2: Peach (orange)
                "#f9e2af",  -- H3: Yellow
                "#a6e3a1",  -- H4: Green
                "#74c7ec",  -- H5: Blue
                "#cba6f7",  -- H6: Mauve (purple)
            }
        }
    }
})
```

---

## ⌨️ Commands & Keybindings

`fk_markdown.nvim` works transparently in the background. There are no special commands to learn. Simply open a Markdown file and rendering happens automatically.

To disable rendering for the current buffer:

```vim
:set conceallevel=0
```

To re-enable:

```vim
:set conceallevel=3
```

---

## 🐛 Troubleshooting

### Code blocks not rendering

**Problem**: Code blocks appear plain without borders or styling.

**Solutions**:
1. Ensure `nvim-treesitter` is installed and `markdown` parser is installed:
   ```vim
   :TSInstall markdown
   ```
2. Verify `config.code.enabled = true` in your setup
3. Check that the markdown file is recognized as filetype `markdown`:
   ```vim
   :set filetype?
   ```

### Colors not applying correctly

**Problem**: Heading or code block colors are wrong or not showing.

**Solutions**:
1. Use hex colors (`"#f38ba8"`) instead of named highlights for reliability
2. For dynamic mode, ensure `nvim-web-devicons` recognizes the language:
   ```lua
   require('nvim-web-devicons').get_icon('file.js')  -- Should return icon + color
   ```
3. Check your colorscheme supports the colors you've specified

### Performance degradation on large files

**Problem**: Rendering is slow or causes lag.

**Solutions**:
1. Increase the `debounce` parameter (default: 100ms):
   ```lua
   require('fk_markdown').setup({ debounce = 200 })
   ```
2. Reduce file size limits or disable rendering for very large files:
   ```lua
   require('fk_markdown').setup({ max_file_size = 5.0 })  -- 5MB limit
   ```
3. Disable expensive features like background highlighting:
   ```lua
   heading = { background = { enabled = false } }
   ```

### Treesitter errors

**Problem**: Error messages about treesitter queries or injections.

**Solutions**:
1. Update treesitter and parsers:
   ```vim
   :TSUpdate
   ```
2. Verify the `markdown` parser is installed:
   ```vim
   :TSInstall markdown
   ```

---

## 🤝 Contributing

Contributions, bug reports, and feature requests are welcome! 

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Commit your changes: `git commit -m 'Add my feature'`
4. Push to the branch: `git push origin feature/my-feature`
5. Open a Pull Request

---

## 🙏 Acknowledgments

This plugin is built on top of the robust core engine provided by [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim), created by [MeanderingProgrammer](https://github.com/MeanderingProgrammer). Sincere thanks to the maintainers for their exceptional work.

Special thanks to:
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) for parsing
- [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) for language icons and colors

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## 📞 Support

- **Issues**: Open an issue on [GitHub](https://github.com/the-mayankjha/fk_markdown.nvim/issues)
- **Discussions**: Join discussions on [GitHub Discussions](https://github.com/the-mayankjha/fk_markdown.nvim/discussions)
- **Documentation**: See [CONFIGURATION.md](./CONFIGURATION.md) for advanced options

---

<div align="center">

Made with ❤️ by [Mayank Jha](https://github.com/the-mayankjha)

</div>
