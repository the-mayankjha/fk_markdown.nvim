#  Table Configuration

Configure how Markdown pipe tables are rendered in `fk_markdown.nvim`. All table configurations are declared within the `pipe_table` block in your `setup()` function.

---

## ⚙️ Configuration Options

These are the primary options defined within the `pipe_table` block:

### `enabled`
- **Type**: `boolean`
- **Default**: `true`
- Toggle pipe table formatting and rendering.

### `preset`
- **Type**: `'none' | 'round' | 'double' | 'heavy'`
- **Default**: `'none'`
- Pre-configured border styles to easily apply borders without manually setting the individual characters:
  - `none`: Does not apply presets; uses the explicit `border` table characters.
  - `round`: Applies thin borders with rounded corners.
  - `double`: Applies double-line borders.
  - `heavy`: Applies thick/heavy borders.
- [...image showing table with preset='round']
- [...image showing table with preset='double']

### `cell`
- **Type**: `'padded' | 'trimmed' | 'raw' | 'overlay'`
- **Default**: `'padded'`
- Controls how individual cell content is displayed:
  - `padded`: Evaluates column widths and pads all cells to match the widest element in their column.
  - `trimmed`: Padded, but subtracts empty space from visual width calculations.
  - `raw`: Replaces border character pipes (`|`) but leaves internal spacing untouched.
  - `overlay`: Completely overlays the table contents, removing conceal options.
- [...image showing cell='padded' aligning column contents]
- [...image showing cell='raw' keeping native text spacing]

### `padding`
- **Type**: `integer`
- **Default**: `1`
- Number of spaces to insert between cell content text and the vertical borders (`│`).
- [...image with option like padding=2]

### `min_width`
- **Type**: `integer`
- **Default**: `0`
- Minimum width of columns when `cell` is set to `'padded'` or `'trimmed'`.

### `border`
- **Type**: `string[]`
- **Default**: `{'┌', '┬', '┐', '├', '┼', '┤', '└', '┴', '┘', '│', '─'}`
- Explicit characters used to build the table grid. The table maps 11 positions:
  1. Top-left corner (`┌`)
  2. Top-center intersection (`┬`)
  3. Top-right corner (`┐`)
  4. Delimiter-left intersection (`├`)
  5. Delimiter-center intersection (`┼`)
  6. Delimiter-right intersection (`┤`)
  7. Bottom-left corner (`└`)
  8. Bottom-center intersection (`┴`)
  9. Bottom-right corner (`┘`)
  10. Vertical borders (`│`)
  11. Horizontal borders (`─`)

### `border_enabled`
- **Type**: `boolean`
- **Default**: `true`
- Toggle drawing of top and bottom border lines.
- [...image showing border_enabled=false]

### `border_virtual`
- **Type**: `boolean`
- **Default**: `false`
- Forces table borders to render using virtual lines instead of empty spaces. This is automatically turned on if Neovim's indent module is active.

### `alignment_indicator`
- **Type**: `string`
- **Default**: `'━'`
- The character placed on the delimiter row to indicate column alignment (left/center/right).

### `head`
- **Type**: `string` (Highlight group name)
- **Default**: `'RenderMarkdownTableHead'`
- Highlight group applied to the table header cells, header delimiter separators, and the border row above it.

### `row`
- **Type**: `string` (Highlight group name)
- **Default**: `'RenderMarkdownTableRow'`
- Highlight group applied to body cells, body separators, and the border row below.

### `style`
- **Type**: `'full' | 'normal' | 'none'`
- **Default**: `'full'`
- Quick toggles for table border coverage:
  - `full`: Uses all standard default borders.
  - `normal`: Removes top and bottom borders (hides top/bottom lines).
  - `none`: Completely disables table rendering.

---

## 📝 Configuration Examples

### Minimal Clean Rounded Corner Tables
```lua
require('fk_markdown').setup({
    pipe_table = {
        enabled = true,
        preset = 'round',
        cell = 'padded',
        padding = 1,
        border_enabled = true,
        head = 'Title',
        row = 'Normal'
    }
})
```

### Classic Double-line Border Tables
```lua
require('fk_markdown').setup({
    pipe_table = {
        enabled = true,
        preset = 'double',
        cell = 'trimmed',
        padding = 2,
        alignment_indicator = '═'
    }
})
```