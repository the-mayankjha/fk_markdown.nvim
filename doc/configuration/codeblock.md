# 💻 Code Block Configuration

Customize fenced code blocks (` ```lang ... ``` `) and inline code in
`fk_markdown.nvim`.

The `code` configuration provides a flexible way to control code block layouts,
backgrounds, padding, borders, language titles, DevIcons, and inline code
rendering.

---

## ⚙️ Custom Wrapper Options

These are the primary options defined inside the `code` block of your
`setup()` configuration.

### `enabled`

- **Type:** `boolean`
- **Default:** `true`

Enables or disables code block and inline code rendering.

```lua
code = {
    enabled = true,
}
```

---

### `style`

- **Type:** `'wide' | 'compact'`
- **Default:** `'wide'`

Controls the width and layout behavior of the code block.

| `wide` | `compact` |
|:---:|:---:|
| <img src="https://github.com/user-attachments/assets/f91ccad1-7bab-468c-880c-2e34dedf891a" width="100%"> | <img src="https://github.com/user-attachments/assets/c2445cda-b0d8-4f54-b08b-e5a1673adb1a" width="100%"> |
| Full-width layout | Content-focused layout |

#### Wide

The `wide` style allows the code block background and borders to span the
available window width.

```lua
code = {
    enabled = true,
    style = 'wide',

    background = {
        enabled = false,
        color = "#181825",
    },
}
```

#### Compact

The `compact` style keeps the code block closer to the visual width of the
code content.

```lua
code = {
    enabled = true,
    style = 'compact',

    background = {
        enabled = false,
        color = "#181825",
    },
}
```

> [!NOTE]
> `compact` style is currently under development and may not behave as
> expected in all cases.

---

## 🎨 Background

Controls the background fill behind rendered code blocks.

### `background.enabled`

- **Type:** `boolean`
- **Default:** `false`

Enables or disables the code block background.

| Transparent Background | Custom Background |
|:---:|:---:|
| <img src="https://github.com/user-attachments/assets/f91ccad1-7bab-468c-880c-2e34dedf891a" width="100%"> | <img src="https://github.com/user-attachments/assets/4a6d9ac3-3ebc-46d2-90aa-b43251402fd5" width="100%"> |
| `background.enabled = false` | `background.enabled = true` |

#### Disable Background

```lua
code = {
    enabled = true,
    style = 'wide',

    background = {
        enabled = false,
        color = "#181825",
    },
}
```

#### Enable Background

```lua
code = {
    enabled = true,
    style = 'wide',

    background = {
        enabled = true,
        color = "#181825",
    },
}
```

---

### `background.color`

- **Type:** `string`
- **Default:** `"#181825"`

Specifies the background color used when
`background.enabled = true`.

```lua
code = {
    background = {
        enabled = true,
        color = "#181825",
    },
}
```

---

## 📐 Padding

Provides fine-grained control over the spacing around code content using
virtual lines and inline spacing.

### Padding Overview

<img src="https://github.com/user-attachments/assets/9b6990a5-71b0-400b-8dd1-f23b6832e77d" width="100%">

```lua
code = {
    enabled = true,
    style = 'wide',

    padding = {
        top = 1,
        bottom = 0,
        left = 1,
        right = 2,
    },
}
```

### `padding.top`

- **Type:** `integer`
- **Default:** `1`

Number of empty virtual padding lines between the top border and the code.

### `padding.bottom`

- **Type:** `integer`
- **Default:** `1`

Number of empty virtual padding lines between the code and the bottom border.

### `padding.left`

- **Type:** `integer`
- **Default:** `1`

Number of space characters inserted between the left border (`│`) and the
code text.

### `padding.right`

- **Type:** `integer`
- **Default:** `2`

Additional padding width applied to the right side of the code block.

This is especially useful with `compact` style.

---

# 🖼️ Border & Title

The `border` and `title` configurations define the visual identity of a code
block.

Both support two color modes:

- **Dynamic** — automatically follows the programming language's DevIcon color.
- **Static** — uses a custom color defined by the user.

---

## Dynamic vs Static

| Dynamic | Static |
|:---:|:---:|
| <img src="https://github.com/user-attachments/assets/67a8db62-48d9-4c16-98d9-1dbd37542216" width="100%"> | <img src="https://github.com/user-attachments/assets/f91ccad1-7bab-468c-880c-2e34dedf891a" width="100%"> |
| Language-aware colors | Custom colors |

---

## `border`

Configures the outline surrounding the code block.

### `border.enabled`

- **Type:** `boolean`
- **Default:** `true`

Enables or disables the code block outline.

```lua
border = {
    enabled = true,
}
```

### `border.type`

- **Type:** `"dynamic" | "static"`
- **Default:** `"dynamic"`

Determines how the border color is selected.

| Type | Description |
|---|---|
| `dynamic` | Automatically matches the `nvim-web-devicons` highlight color of the programming language |
| `static` | Uses the explicitly configured `border.color` |

