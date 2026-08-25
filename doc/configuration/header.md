# Header configuration

Configure how Markdown headers (#, ##, ###, etc.) are rendered.

Options

- level_styles: table mapping header level to style options
  - size: relative size multiplier
  - bold: boolean
  - hl: highlight group name

Example configuration

```lua
require('fk_markdown').setup({
  header = {
    level_styles = {
      [1] = {size = 1.6, bold = true, hl = 'Title'},
      [2] = {size = 1.3, bold = true, hl = 'Keyword'},
      [3] = {size = 1.1, bold = false, hl = 'Type'},
    },
    underline = {
      enable = true,
      char = '─',
      hl = 'Comment',
    }
  }
})
```

Screenshot

![Headers render](doc/images/headers.png)

Tips

- If your terminal/font doesn't support relative sizes, prefer using bold + highlight groups instead of size multipliers.
- Use `underline` to add a subtle underline effect for level-1 headers.