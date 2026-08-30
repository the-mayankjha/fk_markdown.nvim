# Limitations

This document describes the known limitations of `fk_markdown.nvim` as of release `1.4.2`.

## 1. Text Size at Different Heading Levels

As of release `1.4.2`, `fk_markdown.nvim` does not support different text sizes for different Markdown heading levels.

For example:

```markdown
# Heading 1
## Heading 2
### Heading 3
```

Currently, the heading level is recognized and rendered, but different heading levels do not have independently configurable text sizes.

### Current Status

* Different text sizes for `#`, `##`, `###`, and other heading levels are not supported.
* Heading levels are still recognized and rendered as headings.
* Support for level-specific text sizing may be added in a future release.



## 2. Image and LaTeX Rendering

As of release `1.4.2`, image and LaTeX rendering depends on terminal capabilities.

`fk_markdown.nvim` requires a terminal with support for the Kitty Graphics Protocol to render graphical content such as images.

Terminals that do not support the Kitty Graphics Protocol may not be able to render images correctly. This includes terminals such as iTerm2 and Alacritty when the required graphics protocol is not available.

### Current Status

* Image rendering is not supported in terminals without Kitty Graphics Protocol support.
* LaTeX rendering may also be unavailable when the terminal cannot display the required graphical output.
* Rendering support depends on the capabilities of the terminal emulator being used.



## 3. Troubleshooting and Health Check

As of release `1.4.2`, the built-in troubleshooting and health-check functionality is available only for **LaTeX rendering**.

The health check can be used to verify the dependencies and configuration required for LaTeX rendering.

Currently:

* LaTeX rendering has dedicated troubleshooting support.
* LaTeX rendering has a corresponding health check.
* Image rendering does not currently have a dedicated troubleshooting or health-check mechanism.
* Terminal capability detection for image rendering is not currently covered by the health check.

Additional troubleshooting and health checks for other rendering features may be introduced in future releases.



## Version

These limitations apply to:

**fk_markdown.nvim v1.4.2**

The limitations described above may be addressed or changed in future releases.

For more information, refer to the project repository:

[fk_markdown.nvim on GitHub](https://github.com/the-mayankjha/fk_markdown.nvim?utm_source=chatgpt.com)
