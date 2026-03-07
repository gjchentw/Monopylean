# Monopylean

Monopylean 是一個用來快速建立新 Lean 專案的模板（template）專案。
它的設計目標是讓你在以下環境都能順暢完成專案啟動：

- GitHub Codespaces（建議）
- 乾淨的 Debian（Trixie）環境（不使用 Docker）

核心目標很簡單：以最少的環境摩擦，快速開始新的 Lean 專案。

## 透過此 Template 建立 `MyLeanProof`

當 Monopylean 已啟用為 GitHub Template Repository 後，你可以這樣建立新專案：

1. 開啟 GitHub 上的 Monopylean repository 頁面。
2. 點擊 `Use this template`。
3. 選擇 `Create a new repository`。
4. 將 repository 名稱設定為 `MyLeanProof`。
5. 建立 repository。

以下所有範例皆以 `MyLeanProof` 作為教學專案名稱。

## 快速開始（30 秒）

### 在 GitHub Codespaces

在 Codespaces 開啟你由 template 建立的 repository（`MyLeanProof`），然後執行：

```bash
make standalone
```

或

```bash
make mathlib
```

### 在 Debian Trixie（不使用 Docker）

```bash
sudo apt update && sudo apt install -y \
  git curl ca-certificates bash make \
  texlive-latex-recommended texlive-latex-extra texlive-science \
  texlive-pictures texlive-pstricks texlive-xetex texlive-luatex \
  texlive-fonts-recommended texlive-fonts-extra \
  fonts-noto-cjk texlive-lang-chinese \
  python3 python3-dev python3-venv python3-pip \
  ghostscript graphviz-dev
git clone https://github.com/<your-account>/MyLeanProof.git
cd MyLeanProof
curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s -- -y
source "$HOME/.profile"
python3 -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt
make standalone
```

若你要使用 Mathlib 模式，請改用 `make mathlib`。

## 這個 Template 預期的環境是什麼？

專案預期環境定義在 `.devcontainer/devcontainer.json`。

根據該檔案，Monopylean 預期：

- 以 Debian 為基礎的開發容器映像（由 `.devcontainer/Dockerfile` 建置）
- 此工作區的 VS Code 設定：
  - 整合終端機預設開在 `/workspaces/<repo-name>`
  - Linux 預設終端機 profile 為 `bash`
  - Python 解譯器路徑為 `.venv/bin/python`
- VS Code extensions：
  - `leanprover.lean4`
  - `James-Yu.latex-workshop`
  - `ms-python.python`
- 建立容器後自動執行命令（post-create）：
  - `python3 -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt`

## GitHub Codespaces 環境準備

在 Codespaces 中，devcontainer 會自動完成環境準備：

1. 在 GitHub Codespaces 開啟你由 template 建立的 repository（`MyLeanProof`）。
2. 等待容器建置與啟動。
3. `postCreateCommand` 會自動建立 `.venv` 並安裝 Python 相依套件。
4. 直接使用 Makefile targets 開始開發。

在一般 Codespaces 流程中，不需要額外安裝主機端套件。

## 乾淨 Debian Trixie 環境安裝（不使用 Docker）

如果你使用的是全新 Debian Trixie，請依序執行以下步驟。

### 1) 安裝基礎套件

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

### 2) Clone 專案

```bash
git clone https://github.com/<your-account>/MyLeanProof.git
cd MyLeanProof
```

### 3) 安裝 Lean toolchain 管理器（elan）

```bash
curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s -- -y
source "$HOME/.profile"
```

### 4) 建立 Python 虛擬環境並安裝 requirements

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 5) 驗證工具

```bash
elan --version
lake --version
```

完成後，你就可以開始初始化與建置 `MyLeanProof` Lean 專案。

## 建立與管理 `MyLeanProof`（Makefile Targets）

### 初始化 Standalone 專案

```bash
make standalone
```

對 `MyLeanProof` 而言，這會將專案初始化或轉換為 standalone 模式。

它會執行：

- 確保 standalone Lean toolchain（`leanprover/lean4:stable`）
- 必要時初始化專案，或將既有專案從 Mathlib 轉為 Standalone
- 更新相依套件並建置

### 初始化 Mathlib 專案

```bash
make mathlib
```

對 `MyLeanProof` 而言，這會將專案初始化或轉換為 Mathlib 模式。

它會執行：

- 確保 Mathlib toolchain（`leanprover-community/mathlib4:lean-toolchain`）
- 必要時初始化專案，或將既有專案從 Standalone 轉為 Mathlib
- 更新相依套件、嘗試下載 Mathlib 快取，並建置

### 清理專案

```bash
make clean
```

它會執行：

- 清除 Lake 建置產物
- 移除 `.lake/build/lib/mathlib` 下的 Mathlib 快取

### 建置專案

```bash
make
```

或

```bash
make lake
```

它會執行：

- 使用 `lake build` 建置 `MyLeanProof`

## 其他實用命令

```bash
make help
make status
make update-toolchain
```

`make status` 可用來確認目前 toolchain，以及 `lakefile.lean` 是否包含 Mathlib 相依。