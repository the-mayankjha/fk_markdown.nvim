# fk_markdown.nvim

A lightweight Neovim plugin for rendering and customizing Markdown elements inside Neovim with flexible Lua configuration.

This update adds detailed documentation for how different Markdown elements are rendered inside the plugin and provides configuration pages per element (headers, codeblocks, callouts, tables) with placeholder screenshots you can replace later.

## Quick links

- Configuration overview: doc/configuration.md
- Header configuration: doc/configuration/header.md
- Codeblock configuration: doc/configuration/codeblock.md
- Callout configuration: doc/configuration/callout.md
- Table configuration: doc/configuration/table.md

## Installation

Use your favorite plugin manager. Example (packer.nvim):

```lua
use {
  'the-mayankjha/fk_markdown.nvim',
  config = function()
    require('fk_markdown').setup({
      -- plugin defaults (see doc/configuration.md)
    })
  end
}
```

## Render examples

Below are the Markdown elements supported and how they are rendered inside fk_markdown.nvim. Each example includes a link to the element-specific configuration page and a placeholder screenshot. Replace the placeholders at `doc/images/` with your own screenshots later.

- Headers
  - Description: Renders Markdown headers (#, ##, ###) using configurable styles and sizes.
  - Config: doc/configuration/header.md
  - Screenshot: ![Headers render](doc/images/headers.png)

- Bold / Italic / Underline
  - Description: Emphasizes text using bold, italic and underline styles. These styles are configurable via highlight groups and font features.
  - Config: doc/configuration.md#emphasis (general emphasis settings)
  - Screenshot: ![Bold Italic Underline render](doc/images/emphasis.png)

- Links
  - Description: Renders links with configurable text decorations and click/mapping support.
  - Config: doc/configuration.md#links
  - Screenshot: ![Links render](doc/images/links.png)

- Table
  - Description: Renders Markdown tables with borders, alternating row highlights, and alignment options.
  - Config: doc/configuration/table.md
  - Screenshot: ![Table render](doc/images/table.png)

- Codeblock
  - Description: Renders fenced code blocks with syntax highlighting, line numbers (optional), background, and a configurable gutter.
  - Config: doc/configuration/codeblock.md
  - Screenshot: ![Codeblock render](doc/images/codeblock.png)

- Quotation
  - Description: Renders blockquotes with a vertical bar, custom highlight, and optional author label.
  - Config: doc/configuration.md#quotation
  - Screenshot: ![Quotation render](doc/images/quotation.png)

- Callouts
  - Description: Renders informational/warning/error/success callouts with icons, colors, and custom titles.
  - Config: doc/configuration/callout.md
  - Screenshot: ![Callouts render](doc/images/callout.png)

- Bulleted & Numbered Lists
  - Description: Custom bullet symbols, indentation and nested list rendering.
  - Config: doc/configuration.md#lists
  - Screenshot: ![Lists render](doc/images/lists.png)

- Images
  - Description: Inline image placeholders and optional inline preview support (if an image preview plugin is enabled).
  - Config: doc/configuration.md#images
  - Screenshot: ![Images render](doc/images/images.png)

## Examples of configuration

See the element-specific docs for examples. Quick snippet for general setup:

```lua
require('fk_markdown').setup({
  header = {
    level_styles = {
      [1] = {size = 1.6, bold = true},
      [2] = {size = 1.3, bold = true},
      [3] = {size = 1.1, bold = false},
    }
  },
  codeblock = {
    show_line_numbers = false,
    style = 'single',
  },
  callout = {
    icons = {info = 'ℹ️', warn = '⚠️', error = '❌', success = '✅'}
  }
})
```

## Contributing

PRs are welcome. If you update screenshots, replace the placeholder images in `doc/images/` with the real ones and keep the same file names used above.

---

If you'd like, I can also add example screenshots into the repository as placeholder PNGs. For now I've added the documentation pages that reference placeholder image paths — tell me if you'd prefer I create small placeholder image files as well.