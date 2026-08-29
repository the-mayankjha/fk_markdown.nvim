-- FkMarkdown LaTeX Health Check
-- Opens in a scratch split buffer with highlighted diagnostics.

local M = {}

---@param lines string[]
---@param line string
---@param hl? string  highlight group name
local function add(lines, line, hl)
    lines[#lines + 1] = { text = line, hl = hl }
end

---@param lines string[]
---@param ok boolean
---@param label string
---@param detail? string
local function check(lines, ok, label, detail)
    local icon = ok and "✓" or "✗"
    local hl = ok and "DiagnosticOk" or "DiagnosticError"
    local text = "  " .. icon .. " " .. label
    if detail then text = text .. "  (" .. detail .. ")" end
    add(lines, text, hl)
end

---Run the health check and display results in a split buffer.
function M.run()
    local kitty = require('fk_markdown.latex.kitty')
    local backend = require('fk_markdown.latex.backend')

    -- Gather state config (may not exist if setup hasn't run)
    local config = nil
    pcall(function()
        config = require('fk_markdown.state').config.latex
    end)

    local lines = {} ---@type {text: string, hl: string|nil}[]

    -- ── Header ───────────────────────────────────────────────────────────
    add(lines, "")
    add(lines, "╔══════════════════════════════════════════════╗", "Title")
    add(lines, "║       FkMarkdown LaTeX Health Check          ║", "Title")
    add(lines, "╚══════════════════════════════════════════════╝", "Title")
    add(lines, "")

    -- ── Terminal ─────────────────────────────────────────────────────────
    add(lines, "Terminal", "Bold")
    add(lines, string.rep("─", 46), "NonText")
    local term = vim.env.TERM or "(unset)"
    local term_program = vim.env.TERM_PROGRAM or "(unset)"
    add(lines, "  TERM:         " .. term)
    add(lines, "  TERM_PROGRAM: " .. term_program)
    check(lines, kitty.is_supported(), "Unicode placeholders (Kitty/Ghostty)",
        kitty.is_supported() and "supported" or "need Kitty >= 0.28 or Ghostty")
    check(lines, vim.o.termguicolors, "termguicolors",
        vim.o.termguicolors and "required so image id is encoded in guifg"
            or "enable 'termguicolors' — placeholder image ids will not bind")
    add(lines, "")

    -- ── External Dependencies ────────────────────────────────────────────
    add(lines, "External Dependencies", "Bold")
    add(lines, string.rep("─", 46), "NonText")

    local deps = {
        { "curl",          "Network backend (CodeCogs API)" },
        { "node",          "Local MathJax backend" },
        { "rsvg-convert",  "SVG → PNG conversion (librsvg)" },
        { "utftex",        "Text-based LaTeX → Unicode" },
        { "latex2text",    "Text-based LaTeX → Unicode (fallback)" },
    }
    for _, dep in ipairs(deps) do
        local cmd, desc = dep[1], dep[2]
        local found = vim.fn.executable(cmd) == 1
        local version = ""
        if found then
            local out = vim.fn.system({ cmd, "--version" })
            version = vim.split(out, "\n")[1] or ""
            if #version > 50 then version = version:sub(1, 50) .. "…" end
        end
        check(lines, found, cmd, found and desc .. " — " .. version or desc)
    end
    add(lines, "")

    -- ── Backend Resolution ───────────────────────────────────────────────
    add(lines, "Backend Resolution", "Bold")
    add(lines, string.rep("─", 46), "NonText")

    if config then
        add(lines, "  Configured render_method: " .. (config.render_method or "text"))
        add(lines, "  Configured backend:       " .. (config.backend or "auto"))
        add(lines, "  Cache directory:           " .. (config.cache_dir or "(none)"))

        local resolved = backend.resolve(config)
        if resolved then
            check(lines, true, "Resolved backend: " .. resolved)
        else
            check(lines, false, "No image backend available — falling back to text rendering")
        end

        -- Check cache dir
        if config.cache_dir then
            local exists = vim.fn.isdirectory(config.cache_dir) == 1
            if exists then
                local count = #(vim.fn.glob(config.cache_dir .. "/*.png", false, true))
                check(lines, true, "Cache directory exists", count .. " cached images")
            else
                add(lines, "  Cache directory does not exist yet (will be created on first render)")
            end
        end
    else
        check(lines, false, "LaTeX config not loaded — run require('fk_markdown').setup() first")
    end
    add(lines, "")

    -- ── Effective Behavior ───────────────────────────────────────────────
    add(lines, "Effective Behavior", "Bold")
    add(lines, string.rep("─", 46), "NonText")

    local kitty_ok = kitty.is_supported()
    local backend_ok = config and backend.resolve(config) ~= nil
    local text_ok = false
    pcall(function()
        local env = require('fk_markdown.lib.env')
        text_ok = #env.commands(config.converter) > 0
    end)

    if kitty_ok and backend_ok then
        check(lines, true, "Image rendering active",
            "LaTeX → PNG → Kitty Unicode Placeholders")
    elseif text_ok then
        check(lines, true, "Text rendering active",
            "LaTeX → Unicode via " .. (config and type(config.converter) == "table"
                and table.concat(config.converter, "/") or "converter"))
    else
        check(lines, false, "No rendering available",
            "Install utftex/latex2text for text, or curl/node+rsvg for images")
    end

    if config then
        add(lines, "")
        add(lines, "  anticonceal:     " .. tostring(config.anticonceal))
        add(lines, "  hide_on_insert:  " .. tostring(config.hide_on_insert))
        add(lines, "  dynamic_scale:   " .. tostring(config.dynamic_scale))
        add(lines, "  update_interval: " .. tostring(config.update_interval) .. "ms")
    end

    add(lines, "")
    add(lines, string.rep("═", 46), "NonText")

    -- ── Render into a split buffer ───────────────────────────────────────
    vim.cmd("botright new")
    local buf = vim.api.nvim_get_current_buf()
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
    vim.bo[buf].filetype = "fk_health"
    vim.api.nvim_buf_set_name(buf, "FkMarkdown LaTeX Health")

    local text_lines = {}
    for _, l in ipairs(lines) do
        text_lines[#text_lines + 1] = l.text
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, text_lines)

    -- Apply highlights
    local ns = vim.api.nvim_create_namespace("fk_health")
    for i, l in ipairs(lines) do
        if l.hl then
            vim.api.nvim_buf_add_highlight(buf, ns, l.hl, i - 1, 0, -1)
        end
    end

    vim.bo[buf].modifiable = false

    -- Keymap: q to close
    vim.keymap.set("n", "q", "<cmd>bdelete<cr>", { buffer = buf, silent = true })
end

return M