#### Dynamic Border

```lua
border = {
    enabled = true,
    type = "dynamic",
}
```

#### Static Border

```lua
border = {
    enabled = true,
    type = "static",
    color = "#abcdef",
}
```

### `border.color`

- **Type:** `string`
- **Default:** `"#f38ba8"`

Specifies the border color when `border.type` is `"static"`.

```lua
border = {
    enabled = true,
    type = "static",
    color = "#abcdef",
}
```

---

## `title`

Controls the programming-language indicator displayed on the top border.

```text
╭── 󰌛 lua ──────────────────────────╮
│                                    │
│  print("Hello, Neovim!")           │
│                                    │
╰────────────────────────────────────╯
```

### `title.enabled`

- **Type:** `boolean`
- **Default:** `true`

Shows or hides the language title.

```lua
title = {
    enabled = true,
}
```

### `title.type`

- **Type:** `"dynamic" | "static"`
- **Default:** `"dynamic"`

Determines how the title color is selected.

| Type | Description |
|---|---|
| `dynamic` | Automatically matches the DevIcon color of the programming language |
| `static` | Uses the explicitly configured `title.color` |

#### Dynamic Title

<img src="https://github.com/user-attachments/assets/f172ff00-e7b3-47a3-a77c-4ba2256ae9ae" width="100%">

```lua
title = {
    enabled = true,
    type = "dynamic",
}
```

#### Static Title

```lua
title = {
    enabled = true,
    type = "static",
    color = "#abcdef",
}
```

### `title.color`

- **Type:** `string`
- **Default:** `"#a6e3a1"`

Specifies the title color when `title.type` is `"static"`.

```lua
title = {
    enabled = true,
    type = "static",
    color = "#abcdef",
}
```

---

## 🔗 Border + Title

Because `border` and `title` support the same dynamic/static concept, they can
be combined in several ways.

### Dynamic Border + Dynamic Title

Automatically adapts the code block styling to the programming language.

```lua
code = {
    enabled = true,
    style = 'wide',

    border = {
        enabled = true,
        type = "dynamic",
    },

    title = {
        enabled = true,
        type = "dynamic",
    },
}
```

### Static Border + Static Title

Uses a consistent custom color for both the border and title.

```lua
code = {
    enabled = true,
    style = 'wide',

    border = {
        enabled = true,
        type = "static",
        color = "#abcdef",
    },

    title = {
        enabled = true,
        type = "static",
        color = "#abcdef",
    },
}
```

### Dynamic Border + Static Title

Keeps the language-aware border while using a consistent title color.

```lua
code = {
    enabled = true,
    style = 'wide',

    border = {
        enabled = true,
        type = "dynamic",
    },

    title = {
        enabled = true,
        type = "static",
        color = "#cdd6f4",
    },
}
```

### Static Border + Dynamic Title

Uses a consistent border while allowing the title to follow the programming
language.

```lua
code = {
    enabled = true,
    style = 'wide',

    border = {
        enabled = true,
        type = "static",
        color = "#abcdef",
    },

    title = {
        enabled = true,
        type = "dynamic",
    },
}
```

---

## 🔹 Icon

Controls the programming-language DevIcon displayed with the code block title.

### `icon.enabled`

- **Type:** `boolean`
- **Default:** `true`

Shows or hides the language DevIcon.

```lua
icon = {
    enabled = true,
}
```

### `icon.pill`

- **Type:** `boolean`
- **Default:** `true`

Controls whether the language icon and title are enclosed inside a visual pill.

```lua
icon = {
    pill = true,
}
```

### `icon.pill_style`

- **Type:** `'wide' | 'compact'`
- **Default:** `'wide'`

Controls the layout of the language indicator pill.

```lua
icon = {
    pill = true,
    pill_style = 'wide',
}
```

Available styles:

- `wide`
- `compact`

---

# 🔄 Inherited Engine Options

The following options are part of the underlying rendering engine and are
configured directly inside the `code` table.

### `sign`

- **Type:** `boolean`
- **Default:** `true`

Controls the sign-column indicator displayed next to code blocks.

```lua
code = {
    sign = true,
}
```

### `conceal_delimiters`

- **Type:** `boolean`
- **Default:** `true`

Conceals the Markdown syntax delimiters at the top and bottom of fenced code
blocks.

```lua
code = {
    conceal_delimiters = true,
}
```

### `disable`

- **Type:** `string[]`
- **Default:** `{}`

Specifies programming languages for which code block rendering should be
disabled entirely.

```lua
code = {
    disable = {
        'bash',
        'zsh',
    },
}
```

### `disable_background`

- **Type:** `boolean | string[]`
- **Default:** `{ 'diff' }`

Disables background rendering for selected languages.

```lua
code = {
    disable_background = {
        'diff',
        'git',
    },
}
```

Set to `true` to disable backgrounds for all languages:

```lua
code = {
    disable_background = true,
}
```

