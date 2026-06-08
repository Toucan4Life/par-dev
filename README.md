# par-dev

`par-dev` is the workspace repository for developing the Par language and the VS Code extension together.

The source of truth for the actual products stays in the child repositories:

- `par-lang`
- `par-vscode`

This repository should track workspace-level files plus submodule pointers to those child repositories.

## Clone

Clone the workspace and materialize its child repositories with submodules:

```bash
git clone --recurse-submodules https://github.com/Toucan4Life/par-dev.git
cd par-dev
bash scripts/bootstrap.sh --post-create
```

If you already cloned without `--recurse-submodules`, run:

```bash
git submodule update --init --recursive
bash scripts/bootstrap.sh --post-create
```

## Daily workflow

Make code changes inside `par-lang` or `par-vscode`, then commit and push from that child repository first.

Example for `par-lang`:

```bash
cd par-lang
git status
git add ...
git commit -m "Describe the change"
git push origin HEAD
```

After the child repository has moved forward, record the new submodule pointer in `par-dev`:

```bash
cd ..
git status
git add par-lang par-vscode
git commit -m "Update workspace submodules"
git push origin HEAD
```

## Remotes

The expected child-repository remote layout is:

- `par-lang`: `origin` points to `https://github.com/Toucan4Life/par-lang.git`, `upstream` points to `https://github.com/par-team/par-lang.git`
- `par-vscode`: `origin` points to `https://github.com/Toucan4Life/par-vscode.git`, `upstream` points to `https://github.com/s15n/par-vscode.git`

The root `par-dev` repository should point to `https://github.com/Toucan4Life/par-dev.git`.