FROM mcr.microsoft.com/devcontainers/base:trixie

RUN apt-get update && apt-get install -y --no-install-recommends \
    pkg-config dvisvgm \
    # 1. LaTeX 核心與數學基礎 (amsmath, amsthm, amssymb)
    texlive-latex-recommended \
    texlive-latex-extra \
    texlive-science \
    # 2. 數學繪圖的核心 (TikZ/PGF, Circuitikz, PGFPlots)
    texlive-pictures \
    texlive-pstricks \
    # 3. 處理字體與渲染引擎 (XeLaTeX / LuaLaTeX)
    texlive-xetex \
    texlive-luatex \
    # 4. 數學研究常用字體 (包含微積分常用符號與特殊字體)
    texlive-fonts-recommended \
    texlive-fonts-extra \
    # 5. 中文支援 (Noto Sans CJK 用於標註)
    latexmk \
    fonts-noto-cjk \
    texlive-lang-chinese \
    # 6. Python 環境 (用於做圖腳本或 Manim)
    python3 \
    python3-dev \
    python3-venv \
    python3-pip \
    # 7. 輔助工具 (Ghostscript 用於處理 PDF/EPS)
    ghostscript \
    # 8. leanblueprint
    graphviz graphviz-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
