# 󰲡 Header Configuration

Configure how Markdown headers (`#`, `##`, `###`, etc.) are rendered in `fk_markdown.nvim`. The plugin provides a wrapper called `heading` to simplify heading styles (custom icons, colors, and backgrounds) and inherits core rendering configurations from the underlying engine.

---

## ⚙️ Custom Wrapper Options

These are the primary options defined within the `heading` block in your `setup()` function:

### `enabled`
- **Type**: `boolean`
- **Default**: `true`
- Turn on or off heading icon and background rendering.

### `icon`
- **Type**: `boolean`
- **Default**: `true`
- Set to `false` to disable rendering custom heading icons and display native `#` markers instead.
- [...image with option like icon=false]

### `icons`
- **Type**: `string[]` or `fun(ctx: Context): string?`
- **Default**: `{ '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' }`
- Replaces the `#` character sequence with a custom icon for ATX headings based on the heading level (H1 to H6).
- [...image showing headings with custom icons H1 to H6]

### `background`
Controls the header backgrounds and foreground text colors.
- **`background.enabled`** (`boolean`, default: `false`): Enables background fills behind header lines.
- **`background.bg_color`** (`string[]`, default: list of `#1e1e2e`): Hex colors for backgrounds of levels H1 to H6.
- **`background.font_color`** (`string[]`, default: list of Catppuccin-themed hexes): Hex colors for the foreground text of levels H1 to H6.
- [...image showing background.enabled=true with distinct bg_color and font_color settings]

---

## 🔄 Inherited Engine Options

These options are part of the core engine and are specified directly inside the `heading` table:

### `position`
- **Type**: `'overlay' | 'inline' | 'right' | 'eol'`
- **Default**: `'overlay'`
- Determines how the custom header icons are positioned:
  - `overlay`: Overlay the icon directly over the `#` markers (conceals them and aligns left).
  - `inline`: Conceals the `#` and inlines the icon at the start of the heading.
  - `right`: Conceals the `#` and appends the icon immediately to the right of the heading text.
  - `eol`: Conceals the `#` and aligns the icon to the far-right edge of the buffer.
- [...image demonstrating position='inline' compared to position='overlay']

### `width`
- **Type**: `'full' | 'block' | ('full' | 'block')[]`
- **Default**: `'full'`
- Controls background highlight width:
  - `full`: Highlight extends across the entire line length.
  - `block`: Highlight spans only the visual width of the heading text.
- [...image displaying width='block' backgrounds]

### `border`
- **Type**: `boolean | boolean[]`
- **Default**: `false`
- If enabled, adds solid horizontal border lines above and below headings.
- [...image showing border=true for H1 headers]

### `above` / `below`
- **Type**: `string`
- **Default**: `'▄'` / `'▀'`
- The character used to construct the borders.

### `border_prefix`
- **Type**: `boolean`
- **Default**: `false`
- If true, colors the start of the border with the foreground color.

### `border_virtual`
- **Type**: `boolean`
- **Default**: `false`
- Forces the use of virtual lines for borders instead of attempting to overlay empty lines.

### `left_margin` / `left_pad` / `right_pad`
- **Type**: `number | number[]` (or float `< 1` for window percentage)
- **Default**: `0` / `0` / `0`
- Adjusts spacing around the heading content. `right_pad` applies when `width` is `'block'`.

### `min_width`
- **Type**: `integer | integer[]`
- **Default**: `0`
- Minimum width of heading backgrounds when `width` is `'block'`.

### `sign` / `signs`
- **Type**: `boolean` / `string[]`
- **Default**: `true` / `{ '󰫎 ' }`
- Show indicators in the editor sign column next to headers.

### `custom`
- **Type**: `table<string, CustomHeading>`
- Match heading text to apply pattern-specific icons and colors.
  - `pattern`: String pattern matched against heading text.
  - `icon` (optional): Custom icon override.
  - `background` (optional): Custom background highlight group override.
  - `foreground` (optional): Custom foreground highlight group override.

---

## 📝 Configuration Examples

### Minimal Setup with Native Markers
To disable fancy icons and keep native `#` characters but keep custom foreground colors:
```lua
require('fk_markdown').setup({
    heading = {
        icon = false,
        background = {
            enabled = false,
            font_color = { 
                "#ff5555", "#ffb86c", "#f1fa8c", 
                "#50fa7b", "#8be9fd", "#bd93f9" 
            }
        }
    }
})
```

### Modern Block-Width Headers with Borders
```lua
require('fk_markdown').setup({
    heading = {
        enabled = true,
        icons = { '➊ ', '➋ ', '➌ ', '➍ ', '➎ ', '➏ ' },
        width = 'block',
        left_pad = 2,
        right_pad = 2,
        border = { true, true, false, false, false, false }, -- Borders only on H1 & H2
        border_virtual = true,
        above = '─',
        below = '─',
        background = {
            enabled = true,
            bg_color = { 
                "#2d3139", "#2d3139", "NONE", "NONE", "NONE", "NONE" 
            },
            font_color = { 
                "#61afef", "#98c379", "#e5c07b", 
                "#e06c75", "#d19a66", "#c678dd" 
            }
        }
    }
})
```