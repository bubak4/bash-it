# CLAUDE.md — Doom Emacs private config (`~/.doom.d`)

## Literate config — edit the `.org`, never the `.el`
The `.el` files are tangled output and gitignored (`config.el`, `my-config.el`).

- `init.el` — Doom module selection (the `doom!` block).
- `config.org` → `config.el` (Doom `:config literate`): minimal; loads `my-config.org` at the end.
- `my-config.org` → `my-config.el` (via `org-babel-load-file`): **the bulk of the config — edit here.**
- `packages.el` — `package!` declarations; run `doom sync` after editing.

Apply a change: edit the `.org`, restart Emacs (re-tangles when the `.org` is newer; delete the
stale `.el` if it seems ignored).

## Conventions
- Org inline markup: `=verbatim=`, not `~code~`.
- Configure Doom-module / built-in packages (org, magit, company, treemacs, …) with `after!`, **not**
  `use-package! … :config` — the latter forces an eager `require` that can break startup. Reserve
  `use-package!` for packages you declare in `packages.el` (with a defer trigger).
- Upgrade breakage is usually a renamed/removed API — fix the name at the failing form.

## Doom install (3.0-dev, master)
Core is `~/.emacs.d`; modules are a git submodule (`doomemacs/modules`) at `~/.emacs.d/sources/doom+`.
An empty submodule → missing packages/themes and `doom` CLI errors. Fix:
`git -C ~/.emacs.d submodule update --init --recursive && doom sync` (`~/.emacs.d/upgrade.sh` does this).
Don't run `doom purge` while the module tree is missing — it deletes the module packages.
