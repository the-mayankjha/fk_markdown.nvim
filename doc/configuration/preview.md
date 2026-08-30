# 🌐 Web Preview Configuration

`fk_markdown.nvim` includes a built-in, lightweight local web preview server with real-time live synchronization, cursor-based synchronized auto-scrolling, local image serving, and customizable code block syntax highlighting.

---

## 🚀 Commands

| Command | Description |
|---|---|
| `:FkPreview` | Start live browser preview for the current buffer |
| `:FkPreviewStop` | Stop the preview server for the current buffer |
| `:FkPreviewToggle` | Toggle the preview server on / off |
| `:FkPreviewAutoScroll [on\|off\|toggle]` | Toggle or set synchronized cursor scrolling |

> [!TIP]
> `:FkAutoScroll` and `:FkAutoscroll` are available as command aliases for `:FkPreviewAutoScroll`.

You can also call the Lua API directly:
```lua
require('fk_markdown.preview').start()
require('fk_markdown.preview').stop()
require('fk_markdown.preview').toggle()
require('fk_markdown.preview').autoscroll() -- or autoscroll("on" | "off" | "toggle")
```

---

## ⚙️ Full Configuration Reference

All preview options are defined under the `preview` table in `require('fk_markdown').setup()`:

```lua
require('fk_markdown').setup({
    preview = {
        -- Enable preview functionality
        enabled = true,

        -- Automatically launch browser preview when opening Markdown files
        auto_start = false,

        -- Automatically stop the preview server when closing the buffer
        auto_close = true,

        -- Real-time synchronized scrolling following cursor position
        auto_scroll = true,

        -- Specific browser to open (e.g. "firefox", "google-chrome", "brave")
        -- Leave empty ("") to use system default browser
        browser = "",

        -- Optional custom browser opener function: fun(url: string)
        browser_func = nil,

        -- Fixed port for preview server (nil = choose an available port automatically)
        port = nil,

        -- IP address to bind local server
        open_ip = "127.0.0.1",

        -- Overall theme for preview: "dark" or "light"
        theme = "dark",

        -- Code block syntax highlighting configuration
        syntax_highlight = {
            -- Enable syntax highlighting in web preview
            enabled = true,

            -- Highlight.js theme
            -- Popular options: "github-dark", "github", "atom-one-dark", "monokai",
            -- "tokyo-night-dark", "dracula", "nord", "vs2015", etc.
            theme = "github-dark",

            -- Custom syntax color overrides (hex codes or Neovim highlight group names)
            colors = {
                background    = nil, -- e.g. "#181825" or "RenderMarkdownCode"
                text          = nil, -- e.g. "#cdd6f4"
                border        = nil, -- e.g. "#313244" or "FkMarkdownCodeBorder"
                keyword       = nil, -- e.g. "#cba6f7" (local, function, return, if)
                string        = nil, -- e.g. "#a6e3a1" ("strings")
                number        = nil, -- e.g. "#fab387" (123, 0xFF)
                comment       = nil, -- e.g. "#6c7086" (-- comments)
                function_name = nil, -- e.g. "#89b4fa" (function calls & declarations)
                variable      = nil, -- e.g. "#f38ba8" (variables & fields)
                constant      = nil, -- e.g. "#fab387" (constants & symbols)
                operator      = nil, -- e.g. "#89dceb" (=, +, -, etc.)
                builtin       = nil, -- e.g. "#89dceb" (require, print)
                type          = nil, -- e.g. "#f9e2af" (types & classes)
                tag           = nil, -- e.g. "#89b4fa" (HTML/XML tags)
                attribute     = nil, -- e.g. "#f9e2af" (HTML/XML attributes)
            },
        },

        -- Keymaps for preview actions
        keymap = {
            start  = false, -- e.g. "<leader>mp"
            stop   = false, -- e.g. "<leader>mq"
            toggle = false, -- e.g. "<leader>mt"
        },
    },
})
```

---

## 🎨 Syntax Highlighting & Colors