### `inline`

- **Type:** `boolean`
- **Default:** `true`

Controls styling for inline code snippets.

```markdown
Use `vim.api.nvim_get_current_line()` here.
```

Disable inline code rendering with:

```lua
code = {
    inline = false,
}
```

### `inline_left` / `inline_right`

- **Type:** `string`
- **Default:** `""` / `""`

Defines custom symbols or icons inserted to the left and right of inline code.

```lua
code = {
    inline_left = "",
    inline_right = "",
}
```

### `inline_pad`

- **Type:** `integer`
- **Default:** `0`

Controls the padding applied to the left and right of inline code.

```lua
code = {
    inline_pad = 1,
}
```

### `priority`

- **Type:** `integer`
- **Default:** `140`

Controls the highlight priority used for code block backgrounds.

```lua
code = {
    priority = 140,
}
```

---

# 📝 Configuration Examples

## Minimal Clean Layout

```lua
require('fk_markdown').setup({
    code = {
        style = 'compact',

        border = {
            enabled = false,
        },

        background = {
            enabled = true,
            color = "#1e1e2e",
        },

        padding = {
            top = 0,
            bottom = 0,
            left = 2,
            right = 2,
        },
    },
})
```

---

## High-Contrast Static Border Layout

```lua
require('fk_markdown').setup({
    code = {
        style = 'compact',

        background = {
            enabled = true,
            color = "#11111b",
        },

        border = {
            enabled = true,
            type = "static",
            color = "#fab387",
        },

        title = {
            enabled = true,
            type = "static",
            color = "#cdd6f4",
        },

        padding = {
            top = 1,
            bottom = 1,
            left = 2,
            right = 4,
        },
    },
})
```

---

## Dynamic Language-Aware Layout

```lua
require('fk_markdown').setup({
    code = {
        enabled = true,
        style = 'wide',

        background = {
            enabled = false,
            color = "#181825",
        },

        padding = {
            top = 1,
            bottom = 1,
            left = 1,
            right = 2,
        },

        border = {
            enabled = true,
            type = "dynamic",
        },

        title = {
            enabled = true,
            type = "dynamic",
        },

        icon = {
            enabled = true,
            pill = true,
            pill_style = 'wide',
        },
    },
})
```

---

# 📋 Option Reference

| Option | Type | Default | Description |
|---|---|---|---|
| `enabled` | `boolean` | `true` | Enable code rendering |
| `style` | `string` | `'wide'` | Code block layout |
| `background.enabled` | `boolean` | `false` | Enable background fill |
| `background.color` | `string` | `#181825` | Code block background color |
| `padding.top` | `integer` | `1` | Empty lines above code |
| `padding.bottom` | `integer` | `1` | Empty lines below code |
| `padding.left` | `integer` | `1` | Left spacing |
| `padding.right` | `integer` | `2` | Right spacing |
| `border.enabled` | `boolean` | `true` | Enable code block border |
| `border.type` | `string` | `'dynamic'` | Dynamic or static border |
| `border.color` | `string` | `#f38ba8` | Static border color |
| `title.enabled` | `boolean` | `true` | Show language title |
| `title.type` | `string` | `'dynamic'` | Dynamic or static title |
| `title.color` | `string` | `#a6e3a1` | Static title color |
| `icon.enabled` | `boolean` | `true` | Show language icon |
| `icon.pill` | `boolean` | `true` | Enable title/icon pill |
| `icon.pill_style` | `string` | `'wide'` | Pill layout |
| `sign` | `boolean` | `true` | Show sign-column indicator |
| `conceal_delimiters` | `boolean` | `true` | Hide Markdown delimiters |
| `disable` | `string[]` | `{}` | Disable rendering for languages |
| `disable_background` | `boolean/string[]` | `{'diff'}` | Disable backgrounds |
| `inline` | `boolean` | `true` | Enable inline code styling |
| `inline_left` | `string` | `""` | Left inline-code symbol |
| `inline_right` | `string` | `""` | Right inline-code symbol |
| `inline_pad` | `integer` | `0` | Inline-code padding |
| `priority` | `integer` | `140` | Background highlight priority |

---

# 💡 Recommended Configuration

A balanced configuration with dynamic language-aware styling:

```lua
require('fk_markdown').setup({
    code = {
        enabled = true,
        style = 'wide',

        background = {
            enabled = false,
            color = "#181825",
        },

        padding = {
            top = 1,
            bottom = 1,
            left = 1,
            right = 2,
        },

        border = {
            enabled = true,
            type = "dynamic",
        },

        title = {
            enabled = true,
            type = "dynamic",
        },

        icon = {
            enabled = true,
            pill = true,
            pill_style = 'wide',
        },
    },
})
```

> [!TIP]
> Use `dynamic` mode when you want code blocks to automatically reflect the
> programming language's DevIcon colors. Use `static` mode when you want a
> consistent visual style across all languages.
