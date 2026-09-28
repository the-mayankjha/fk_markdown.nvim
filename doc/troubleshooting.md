# Troubleshooting

This document provides troubleshooting guidance for common issues encountered while using `fk_markdown.nvim`.

The troubleshooting and health-check functionality described here is primarily focused on **LaTeX rendering**, which is the feature currently covered by the plugin's diagnostic checks.

## 1. LaTeX Rendering Is Not Working

If LaTeX expressions are not rendered correctly, first verify that the required dependencies are installed and available in your environment.

### Run the Health Check

`fk_markdown.nvim` provides a health check for LaTeX rendering.

Run the following command inside Neovim:

```vim
:checkhealth fk_markdown
```

The health check reports problems related to the LaTeX rendering environment and can help identify missing or incorrectly configured dependencies.

Follow the reported recommendations before proceeding with manual troubleshooting.



## 2. Verify LaTeX Dependencies

LaTeX rendering requires the appropriate external tools to be installed and accessible through your system's `PATH`.

Verify that the required commands are available from your terminal.

For example:

```bash
which latex
```

or:

```bash
which pdflatex
```

If the command cannot be found, install the required LaTeX distribution and make sure its binary directory is included in your `PATH`.

After modifying your `PATH`, restart Neovim and run the health check again:

```vim
:checkhealth fk_markdown
```



## 3. LaTeX Expression Is Not Rendered

Make sure the expression uses valid LaTeX syntax and the expected Markdown math delimiters.

### Inline Math

```markdown
$E = mc^2$
```

### Block Math

```markdown
$$
E = mc^2
$$
```

If valid expressions are still not rendered, run:

```vim
:checkhealth fk_markdown
```

and check whether the required LaTeX dependencies are detected.



## 4. Image Rendering Is Not Working

Image rendering depends on the capabilities of the terminal emulator.

`fk_markdown.nvim` uses terminal graphics capabilities for rendering images. In particular, image rendering requires support for the **Kitty Graphics Protocol**.

If your terminal does not support the required graphics protocol, images may not be displayed.

### Things to Check

1. Verify that your terminal supports the Kitty Graphics Protocol.
2. Verify that the terminal is configured to allow graphical output.
3. Check whether you are running Neovim inside a compatible terminal environment.
4. Test the same Markdown file in a terminal known to support the required graphics protocol.

Image rendering does not currently have the same dedicated health-check coverage as LaTeX rendering.


## 5. iTerm2 or Alacritty

If you are using iTerm2, Alacritty, or another terminal emulator without the required Kitty Graphics Protocol support, image rendering may not work as expected.

This is a terminal capability limitation rather than necessarily a problem with the plugin configuration.

In such cases, use a terminal emulator with compatible graphics-protocol support if image rendering is required.



## 6. Markdown Renders but Looks Incorrect

If Markdown renders successfully but the visual appearance is different from what you expect, check the supported formatting features and the current rendering limitations.

For example, as of `fk_markdown.nvim` v1.4.2, different Markdown heading levels do not have different text sizes.

The following headings may therefore use the same text size:

```markdown
# Heading 1
## Heading 2
### Heading 3
```

This is a known limitation and is not necessarily a configuration problem.


## 7. Health Check Does Not Report an Image Problem

As of `fk_markdown.nvim` v1.4.2, the plugin's health-check functionality is focused on **LaTeX rendering**.

Therefore, an image-rendering problem may not be reported by:

```vim
:checkhealth fk_markdown
```

If LaTeX passes the health check but images are not displayed, investigate the terminal's graphics-protocol support instead.



## 8. General Debugging Checklist

When troubleshooting a rendering issue, check the following:

1. Confirm that you are using a supported version of `fk_markdown.nvim`.

2. Run:

   ```vim
   :checkhealth fk_markdown
   ```


3. Verify that required external dependencies are installed.

4. Verify that required commands are available in your `PATH`.

5. Confirm that your terminal supports the graphics features required by the content being rendered.

6. Restart Neovim after changing dependencies, environment variables, or terminal configuration.

7. Test with a minimal Markdown document to determine whether the issue is related to the document content or the rendering environment.


## 9. Reporting an Issue

If the problem persists after following the troubleshooting steps, provide enough information to reproduce the issue.

When opening an issue, include:

* `fk_markdown.nvim` version.

* Neovim version.

* Operating system.

* Terminal emulator and version.

* Relevant Markdown content.

* Output of:

  ```vim
  :FkLatexHealth
  ```
  
<img width="1043" height="732" alt="image" src="https://github.com/user-attachments/assets/6bf1a302-c098-4b2d-929a-5baabc8b70f5" />

* A description of the expected behavior.

* A description of the actual behavior.

* Any relevant error messages.

Providing this information makes it easier to identify whether the problem is related to the plugin, an external dependency, or terminal capabilities.

## Version

This troubleshooting guide applies to:

**fk_markdown.nvim v1.4.2**

Troubleshooting procedures and diagnostic support may change in future releases.
