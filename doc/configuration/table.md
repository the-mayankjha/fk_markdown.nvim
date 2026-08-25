# Table configuration

Configure how Markdown tables are rendered: borders, alignment and alternating row highlights.

Options

- border: { enable = boolean, style = 'single' | 'double' | 'none' }
- align = { left = 'left', center = 'center', right = 'right' }
- alternate_rows = boolean

Example configuration

```lua
require('fk_markdown').setup({
  table = {
    border = { enable = true, style = 'single' },
    align = { default = 'left' },
    alternate_rows = true,
  }
})
```

Screenshot

![Table render](doc/images/table.png)

Tips

- If table columns wrap, consider increasing the editor width or using `wrap` toggles to view the full table.
- Use `alternate_rows` to help visually separate rows in long tables.