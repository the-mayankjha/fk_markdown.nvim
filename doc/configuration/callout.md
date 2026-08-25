# 󰋽 Callout & Quote Configuration

Configure Markdown blockquotes (`> text`) and callouts (e.g., `> [!NOTE]`) in `fk_markdown.nvim`. The plugin provides a wrapper called `quote` to toggle between clean compact layouts and beautiful Notion-like boxy containers with custom accent bars.

---

## ⚙️ Quote Configuration Options

These are the primary options defined within the `quote` block in your `setup()` function:

### `enabled`
- **Type**: `boolean`
- **Default**: `true`
- Toggle blockquote and callout rendering.

### `style`
- **Type**: `'boxy' | 'compact'`
- **Default**: `'boxy'`
- Determines the container visual style:
  - `boxy`: A full, rounded-box container resembling Notion callouts. Text flows inside a boxed border with optional background colors and title bars.
  - `compact`: A standard sidebar accent line on the left of blockquotes.
- [...image showing quote with style='boxy']
- [...image showing quote with style='compact']

### `accent`
- **Type**: `'thick' | 'line' | 'corner'`
- **Default**: `'line'`
- Applies only when `style = 'boxy'`. Determines the shape of the left visual indicator bar:
  - `thick`: A solid, thick gradient left edge (`█▌`).
  - `line`: A standard sidebar left edge (`▌ `).
  - `corner`: Hides the continuous vertical bar; the container corners (╭/╰) act as the accent.
- [...image showing boxy style with accent='thick']
- [...image showing boxy style with accent='corner']

### `border`
- **Type**: `boolean`
- **Default**: `true`
- Applies only when `style = 'boxy'`. Enables rounded top/bottom/right borders (`╭─╮`, `│`, `╰─╯`) to enclose the container.

### `bg`
- **Type**: `string`
- **Default**: `"NONE"`
- Background color for the box container. Can be `"NONE"` (transparent) or a specific hex color (e.g., `"#1e1e2e"`).
- [...image showing callout with custom background fill bg='#1e1e2e']

### `fg`
- **Type**: `string`
- **Default**: `"#cad3f5"`
- Foreground text color for the quote block.

### `icon`
- **Type**: `string | string[]`
- **Default**: `'▋'`
- The character used to replace the native `>` markdown marker when in `'compact'` style. Can be an array evaluated by level.

### `repeat_linebreak`
- **Type**: `boolean`
- **Default**: `false`
- Repeats the left quote bar icon on wrapped lines.

### `highlight`
- **Type**: `string | string[]`
- **Default**: List of `'RenderMarkdownQuote1'` to `'RenderMarkdownQuote6'`
- Highlight groups applied to the quote icons.

---

## ⚙️ Callout Configuration Options

Callouts are defined under the `callout` table in your `setup()` function. The keys represent the callout types (e.g. `note`, `tip`, `warning`) mapping to their individual properties:

```lua
callout = {
    note = { 
        raw = '[!NOTE]', 
        rendered = '󰋽 Note', 
        highlight = 'RenderMarkdownInfo', 
        category = 'github' 
    },
    -- ...
}
```

### Callout Properties

- **`raw`** (`string`): The raw text identifier inside the blockquote (e.g., `"[!NOTE]"`).
- **`rendered`** (`string`): The icon and text overlay replacement (e.g., `"󰋽 Note"`).
- **`highlight`** (`string`): The highlight group applied to the title card and left borders.
- **`quote_icon`** (`string`, optional): Custom icon to override `quote.icon` specifically for this callout type.
- **`category`** (`string`, optional): Optional category metadata (e.g., `"github"` or `"obsidian"`).

### Standard Callouts Provided by default

- **GitHub themed**: `note` (`󰋽`), `tip` (`󰌶`), `important` (`󰅾`), `warning` (`󰀪`), `caution` (`󰳦`)
- **Obsidian themed**: `abstract` (`󰨸`), `todo` (`󰗡`), `success` (`󰄬`), `question` (`󰘥`), `bug` (`󰨰`), `example` (`󰉹`), `quote` (`󱆨`), etc.

---

## 📝 Configuration Examples

### Minimal Transparent Boxy Callout
```lua
require('fk_markdown').setup({
    quote = {
        style = 'boxy',
        accent = 'line',
        border = true,
        bg = 'NONE',
        fg = '#cdd6f4'
    }
})
```

### Full Notion-Style Highlighted Blockquotes
```lua
require('fk_markdown').setup({
    quote = {
        style = 'boxy',
        accent = 'thick',
        border = true,
        bg = '#181825',
        fg = '#cad3f5'
    },
    callout = {
        -- Overriding warning callout text & icon
        warning = { 
            raw = '[!WARNING]', 
            rendered = '⚠️ CRITICAL ALERT', 
            highlight = 'RenderMarkdownError' 
        }
    }
})
```