# Neovim Keymaps Reference

## LSP Navigation (via Snacks)
All `g*` navigation keymaps are handled by Snacks picker for consistent UI:

- `gd` - Goto Definition
- `gD` - Goto Declaration
- `gr` - Goto References
- `gI` - Goto Implementation
- `gy` - Goto Type Definition

## LSP Code Actions
Code modification commands use the `<leader>c` prefix:

- `<leader>cr` - Code Rename (LSP rename)
- `<leader>ca` - Code Action (LSP code action)
- `<leader>cR` - Rename File (Snacks)
- `<leader>f` - Format buffer (Conform)

## LSP Utilities
- `<leader>th` - Toggle Inlay Hints
- `K` - Hover Documentation (LSP)
- `<leader>q` - Open Diagnostic Quickfix List

## File Navigation
- `<leader><space>` - Smart Find Files
- `<leader>,` - Buffers
- `<leader>/` - Grep
- `<leader>e` - File Explorer
- `<leader>ff` - Find Files
- `<leader>fg` - Find Git Files
- `<leader>fb` - Find Buffers
- `<leader>fr` - Recent Files
- `<leader>fc` - Find Config Files

## Search
- `<leader>sg` - Grep
- `<leader>sw` - Search Word Under Cursor
- `<leader>sb` - Search Buffer Lines
- `<leader>sd` - Search Diagnostics
- `<leader>ss` - LSP Symbols
- `<leader>sS` - LSP Workspace Symbols

## Git
- `<leader>gg` - Lazygit
- `<leader>gb` - Git Branches
- `<leader>gl` - Git Log
- `<leader>gs` - Git Status
- `<leader>gd` - Git Diff (Hunks)
- `<leader>gB` - Git Browse (open in browser)
- `]c` / `[c` - Next/Previous Git Change

## Git Hunks
- `<leader>hs` - Stage Hunk
- `<leader>hr` - Reset Hunk
- `<leader>hS` - Stage Buffer
- `<leader>hR` - Reset Buffer
- `<leader>hp` - Preview Hunk
- `<leader>hb` - Blame Line
- `<leader>hd` - Diff Against Index
- `<leader>hD` - Diff Against Last Commit

## Buffers
- `<leader>bd` - Delete Buffer
- `<leader>,` - Buffer List

## Toggles
- `<leader>th` - Toggle Inlay Hints
- `<leader>tb` - Toggle Git Blame Line
- `<leader>tD` - Toggle Git Show Deleted
- `<leader>us` - Toggle Spelling
- `<leader>uw` - Toggle Wrap
- `<leader>ul` - Toggle Line Numbers
- `<leader>uL` - Toggle Relative Numbers
- `<leader>ud` - Toggle Diagnostics
- `<leader>uh` - Toggle Inlay Hints
- `<leader>ub` - Toggle Dark/Light Background

## Utilities
- `<leader>z` - Toggle Zen Mode
- `<leader>Z` - Toggle Zoom
- `<leader>.` - Scratch Buffer
- `<leader>n` - Notification History
- `<leader>un` - Dismiss Notifications
- `<leader>cc` - Open Claude with Current File
- `<c-/>` - Toggle Terminal

## Window Navigation
- `<C-h>` - Move to Left Window
- `<C-j>` - Move to Lower Window
- `<C-k>` - Move to Upper Window
- `<C-l>` - Move to Right Window

## Reference Jump
- `]]` - Next Reference
- `[[` - Previous Reference

## Notes
- All `g*` navigation uses Snacks picker for better UI
- All `<leader>c*` commands are code-related actions
- All `<leader>g*` commands are git-related
- All `<leader>h*` commands are git hunk operations
- All `<leader>t*` commands are toggles
- All `<leader>u*` commands are UI toggles
