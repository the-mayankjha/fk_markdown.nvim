# Purpose

## Overview

`fk_markdown.nvim` is a Neovim plugin designed to provide an enhanced Markdown viewing and rendering experience directly inside the terminal.

The primary purpose of the plugin is to make Markdown documents easier to read without requiring users to leave Neovim or open an external Markdown viewer.

It aims to provide a terminal-friendly rendering experience while preserving the structure and readability of Markdown content.

## Goals

The main goals of `fk_markdown.nvim` are:

* Provide a convenient way to view rendered Markdown directly within Neovim.
* Improve the readability of Markdown documents in the terminal.
* Support common Markdown elements such as headings, paragraphs, lists, code blocks, links, images, and other formatted content.
* Provide LaTeX rendering for mathematical expressions.
* Make Markdown rendering accessible without relying on a separate graphical Markdown application.
* Integrate naturally with the Neovim workflow.

## Terminal-Oriented Rendering

`fk_markdown.nvim` is primarily designed for users who work with Markdown from a terminal-based environment.

The plugin takes advantage of terminal capabilities where available to provide richer rendering, including graphical rendering for supported content.

Because terminal emulators differ in their supported graphics protocols, some rendering features depend on the capabilities of the terminal being used.

## LaTeX Support

A key purpose of the plugin is to provide support for rendering mathematical expressions written using LaTeX.

This allows Markdown documents containing mathematical notation to be viewed in a more readable form directly from Neovim.

For example:

```markdown
Inline math: $E = mc^2$

Block math:

$$
\int_0^\infty e^{-x} dx = 1
$$
```

The plugin provides troubleshooting and health-check functionality specifically for the LaTeX rendering pipeline.

## Image Support

`fk_markdown.nvim` also aims to support image rendering within Markdown documents.

Image rendering is intended to work through terminal graphics capabilities, particularly the Kitty Graphics Protocol.

This allows supported terminal environments to display images without opening an external image viewer.

Image rendering availability therefore depends on the terminal emulator and its supported graphics protocols.

## Neovim Integration

The plugin is intended to fit into a normal Neovim workflow.

Users should be able to work with Markdown files, preview their rendered content, and continue editing without switching between applications.

The project focuses on providing a lightweight and terminal-native alternative to external Markdown preview applications.

## Scope

The project focuses on **rendering and viewing Markdown inside Neovim**.

It is not intended to be:

* A full Markdown editor.
* A replacement for Neovim's built-in editing capabilities.
* A general-purpose document viewer.
* A graphical Markdown application.
* A complete replacement for dedicated browser-based Markdown renderers.

The goal is to provide a practical Markdown rendering experience within the terminal and Neovim environment.

## Future Direction

The project can be extended over time to improve Markdown rendering, terminal compatibility, and support for additional Markdown features.

Potential areas of improvement include:

* More granular styling for different Markdown heading levels.
* Improved image rendering compatibility across terminal emulators.
* Additional diagnostics and health checks for rendering features.
* Broader Markdown syntax support.
* Improved rendering consistency across different terminal environments.

## Summary

The purpose of `fk_markdown.nvim` is to bring a readable and feature-rich Markdown viewing experience into Neovim while remaining focused on the terminal environment.

It combines Markdown rendering, image support, and LaTeX rendering to allow users to read rich Markdown content without leaving their Neovim workflow.
