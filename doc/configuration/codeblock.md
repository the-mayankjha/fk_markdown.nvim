#  Codeblock Configuration

Customize fenced code blocks (````lang ... ````) and inline code in `fk_markdown.nvim`. The plugin provides a wrapper called `code` to offer beautiful boxy visual layouts with dynamic border coloring, background padding, and title customization.

---

## ⚙️ Custom Wrapper Options

These are the primary options defined within the `code` block in your `setup()` function:

### `enabled`
- **Type**: `boolean`
- **Default**: `true`
- Toggle code block and inline code rendering.

### `style`
- **Type**: `'wide' | 'compact'`
- **Default**: `'wide'`
- Determines the width behaviour of the code block.
  - `wide`: Background and borders span the full width of the window.
  - `compact`: Background and borders wrap tightly around the code text width.
- [...image showing code block with style='compact']
- [...image showing code block with style='wide']

### `background`
Controls the background fill behind the code block.
- **`background.enabled`** (`boolean`, default: `false`): Toggles background color fill.
- **`background.color`** (`string`, default: `"#181825"`): Hex color used for code background.
- [...image showing code block background fill active]

### `padding`
Provides fine-grained space control using virtual lines and inline spacing.
- **`padding.top`** (`integer`, default: `1`): Number of empty virtual padding lines between the top border and code.
- **`padding.bottom`** (`integer`, default: `1`): Number of empty virtual padding lines between the code and bottom border.
- **`padding.left`** (`integer`, default: `1`): Number of space characters added between the left border (`│`) and code text.
- **`padding.right`** (`integer`, default: `2`): Extra padding width added to the right side (especially useful for `compact` style).
- [...image showing code block padding adjustments top=2, left=4]

### `border`
Configures the borders enclosing the code block.
- **`border.enabled`** (`boolean`, default: `true`): Enables outline borders (`╭`, `╮`, `│`, `╯`, `╰`).
- **`border.type`** (`"dynamic" | "static"`, default: `"dynamic"`):
  - `dynamic`: Automatically matches the `nvim-web-devicons` highlight color of the programming language.
  - `static`: Forces the border to use a specific color (ignores language type).
- **`border.color`** (`string`, default: `"#f38ba8"`): Hex color applied when type is `"static"`.
- [...image showing dynamic border color matching python DevIcon color]
- [...image showing static border color with code.border.color='#89b4fa']

### `title`
Configures the language indicator pill (e.g. `python` or `javascript`) overlayed on the top border.
- **`title.enabled`** (`boolean`, default: `true`): Toggle language name visibility.
- **`title.type`** (`"dynamic" | "static"`, default: `"dynamic"`):
  - `dynamic`: Uses the DevIcon color of the language for the text.
  - `static`: Uses a specific color.
- **`title.color`** (`string`, default: `"#a6e3a1"`): Hex color applied when type is `"static"`.
- [...image showing dynamic title text vs static title text]

### `icon`
Controls the programming language devicon at the top of the block.
- **`icon.enabled`** (`boolean`, default: `true`): Show/hide language devicon.
- **`icon.pill`** (`boolean`, default: `true`): Enclose icon/name inside a visual pill.
- **`icon.pill_style`** (`'wide' | 'compact'`, default: `'wide'`): Layout style of the pill.
- [...image with option like icon.enabled=false]

---

## 🔄 Inherited Engine Options

These options are part of the core engine and are specified directly inside the `code` table:

### `sign`
- **Type**: `boolean`
- **Default**: `true`
- Toggle sign column indicator next to code blocks.

### `conceal_delimiters`
- **Type**: `boolean`
- **Default**: `true`
- Conceals the markdown syntax delimiters (````) at the top and bottom of code blocks.

### `disable`
- **Type**: `string[]`
- **Default**: `{}`
- List of programming languages for which rendering should be disabled entirely (e.g., `{ 'bash', 'zsh' }`).

### `disable_background`
- **Type**: `boolean | string[]`
- **Default**: `{ 'diff' }`
- List of languages (or `true` for all) where background coloring is disabled. Often used for languages like diff that provide their own backgrounds.

### `inline`
- **Type**: `boolean`
- **Default**: `true`
- Toggle styling of inline code snippets (e.g., `` `code` ``).

### `inline_left` / `inline_right`
- **Type**: `string`
- **Default**: `""` / `""`
- Custom symbols/icons inserted to the left and right of inline code.

### `inline_pad`
- **Type**: `integer`
- **Default**: `0`
- Padding added to the left and right of inline code.

### `priority`
- **Type**: `integer`
- **Default**: `140`
- Highlight priority for the code block backgrounds.

---

## 📝 Configuration Examples

### Minimal Clean Layout (No Borders, Minimal Spacing)
```lua
require('fk_markdown').setup({
    code = {
        style = 'compact',
        border = { enabled = false },
        background = {
            enabled = true,
            color = "#1e1e2e"
        },
        padding = { top = 0, bottom = 0, left = 2, right = 2 }
    }
})
```

### High-Contrast Static Border Layout
```lua
require('fk_markdown').setup({
    code = {
        style = 'compact',
        background = {
            enabled = true,
            color = "#11111b"
        },
        border = {
            enabled = true,
            type = "static",
            color = "#fab387" -- Uniform orange borders
        },
        title = {
            enabled = true,
            type = "static",
            color = "#cdd6f4" -- Uniform white text
        },
        padding = { top = 1, bottom = 1, left = 2, right = 4 }
    }
})
```