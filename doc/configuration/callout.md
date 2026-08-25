# Callout configuration

Callouts are blocks that emphasize information (info, warn, error, success). Configure icons, colors and titles.

Options

- icons: table mapping type to icon
- highlights: table mapping type to highlight group
- border: { enable = boolean, style = 'rounded' | 'square' }

Example configuration

```lua
require('fk_markdown').setup({
  callout = {
    icons = { info = 'ℹ️', warn = '⚠️', error = '❌', success = '✅' },
    highlights = { info = 'Info', warn = 'WarningMsg', error = 'Error', success = 'Todo' },
    border = { enable = true, style = 'rounded' }
  }
})
```

Screenshot

![Callouts render](doc/images/callout.png)

Tips

- Keep icons short so callouts remain compact.
- Use contrasty highlight groups so the callout stands out from surrounding text.