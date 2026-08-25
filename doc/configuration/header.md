# 󰲡 Header Configuration

Configure how Markdown headings (`#`, `##`, `###`, etc.) are rendered in `fk_markdown.nvim`.

The `heading` configuration provides control over heading icons, colors, backgrounds, spacing, borders, and other rendering options.

---

## ⚙️ Custom Wrapper Options

These options are provided directly by `fk_markdown.nvim`.

### `enabled`

* **Type:** `boolean`
* **Default:** `true`

Enables or disables custom heading rendering.

```lua
heading = {
    enabled = true,
}
```

---

### `icon`

* **Type:** `boolean`
* **Default:** `true`

Controls whether custom heading icons are displayed.

When enabled, `fk_markdown.nvim` replaces the native Markdown heading markers with configurable icons.

#### Custom Icons vs Native Markers

|                                               `icon = true`                                              |                                              `icon = false`                                              |
| :------------------------------------------------------------------------------------------------------: | :------------------------------------------------------------------------------------------------------: |
| <img src="https://github.com/user-attachments/assets/3dae25cc-7792-41a5-ba95-e9f77324436e" width="100%"> | <img src="https://github.com/user-attachments/assets/82147aba-cd5e-4ae7-893b-a7e8ad8c5c33" width="100%"> |
|                                           Custom heading icons                                           |                                            Native `#` markers                                            |

#### Enable Custom Icons

```lua
heading = {
    enabled = true,
    icon = true,

    icons = {
        '󰲡 ',
        '󰲣 ',
        '󰲥 ',
        '󰲧 ',
        '󰲩 ',
        '󰲫 ',
    },
}
```

The icons correspond to heading levels H1 through H6:

```text
H1 → 󰲡
H2 → 󰲣
H3 → 󰲥
H4 → 󰲧
H5 → 󰲩
H6 → 󰲫
```

#### Use Native Markdown Markers

Set `icon = false` to disable custom icons and retain the standard Markdown markers.

```lua
heading = {
    enabled = true,
    icon = false,
}
```

This preserves the native Markdown syntax:

```markdown
# Heading 1
## Heading 2
### Heading 3
```

---

## 🎨 Background

The `background` configuration controls heading background fills and foreground text colors.

Background rendering is disabled by default.

### Background Comparison

|                                            Background Disabled                                           |                                            Background Enabled                                            |
| :------------------------------------------------------------------------------------------------------: | :------------------------------------------------------------------------------------------------------: |
| <img src="https://github.com/user-attachments/assets/80a2b578-f889-4e89-a3ab-80fac2c3cf19" width="100%"> | <img src="https://github.com/user-attachments/assets/397335f8-94fb-4bbc-abe3-c1c8903c27e1" width="100%"> |
|                                       `background.enabled = false`                                       |                                        `background.enabled = true`                                       |

### `background.enabled`

* **Type:** `boolean`
* **Default:** `false`

Enables or disables heading background rendering.

```lua
heading = {
    enabled = true,

    background = {
        enabled = true,
    },
}
```

To disable backgrounds:

```lua
heading = {
    enabled = true,

    background = {
        enabled = false,
    },
}
```

### `background.bg_color`

* **Type:** `string[]`
* **Default:** `"#1e1e2e"` for all heading levels

Defines the background color for each heading level from H1 through H6.

```lua
background = {
    enabled = true,

    bg_color = {
        "#dce7ff", -- H1
        "#ffe4d6", -- H2
        "#e4f3df", -- H3
        "#d9f4f0", -- H4
        "#eee4ff", -- H5
        "#eee4ff", -- H6
    },
}
```

### `background.font_color`

* **Type:** `string[]`

Defines the foreground color for each heading level.

```lua
background = {
    font_color = {
        "#1e66f5", -- H1
        "#fe640b", -- H2
        "#40a02b", -- H3
        "#179299", -- H4
        "#8839ef", -- H5
        "#8839ef", -- H6
    },
}
```

### Complete Background Configuration

```lua
heading = {
    enabled = true,

    background = {
        enabled = true,

        bg_color = {
            "#dce7ff",
            "#ffe4d6",
            "#e4f3df",
            "#d9f4f0",
            "#eee4ff",
            "#eee4ff",
        },

        font_color = {
            "#1e66f5",
            "#fe640b",
            "#40a02b",
            "#179299",
            "#8839ef",
            "#8839ef",
        },
    },
}
```

---

# 🔄 Inherited Engine Options

The following options are inherited from the underlying heading renderer and can be configured directly inside the `heading` table.

## `position`

