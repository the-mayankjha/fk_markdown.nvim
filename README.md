# 🌟 fk_markdown.nvim

A highly polished, aesthetically driven Markdown renderer for Neovim. 

`fk_markdown.nvim` is a specialized reimagining of the fantastic [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim), rebuilt to provide **Notion-like code blocks**, fully dynamic **DevIcon coloring**, granular **padding controls**, and beautifully bounded **callouts** right out of the box.

## ✨ Features

* **Beautiful Bounded Code Blocks:** Say goodbye to flat backgrounds. Code blocks are rendered as enclosed terminal-style boxes (`╭──╮`, `│`, `╰──╯`) with sleek overlay language tabs.
<img width="1470" height="921" alt="image" src="https://github.com/user-attachments/assets/98cfea38-4622-476e-9531-2d7544cca06d" />
<em>Code block with transparent wide style<em>

* **Dynamic DevIcon Inheritance:** Code block borders and titles automatically adapt their colors to match the specific language's `nvim-web-devicons` color (e.g., Python blocks have blue/yellow borders, Java gets red, etc.).
* **Absolute Padding Control:** Add virtual blank lines inside your code blocks using `top`, `bottom`, `left`, and `right` padding configurations. No more cramped code!
* **Notion-Style Callouts:** Blockquotes are transformed into gorgeous, customizable callout boxes with solid left-accent borders and customizable backgrounds.
<img width="1176" height="754" alt="image" src="https://github.com/user-attachments/assets/7cb30408-487b-4f5e-83d9-4bf05a78c26e" />
<em>Callouts with boxy style and background transparent</em>

* **Custom Gradient Headings:** Full control over `H1` through `H6` foregrounds, backgrounds, and custom indicator icons.
* **Modular Configuration:** A completely refactored, deeply nested configuration schema that is logical and easy to maintain.

## 🚀 Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
return {
    "the-mayankjha/fk_markdown.nvim", -- Replace with actual repo if hosted
    dir = "~/fk_markdown.nvim",       -- Or load locally
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        require("fk_markdown").setup({
            -- Add your custom configuration here
        })
    end
}
```

## ⚙️ Configuration

`fk_markdown.nvim` comes with a powerful, nested configuration schema that gives you absolute control over how Markdown elements are painted to your screen. 

Please see [CONFIGURATION.md](./CONFIGURATION.md) for a comprehensive guide on customizing Headings, Code Blocks, and Quotes.

## 🙏 Acknowledgements

This plugin serves as a highly customized interface and renderer built on top of the robust core engine provided by [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim). Massive thanks to its creators and contributors!
