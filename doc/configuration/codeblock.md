# Codeblock configuration

Customize fenced code blocks (```lang) rendering.

Options

- show_line_numbers: boolean — show/hide line numbers for codeblocks
- style: 'single' | 'double' | 'none' — border style
- hl = highlight group for code background
- gutter = { enable = boolean, width = number }

Example configuration

```lua
require('fk_markdown').setup({
  codeblock = {
    show_line_numbers = false,
    style = 'single',
    hl = 'Comment',
    gutter = { enable = true, width = 2 },
  }
})
```

Screenshot

![Codeblock render](doc/images/codeblock.png)

Tips

- For best syntax highlighting, ensure you have treesitter or a high-quality syntax plugin installed.
- Use `gutter.enable = false` if you want a compact appearance in narrow windows.