* **Type:** `'overlay' | 'inline' | 'right' | 'eol'`
* **Default:** `'overlay'`

Controls where custom heading icons are positioned.

| Position  | Description                                         |
| --------- | --------------------------------------------------- |
| `overlay` | Places the icon over the native `#` marker          |
| `inline`  | Places the icon at the beginning of the heading     |
| `right`   | Places the icon immediately after the heading text  |
| `eol`     | Places the icon at the far-right edge of the buffer |

```lua
heading = {
    icon = true,
    position = 'inline',
}
```

---

## `width`

* **Type:** `'full' | 'block' | ('full' | 'block')[]`
* **Default:** `'full'`

Controls the width of heading backgrounds.

|      `full`     |        `block`        |
| :-------------: | :-------------------: |
| Full line width | Heading content width |

### Full Width

```lua
heading = {
    width = 'full',
}
```

### Block Width

```lua
heading = {
    width = 'block',
}
```

Block width is useful for compact heading layouts where the background should only span the visual width of the heading.

---

## `border`

* **Type:** `boolean | boolean[]`
* **Default:** `false`

Adds horizontal borders above and below headings.

### All Headings

```lua
heading = {
    border = true,
}
```

### Individual Heading Levels

```lua
heading = {
    border = {
        true,  -- H1
        true,  -- H2
        false, -- H3
        false, -- H4
        false, -- H5
        false, -- H6
    },
}
```

---

## `above` / `below`

* **Type:** `string`
* **Default:** `'▄'` / `'▀'`

Defines the characters used to render heading borders.

```lua
heading = {
    above = '─',
    below = '─',
}
```

---

## `border_prefix`

* **Type:** `boolean`
* **Default:** `false`

When enabled, the beginning of the border is rendered using the heading foreground color.

```lua
heading = {
    border_prefix = true,
}
```

---

## `border_virtual`

* **Type:** `boolean`
* **Default:** `false`

Forces heading borders to use virtual lines instead of overlaying empty buffer lines.

```lua
heading = {
    border_virtual = true,
}
```

---

## `left_margin`

* **Type:** `number | number[]`
* **Default:** `0`

Controls the margin before the heading.

```lua
heading = {
    left_margin = 1,
}
```

Floating-point values below `1` can be used to specify a percentage of the window width.

---

## `left_pad`

* **Type:** `number | number[]`
* **Default:** `0`

Adds padding between the start of the heading area and the heading content.

```lua
heading = {
    left_pad = 2,
}
```

---

## `right_pad`

* **Type:** `number | number[]`
* **Default:** `0`

Adds padding after the heading content.

This is especially useful with:

```lua
heading = {
    width = 'block',
    right_pad = 2,
}
```

---

## `min_width`

* **Type:** `integer | integer[]`
* **Default:** `0`

Defines the minimum width of a heading background when using `width = 'block'`.

```lua
heading = {
    width = 'block',
    min_width = 30,
}
```

---

# 󰫎 Sign Column

## `sign`

* **Type:** `boolean`
* **Default:** `true`

Controls whether heading indicators are displayed in the sign column.

```lua
heading = {
    sign = true,
}
```

Disable them with:

```lua
heading = {
    sign = false,
}
```

---

## `signs`

* **Type:** `string[]`
* **Default:** `{ '󰫎 ' }`

Defines the characters used for heading indicators.

```lua
heading = {
    signs = {
        '󰫎 ',
    },
}
```

---

# 🎯 Custom Heading Styles

The `custom` option allows individual headings to receive custom icons, backgrounds, and foreground colors based on their text.

```lua
heading = {
    custom = {
        {
            pattern = 'Features',
            icon = '✨ ',
            background = 'Special',
            foreground = 'Title',
        },
    },
}
```

### Custom Options

| Option       | Type     | Description                             |
| ------------ | -------- | --------------------------------------- |
| `pattern`    | `string` | Pattern used to match heading text      |
| `icon`       | `string` | Custom icon for the matched heading     |
| `background` | `string` | Highlight group used for the background |
| `foreground` | `string` | Highlight group used for the foreground |

---

# 📝 Configuration Examples

## Minimal Configuration

Use native Markdown markers without custom icons or backgrounds:

```lua
require('fk_markdown').setup({
    heading = {
        enabled = true,
        icon = false,

        background = {
            enabled = false,
        },
    },
})
```

---

## Custom Icons and Colors

Use custom icons with per-level foreground colors:

