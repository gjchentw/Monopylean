# Monopylean

Monopylean is a template project for creating new Lean projects quickly.
It is designed to make project bootstrapping smooth in either:

- GitHub Codespaces (recommended)
- A clean Debian (Trixie) environment (without Docker)

The goal is simple: start a new Lean project with minimal setup friction.

## Create `MyLeanProof` from This Template

When Monopylean is enabled as a GitHub Template Repository, create your new project like this:

1. Open the Monopylean repository page on GitHub.
2. Click `Use this template`.
3. Select `Create a new repository`.
4. Set repository name to `MyLeanProof`.
5. Create the repository.

All examples below use `MyLeanProof` as the tutorial project name.

## Quick Start (30 Seconds)

### In GitHub Codespaces

Open your template-generated repository (`MyLeanProof`) in Codespaces, then run:

```bash
make standalone
```

or

```bash
make mathlib
```

### In Debian Trixie (No Docker)

```bash
sudo apt update && sudo apt install -y \
  git curl ca-certificates bash make pkg-config dvisvgm \
  texlive-latex-recommended texlive-latex-extra texlive-science \
  texlive-pictures texlive-pstricks texlive-xetex texlive-luatex \
  texlive-fonts-recommended texlive-fonts-extra \
  latexmk fonts-noto-cjk texlive-lang-chinese \
  python3 python3-dev python3-venv python3-pip \
  ghostscript graphviz graphviz-dev
git clone https://github.com/<your-account>/MyLeanProof.git
cd MyLeanProof
curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s -- -y
source "$HOME/.profile"
python3 -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt
make standalone
```

Use `make mathlib` if you want a Mathlib-based project.

## What Environment Does This Template Expect?

The expected environment is defined in `.devcontainer/devcontainer.json`.

From that file, Monopylean expects:

- A Debian-based development container image (built from `.devcontainer/Dockerfile`)
- VS Code settings for this workspace:
	- Integrated terminal opens at `/workspaces/<repo-name>`
	- Default Linux terminal profile is `bash`
	- Python interpreter path is `.venv/bin/python`
- VS Code extensions:
	- `leanprover.lean4`
	- `James-Yu.latex-workshop`
	- `ms-python.python`
- Post-create bootstrap command:
	- `python3 -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt`

## GitHub Codespaces Setup

In Codespaces, environment setup is handled automatically by the devcontainer:

1. Open your template-generated repository (`MyLeanProof`) in GitHub Codespaces.
2. Wait for container build and startup.
3. The post-create command will create `.venv` and install Python dependencies.
4. Start using Makefile targets directly.

No manual host-side package installation is needed in the normal Codespaces flow.

## Clean Debian Trixie Setup (No Docker)

If you are on a fresh Debian Trixie machine, run the following commands step by step.

### 1) Install base packages

```bash
sudo apt update
sudo apt install -y \
	git curl ca-certificates bash make \
	texlive-latex-recommended texlive-latex-extra texlive-science \
	texlive-pictures texlive-pstricks texlive-xetex texlive-luatex \
	texlive-fonts-recommended texlive-fonts-extra \
	fonts-noto-cjk texlive-lang-chinese \
	python3 python3-dev python3-venv python3-pip \
	ghostscript graphviz-dev
```

### 2) Clone the repository

```bash
git clone https://github.com/<your-account>/MyLeanProof.git
cd MyLeanProof
```

### 3) Install Lean toolchain manager (elan)

```bash
curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s -- -y
source "$HOME/.profile"
```

### 4) Create Python virtual environment and install requirements

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 5) Verify tools

```bash
elan --version
lake --version
```

You are now ready to initialize and build your `MyLeanProof` Lean project.

## Build and Manage `MyLeanProof` (Makefile Targets)

### Initialize Standalone project

```bash
make standalone
```

For `MyLeanProof`, this initializes or converts your project into standalone mode.

What it does:

- Ensures standalone Lean toolchain (`leanprover/lean4:stable`)
- Initializes project if needed, or converts existing project from Mathlib to Standalone
- Runs dependency update and build

### Initialize Mathlib project

```bash
make mathlib
```

For `MyLeanProof`, this initializes or converts your project into Mathlib mode.

What it does:

- Ensures Mathlib toolchain (`leanprover-community/mathlib4:lean-toolchain`)
- Initializes project if needed, or converts existing project from Standalone to Mathlib
- Runs dependency update, tries to fetch Mathlib cache, then builds

### Clean project

```bash
make clean
```

What it does:

- Cleans Lake build artifacts
- Removes cached Mathlib build library under `.lake/build/lib/mathlib`

### Build project

```bash
make
```

or

```bash
make lake
```

What it does:

- Builds `MyLeanProof` with `lake build`

## Useful Commands

```bash
make help
make status
make update-toolchain
```

`make status` is useful to confirm current toolchain and whether `lakefile.lean` contains Mathlib dependency.
