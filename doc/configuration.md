# ⚙️ Configuration Overview

`fk_markdown.nvim` exposes a clean, modular configuration table. Some options are intercepted by the plugin's custom wrappers to simplify advanced configurations (like boxy codeblocks and custom heading backgrounds), while all other standard `render-markdown.nvim` configurations are natively supported and merged.

Specific elements have detailed documentation:
- 󰲡 [Header Configuration](file:///Users/mayankjha/fk_markdown.nvim/doc/configuration/header.md)
-  [Codeblock Configuration](file:///Users/mayankjha/fk_markdown.nvim/doc/configuration/codeblock.md)
-  [Table Configuration](file:///Users/mayankjha/fk_markdown.nvim/doc/configuration/table.md)
- 󰋽 [Callout & Quote Configuration](file:///Users/mayankjha/fk_markdown.nvim/doc/configuration/callout.md)
- 󰖟 [Web Preview Configuration](file:///Users/mayankjha/fk_markdown.nvim/doc/preview.md)

---

## 🎨 Core Engine Standard Options

Any options outside `heading`, `code`, and `quote` wrappers are forwarded directly to the core render engine. Below are key elements you can configure:

### Bullets (Lists)
Configure bullet characters and indentation spacing under the `bullet` block:
```lua
require('fk_markdown').setup({
    bullet = {
        enabled = true,
        icons = { '●', '○', '◆', '◇' }, -- Cycles bullet characters based on list nesting depth
        left_pad = 0,
        right_pad = 1,
        highlight = 'RenderMarkdownBullet',
    }
})
```
- [...image showing list bullet points]

### Checkboxes
Configure task checkboxes (e.g. `[ ]`, `[x]`, `[-]`) under the `checkbox` block:
```lua
require('fk_markdown').setup({
    checkbox = {
        enabled = true,
        unchecked = { icon = '󰄱 ', highlight = 'RenderMarkdownUnchecked' },
        checked = { icon = '󰱒 ', highlight = 'RenderMarkdownChecked' },
        custom = {
            todo = { raw = '[-]', rendered = '󰥔 ', highlight = 'RenderMarkdownTodo' },
        }
    }
})
```
- [...image showing task list checkboxes]

### Links & Images
Configure how inline hyperlinks, images, and wiki links are decorated under the `link` block:
```lua
require('fk_markdown').setup({
    link = {
        enabled = true,
        image = '󰥶 ',
        email = '󰀓 ',
        hyperlink = '󰌹 ',
        wiki = { enabled = true, icon = '󱗖 ' },
        highlight = 'RenderMarkdownLink',
        highlight_title = 'RenderMarkdownLinkTitle',
    }
})
```
- [...image showing styled inline link and image icon placeholders]

### Dashes (Thematic Breaks)
Customize thematic breaks (e.g., `---`) under the `dash` block:
```lua
require('fk_markdown').setup({
    dash = {
        enabled = true,
        icon = '─',
        highlight = 'RenderMarkdownDash',
    }
})
```
- [...image showing styled horizontal dash break]

---

## ⚙️ Plugin Settings

In addition to visual rendering, the following root settings control the plugin's runtime execution:

### `render_modes`
- **Type**: `string[] | boolean`
- **Default**: `{ 'n', 'c', 't' }`
- Vim modes that will render elements. Remaining modes will display native markdown.

### `max_file_size`
- **Type**: `number` (in MB)
- **Default**: `10.0`
- Maximum file size the plugin will attempt to render to prevent latency on large files.

### `debounce`
- **Type**: `integer` (in ms)
- **Default**: `100`
- Milliseconds to wait before refreshing the visual renders after a buffer change.

### `file_types`
- **Type**: `string[]`
- **Default**: `{ 'markdown' }`
- Filetypes this plugin will attach to.