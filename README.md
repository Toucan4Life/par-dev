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

## Run a File in the Extension Host

After launching the `Par VS Code Extension` debug configuration, open the integrated terminal in the Extension Development Host window and run Par from the workspace root:

```bash
par-lang/target/debug/par run --package par-lang/examples HelloWorld
```

This runs `par-lang/examples/src/HelloWorld.par`. The target is the module path, not the `.par` filename, and Par uses the module's `Main` definition by default.

For other files in `par-lang/examples/src`, use the same pattern:

```bash
par-lang/target/debug/par run --package par-lang/examples ModuleName
par-lang/target/debug/par run --package par-lang/examples Nondeterminism/FanIn
```

If you `cd` into `par-lang/examples` first, the equivalent command is:

```bash
../target/debug/par run HelloWorld
```

## Remotes

The expected child-repository remote layout is:

- `par-lang`: `origin` points to `https://github.com/Toucan4Life/par-lang.git`, `upstream` points to `https://github.com/par-team/par-lang.git`
- `par-vscode`: `origin` points to `https://github.com/Toucan4Life/par-vscode.git`, `upstream` points to `https://github.com/s15n/par-vscode.git`

The root `par-dev` repository should point to `https://github.com/Toucan4Life/par-dev.git`.