```lua
require('fk_markdown').setup({
    heading = {
        enabled = true,
        icon = true,

        icons = {
            '󰲡 ', '󰲣 ', '󰲥 ',
            '󰲧 ', '󰲩 ', '󰲫 ',
        },

        background = {
            enabled = false,

            font_color = {
                "#1e66f5",
                "#fe640b",
                "#40a02b",
                "#179299",
                "#8839ef",
                "#8839ef",
            },
        },
    },
})
```

---

## Custom Icons with Pastel Backgrounds

Enable per-level backgrounds for a more visually prominent Markdown layout:

```lua
require('fk_markdown').setup({
    heading = {
        enabled = true,
        icon = true,

        icons = {
            '󰲡 ', '󰲣 ', '󰲥 ',
            '󰲧 ', '󰲩 ', '󰲫 ',
        },

        background = {
            enabled = true,

            bg_color = {
                "#dce7ff",
                "#ffe4d6",
                "#e4f3df",
                "#d9f4f0",
                "#eee4ff",
                "#eee4ff",
            },

            font_color = {
                "#1e66f5",
                "#fe640b",
                "#40a02b",
                "#179299",
                "#8839ef",
                "#8839ef",
            },
        },
    },
})
```

---

## Block-Width Headers with Borders

Create compact headers with selective borders:

```lua
require('fk_markdown').setup({
    heading = {
        enabled = true,

        icons = {
            '➊ ', '➋ ', '➌ ',
            '➍ ', '➎ ', '➏ ',
        },

        width = 'block',
        left_pad = 2,
        right_pad = 2,

        border = {
            true,  -- H1
            true,  -- H2
            false, -- H3
            false, -- H4
            false, -- H5
            false, -- H6
        },

        border_virtual = true,
        above = '─',
        below = '─',

        background = {
            enabled = true,

            bg_color = {
                "#dce7ff",
                "#ffe4d6",
                "NONE",
                "NONE",
                "NONE",
                "NONE",
            },

            font_color = {
                "#1e66f5",
                "#fe640b",
                "#40a02b",
                "#179299",
                "#8839ef",
                "#8839ef",
            },
        },
    },
})
```

---

# 📋 Option Reference

| Option                  | Type                | Default   | Description                     |
| ----------------------- | ------------------- | --------- | ------------------------------- |
| `enabled`               | `boolean`           | `true`    | Enable custom heading rendering |
| `icon`                  | `boolean`           | `true`    | Enable custom heading icons     |
| `icons`                 | `string[]`          | —         | Icons for H1–H6                 |
| `background.enabled`    | `boolean`           | `false`   | Enable heading backgrounds      |
| `background.bg_color`   | `string[]`          | `#1e1e2e` | Background colors for H1–H6     |
| `background.font_color` | `string[]`          | —         | Foreground colors for H1–H6     |
| `position`              | `string`            | `overlay` | Icon placement                  |
| `width`                 | `string`            | `full`    | Heading background width        |
| `border`                | `boolean/boolean[]` | `false`   | Enable heading borders          |
| `above`                 | `string`            | `▄`       | Upper border character          |
| `below`                 | `string`            | `▀`       | Lower border character          |
| `border_prefix`         | `boolean`           | `false`   | Color the border prefix         |
| `border_virtual`        | `boolean`           | `false`   | Use virtual lines for borders   |
| `left_margin`           | `number/number[]`   | `0`       | Left margin                     |
| `left_pad`              | `number/number[]`   | `0`       | Left padding                    |
| `right_pad`             | `number/number[]`   | `0`       | Right padding                   |
| `min_width`             | `integer/integer[]` | `0`       | Minimum block width             |
| `sign`                  | `boolean`           | `true`    | Show heading signs              |
| `signs`                 | `string[]`          | `󰫎`      | Sign-column characters          |
| `custom`                | `table`             | —         | Pattern-specific heading styles |

---

## 💡 Recommended Configuration

The following configuration provides custom heading icons, subtle pastel backgrounds, and per-level accent colors while keeping the rest of the renderer at its defaults.

```lua
require('fk_markdown').setup({
    heading = {
        enabled = true,
        icon = true,

        icons = {
            '󰲡 ', '󰲣 ', '󰲥 ',
            '󰲧 ', '󰲩 ', '󰲫 ',
        },

        background = {
            enabled = true,

            bg_color = {
                "#dce7ff",
                "#ffe4d6",
                "#e4f3df",
                "#d9f4f0",
                "#eee4ff",
                "#eee4ff",
            },

            font_color = {
                "#1e66f5",
                "#fe640b",
                "#40a02b",
                "#179299",
                "#8839ef",
                "#8839ef",
            },
        },
    },
})
```
