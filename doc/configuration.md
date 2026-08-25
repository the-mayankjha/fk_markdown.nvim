# fk_markdown.nvim — Configuration overview

This page covers general configuration options for fk_markdown.nvim: emphasis, lists, links, images and quotations. Specific elements (headers, tables, codeblocks, callouts) have their own pages linked from this overview.

## Emphasis (bold / italic / underline)

You can control how emphasis is applied via highlight groups and font options.

Example:

```lua
require('fk_markdown').setup({
  emphasis = {
    bold = {hl = 'Bold', enable = true},
    italic = {hl = 'Italic', enable = true},
    underline = {hl = 'Underline', enable = false},
  }
})
```

See screenshot: ![Emphasis render](doc/images/emphasis.png)

## Lists (bulleted & numbered)

Options allow customizing bullet characters, indentation, and nested-list visuals.

Example:

```lua
require('fk_markdown').setup({
  lists = {
    bullet = '•',
    nested_offset = 2,
    enable_tight_lists = true,
  }
})
```

See screenshot: ![Lists render](doc/images/lists.png)

## Links

Control link styling and optional key mappings for opening links.

Example:

```lua
require('fk_markdown').setup({
  links = {
    hl = 'Underlined',
    open_mapping = '<CR>',
    show_url_on_hover = false,
  }
})
```

See screenshot: ![Links render](doc/images/links.png)

## Images

Image display is optional and may depend on external preview plugins. You can configure placeholders and sizing.

Example:

```lua
require('fk_markdown').setup({
  images = {
    show_inline = false,
    placeholder = 'doc/images/image-placeholder.png',
    max_width = 80,
  }
})
```

See screenshot: ![Images render](doc/images/images.png)

## Quotation

Quotation (blockquotes) options.

```lua
require('fk_markdown').setup({
  quotation = {
    bar_char = '|',
    highlight = 'Comment',
    show_author = false,
  }
})
```

See screenshot: ![Quotation render](doc/images/quotation.png)

## Where to find element-specific options

- Headers: doc/configuration/header.md
- Tables: doc/configuration/table.md
- Codeblocks: doc/configuration/codeblock.md
- Callouts: doc/configuration/callout.md

Replace the image placeholders in `doc/images/` with your screenshots when ready.