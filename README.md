# fk_markdown.nvim

A lightweight Neovim plugin for rendering and customizing Markdown elements inside Neovim with flexible Lua configuration.

This update adds detailed documentation for how different Markdown elements are rendered inside the plugin and provides configuration pages per element (headers, codeblocks, callouts, tables) with placeholder screenshots you can replace later.

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
  <div align-"center">
  <img width="1178" height="792" alt="image" src="https://github.com/user-attachments/assets/2ff2f9b9-4c31-417d-8f43-77e617cc690f" />
  <em>Headers with icon rendering</em>
  </div>
  - Description: Renders Markdown headers (#, ##, ###) using configurable styles and sizes.
  - Config: doc/configuration/header.md
 

- Bold / Italic / Underline
 <img width="1079" height="289" alt="image" src="https://github.com/user-attachments/assets/561dd3ee-287e-40cd-8bfd-5eddfe80aa9f" />

  - Description: Emphasizes text using bold, italic and underline styles. These styles are configurable via highlight groups and font features.
  - Config: doc/configuration.md#emphasis (general emphasis settings)


- Links
  <img width="1130" height="128" alt="image" src="https://github.com/user-attachments/assets/45c48f26-09a7-4903-b20d-732fcccf5918" />
  - Description: Renders links with configurable text decorations and click/mapping support.
  - Config: doc/configuration.md#links
 

- Table
  <img width="1090" height="294" alt="image" src="https://github.com/user-attachments/assets/3706dc15-80e3-4c3b-aece-4042ed55928e" />

  - Description: Renders Markdown tables with borders, alternating row highlights, and alignment options.
  - Config: doc/configuration/table.md


- Codeblock
  <img width="1113" height="705" alt="image" src="https://github.com/user-attachments/assets/fcd53006-4cbc-46d1-bdc5-f5cc7da41c55" />
  
  - Description: Renders fenced code blocks with syntax highlighting, line numbers (optional), background, and a configurable gutter.
  - Config: doc/configuration/codeblock.md

- Quotation
  <img width="1120" height="213" alt="image" src="https://github.com/user-attachments/assets/87c292d5-1010-4cab-83c3-2f32e710eb92" />

  - Description: Renders blockquotes with a vertical bar, custom highlight, and optional author label.
  - Config: doc/configuration.md#quotation
  

- Callouts
  <img width="1171" height="792" alt="image" src="https://github.com/user-attachments/assets/d81b57b4-cad3-45b3-bc25-f9d1f88438e8" />
  
  - Description: Renders informational/warning/error/success callouts with icons, colors, and custom titles.
  - Config: doc/configuration/callout.md

- Bulleted & Numbered Lists
  <img width="1053" height="443" alt="image" src="https://github.com/user-attachments/assets/205f6f10-0ba4-4e60-9d77-4704bff78354" />

  - Description: Custom bullet symbols, indentation and nested list rendering.
  - Config: doc/configuration.md#lists


- Links and Images
  <img width="1131" height="223" alt="image" src="https://github.com/user-attachments/assets/d856031d-81bf-437b-b295-d78dcdaf4c30" />
  - Description: Inline image placeholders and optional inline preview support (if an image preview plugin is enabled).
  - Config: doc/configuration.md#images


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
