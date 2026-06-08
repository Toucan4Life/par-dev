#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
POST_CREATE=0

usage() {
    cat <<'EOF'
Usage: scripts/bootstrap.sh [--post-create]

Materializes the Par language and VS Code extension repositories for this parent
workspace, then ensures each repo has the expected upstream remote.

When the workspace root is a Git superproject with submodules configured, this
script initializes or updates those submodules. Otherwise it falls back to
cloning the repositories directly into the workspace.

Options:
  --post-create  Also install extension dependencies and build the language repo.
  --help         Show this help.
EOF
}

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Missing required command: $1" >&2
        exit 1
    fi
}

clone_repo() {
    local repo_name="$1"
    local origin_url="$2"
    local repo_dir="$ROOT_DIR/$repo_name"

    if [ -d "$repo_dir/.git" ]; then
        echo "Using existing $repo_name checkout"
        return
    fi

    if [ -e "$repo_dir" ]; then
        echo "Cannot clone $repo_name because $repo_dir already exists and is not a Git repository." >&2
        exit 1
    fi

    echo "Cloning $repo_name"
    git clone "$origin_url" "$repo_dir"
}

has_submodule_config() {
    local repo_name="$1"
    local configured_path=""

    if [ ! -d "$ROOT_DIR/.git" ] || [ ! -f "$ROOT_DIR/.gitmodules" ]; then
        return 1
    fi

    configured_path="$(git -C "$ROOT_DIR" config --file .gitmodules --get "submodule.$repo_name.path" 2>/dev/null || true)"
    [ "$configured_path" = "$repo_name" ]
}

materialize_repo() {
    local repo_name="$1"
    local origin_url="$2"

    if has_submodule_config "$repo_name"; then
        echo "Initializing $repo_name submodule"
        git -C "$ROOT_DIR" submodule sync -- "$repo_name"
        git -C "$ROOT_DIR" submodule update --init --recursive -- "$repo_name"
        return
    fi

    clone_repo "$repo_name" "$origin_url"
}

ensure_remote() {
    local repo_name="$1"
    local remote_name="$2"
    local remote_url="$3"
    local repo_dir="$ROOT_DIR/$repo_name"
    local current_url=""

    if git -C "$repo_dir" remote get-url "$remote_name" >/dev/null 2>&1; then
        current_url="$(git -C "$repo_dir" remote get-url "$remote_name")"
        if [ "$current_url" = "$remote_url" ]; then
            return
        fi

        if [ "$remote_name" = "upstream" ]; then
            echo "Updating $repo_name upstream to $remote_url"
            git -C "$repo_dir" remote set-url "$remote_name" "$remote_url"
            return
        fi

        echo "Keeping existing $repo_name $remote_name remote: $current_url"
        return
    fi

    echo "Adding $repo_name $remote_name remote"
    git -C "$repo_dir" remote add "$remote_name" "$remote_url"
}

run_post_create_steps() {
    require_command cargo
    require_command npm

    echo "Installing par-vscode dependencies"
    (
        cd "$ROOT_DIR/par-vscode"
        npm ci
    )

    echo "Building par-lang"
    (
        cd "$ROOT_DIR/par-lang"
        cargo build
    )
}

for arg in "$@"; do
    case "$arg" in
        --post-create)
            POST_CREATE=1
            ;;
        --help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $arg" >&2
            usage >&2
            exit 1
            ;;
    esac
done

require_command git

materialize_repo "par-lang" "https://github.com/Toucan4Life/par-lang.git"
materialize_repo "par-vscode" "https://github.com/Toucan4Life/par-vscode.git"

ensure_remote "par-lang" "upstream" "https://github.com/par-team/par-lang.git"
ensure_remote "par-vscode" "upstream" "https://github.com/s15n/par-vscode.git"

if [ "$POST_CREATE" -eq 1 ]; then
    run_post_create_steps
fi