### 1. Highlight.js Themes
Choose any theme from the [Highlight.js Theme Library](https://highlightjs.org/examples):

```lua
require('fk_markdown').setup({
    preview = {
        syntax_highlight = {
            enabled = true,
            theme = "atom-one-dark", -- or "monokai", "tokyo-night-dark", "dracula", "nord", etc.
        },
    },
})
```

### 2. Custom Color Palette (Catppuccin, TokyoNight, etc.)
Customize token colors using `#hex` strings or Neovim highlight group names:

```lua
require('fk_markdown').setup({
    preview = {
        syntax_highlight = {
            enabled = true,
            theme = "github-dark",
            colors = {
                background    = "#181825",
                text          = "#cdd6f4",
                border        = "#313244",
                keyword       = "#cba6f7",
                string        = "#a6e3a1",
                number        = "#fab387",
                comment       = "#6c7086",
                function_name = "#89b4fa",
                variable      = "#f38ba8",
                constant      = "#fab387",
                operator      = "#89dceb",
                builtin       = "#f2cdcd",
                type          = "#f9e2af",
            },
        },
    },
})
```

### 3. Shorthand Configurations
The setup also accepts convenient shorthand forms:

```lua
-- Simple boolean toggle
preview = { syntax_highlight = false }

-- Shorthand under code or syntax keys
preview = {
    code = {
        enabled = true,
        theme = "dracula",
        colors = {
            keyword = "#ff79c6",
            string = "#f1fa8c",
        },
    },
}
```

---

## 📜 Synchronized Auto-Scroll

When `auto_scroll = true` (default), the preview window smoothly tracks your cursor line in Neovim in real-time as you navigate.

- Toggle during runtime with `:FkPreviewAutoScroll`
- Force a state with `:FkPreviewAutoScroll on` or `:FkPreviewAutoScroll off`
- Set in configuration with `preview = { auto_scroll = false }`

---

## ⌨️ Setting Keymaps

Easily bind keys to start, stop, or toggle preview:

```lua
require('fk_markdown').setup({
    preview = {
        keymap = {
            start  = "<leader>mp",
            stop   = "<leader>mq",
            toggle = "<leader>mt",
        },
    },
})
```

---

## 🖼️ Local Image & Asset Support

The preview server automatically resolves and serves local relative images (PNG, JPG, GIF, SVG) located in the same directory as your Markdown file:

```markdown
![Architecture](./assets/diagram.png)
<img src="banner.png" width="600" />
```

---

## 📋 Option Reference

| Option | Type | Default | Description |
|---|---|---|---|
| `enabled` | `boolean` | `true` | Enable preview feature |
| `auto_start` | `boolean` | `false` | Launch browser on opening markdown files |
| `auto_close` | `boolean` | `true` | Stop preview server when buffer is closed |
| `auto_scroll` | `boolean` | `true` | Synchronize browser scroll position with cursor |
| `browser` | `string` | `""` | Browser executable (`""` uses system default) |
| `browser_func` | `function` | `nil` | Custom opener callback `fun(url: string)` |
| `port` | `integer\|nil` | `nil` | Fixed server port (`nil` assigns random available port) |
| `open_ip` | `string` | `"127.0.0.1"` | IP address to bind local server |
| `theme` | `string` | `"dark"` | Preview document theme (`"dark"` or `"light"`) |
| `syntax_highlight.enabled` | `boolean` | `true` | Enable codeblock syntax highlighting |
| `syntax_highlight.theme` | `string` | `"github-dark"` | Highlight.js CSS theme name |
| `syntax_highlight.colors` | `table` | `{}` | Custom token color overrides (hex / hl group) |
| `keymap.start` | `string\|false` | `false` | Normal mode keymap to start preview |
| `keymap.stop` | `string\|false` | `false` | Normal mode keymap to stop preview |
| `keymap.toggle` | `string\|false` | `false` | Normal mode keymap to toggle preview |

---

## 💡 Recommended Configurations

### Catppuccin Theme Preview
```lua
require('fk_markdown').setup({
    preview = {
        theme = "dark",
        syntax_highlight = {
            enabled = true,
            theme = "github-dark",
            colors = {
                background    = "#1e1e2e",
                text          = "#cdd6f4",
                border        = "#313244",
                keyword       = "#cba6f7",
                string        = "#a6e3a1",
                number        = "#fab387",
                comment       = "#6c7086",
                function_name = "#89b4fa",
                variable      = "#f38ba8",
                operator      = "#89dceb",
                builtin       = "#f2cdcd",
                type          = "#f9e2af",
            },
        },
        keymap = {
            toggle = "<leader>mp",
        },
    },
})
```
