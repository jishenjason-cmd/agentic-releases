#!/bin/bash
set -e

echo "agentic — AI-powered terminal coding agent"
echo "==========================================="

VERSION="${AGENTIC_VERSION:-v0.4.0}"
REPO="jishenjason-cmd/agentic-releases"
INSTALL_DIR="$HOME/.agentic"
BIN_DIR="$HOME/.local/bin"
BIN_PATH="$BIN_DIR/agentic"

# ── Platform detection ──────────────────────────

OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$OS" in
  darwin)  OS="darwin" ;;
  linux)   OS="linux" ;;
  *)       echo "❌ Unsupported OS: $OS"; exit 1 ;;
esac

case "$ARCH" in
  arm64|aarch64) ARCH="arm64" ;;
  x86_64|amd64)  ARCH="x64" ;;
  *)             echo "❌ Unsupported arch: $ARCH"; exit 1 ;;
esac

TARGET="agentic-${OS}-${ARCH}"
DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${VERSION}/${TARGET}.zip"

echo "→ Platform: ${OS}-${ARCH}"
echo "→ Version:  ${VERSION}"

# ── Download & Install ──────────────────────────

mkdir -p "$INSTALL_DIR/bin"

echo "→ Downloading ${DOWNLOAD_URL}..."
TMP_ZIP=$(mktemp)
curl -fsSL "$DOWNLOAD_URL" -o "$TMP_ZIP" || {
  echo "❌ Download failed. Binary not available for ${OS}-${ARCH}."
  echo "   Falling back to source install: clone repo and run with bun."
  exit 1
}

echo "→ Extracting..."
TMP_DIR=$(mktemp -d)
unzip -qo "$TMP_ZIP" -d "$TMP_DIR"
cp "$TMP_DIR/agentic" "$INSTALL_DIR/bin/agentic"
chmod +x "$INSTALL_DIR/bin/agentic"
rm -rf "$TMP_ZIP" "$TMP_DIR"

# ── CLI Wrapper ─────────────────────────────────

mkdir -p "$BIN_DIR"
ln -sf "$INSTALL_DIR/bin/agentic" "$BIN_PATH"

# ── PATH ────────────────────────────────────────

add_to_rc() {
  local rc="$1"
  if [ -f "$rc" ] && ! grep -q "$BIN_DIR" "$rc" 2>/dev/null; then
    echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$rc"
    echo "   ✓ Added to $rc"
  fi
}
add_to_rc "$HOME/.zshrc"
add_to_rc "$HOME/.bashrc"
add_to_rc "$HOME/.bash_profile"

# ── Config ──────────────────────────────────────

CFG_DIR="$HOME/.config/agentic"
CFG_FILE="$CFG_DIR/agentic.jsonc"
mkdir -p "$CFG_DIR"

if [ ! -f "$CFG_FILE" ]; then
  cat > "$CFG_FILE" << 'CONFIG'
{
  "$schema": "https://opencode.ai/config.json",
  "model": "",
  "provider": {}
}
CONFIG
fi

# ── Reload PATH ─────────────────────────────────

SHELL_NAME=$(basename "$SHELL")
case "$SHELL_NAME" in
  zsh)  RC="$HOME/.zshrc" ;;
  bash) RC="$HOME/.bashrc" ;;
  *)    RC="" ;;
esac

if [ -n "$RC" ] && [ -f "$RC" ]; then
  export PATH="$BIN_DIR:$PATH"
  echo "   ✓ PATH configured ($RC)"
fi

echo ""
if "$BIN_PATH" --version >/dev/null 2>&1; then
  echo "✅ agentic $( $BIN_PATH --version) installed!"
else
  echo "⚠️  Binary not in PATH yet. Run: export PATH=\"$BIN_DIR:\$PATH\""
fi

echo ""
echo "   Usage: agentic"
echo ""
echo "   Configure provider: $CFG_FILE"
echo ""
echo "   Optional — AI memory (agentmemory):"
echo "     export ANTHROPIC_API_KEY=sk-ant-xxx   # or OPENAI/GEMINI/OPENROUTER/MINIMAX"
echo "     # 国产厂商用 OpenAI 兼容模式，例如 DeepSeek:"
echo "     export OPENAI_API_KEY=\$DEEPSEEK_API_KEY"
echo "     export OPENAI_BASE_URL=https://api.deepseek.com/v1"
echo "     # 或写入 ~/.agentmemory/.env 文件（重启生效）"