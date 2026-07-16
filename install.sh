#!/bin/bash
set -euo pipefail

echo "agentic — AI-powered terminal coding agent"
echo "==========================================="

REQUESTED_VERSION="${AGENTIC_VERSION:-${VERSION:-}}"
REPO="jishenjason-cmd/agentic-releases"
INSTALL_DIR="$HOME/.agentic"
BIN_DIR="$HOME/.local/bin"
BIN_PATH="$BIN_DIR/agentic"

sha256_file() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{ print $1 }'
  elif command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{ print $1 }'
  else
    echo "❌ No SHA256 implementation found (need shasum or sha256sum)." >&2
    return 1
  fi
}

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
if [ -n "$REQUESTED_VERSION" ]; then
  VERSION="v${REQUESTED_VERSION#v}"
  DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${VERSION}/${TARGET}.zip"
else
  VERSION="latest"
  DOWNLOAD_URL="https://github.com/${REPO}/releases/latest/download/${TARGET}.zip"
fi

echo "→ Platform: ${OS}-${ARCH}"
echo "→ Version:  ${VERSION}"

if [ "${AGENTIC_INSTALL_DRY_RUN:-0}" = "1" ]; then
  echo "→ Download: ${DOWNLOAD_URL}"
  exit 0
fi

# ── Download & Install ──────────────────────────

mkdir -p "$INSTALL_DIR/bin"

echo "→ Downloading ${DOWNLOAD_URL}..."
TMP_ZIP=$(mktemp)
TMP_CHECKSUM=$(mktemp)
TMP_DIR=""
cleanup() {
  rm -f "$TMP_ZIP"
  rm -f "$TMP_CHECKSUM"
  if [ -n "$TMP_DIR" ]; then rm -rf "$TMP_DIR"; fi
}
trap cleanup EXIT INT TERM
curl -fsSL "$DOWNLOAD_URL" -o "$TMP_ZIP" || {
  echo "❌ Download failed. Binary not available for ${OS}-${ARCH}."
  echo "   Falling back to source install: clone repo and run with bun."
  exit 1
}

if curl -fsSL "${DOWNLOAD_URL}.sha256" -o "$TMP_CHECKSUM"; then
  EXPECTED_SHA256=$(awk '{ print $1; exit }' "$TMP_CHECKSUM")
  ACTUAL_SHA256=$(sha256_file "$TMP_ZIP")
  if [ -z "$EXPECTED_SHA256" ] || [ "$EXPECTED_SHA256" != "$ACTUAL_SHA256" ]; then
    echo "❌ Release checksum verification failed."
    exit 1
  fi
  echo "   ✓ SHA256 verified"
elif [ "${AGENTIC_REQUIRE_CHECKSUM:-0}" = "1" ]; then
  echo "❌ Release checksum is missing."
  exit 1
else
  echo "⚠️  This legacy release has no checksum asset; continuing for compatibility."
fi

echo "→ Extracting..."
TMP_DIR=$(mktemp -d)
unzip -qo "$TMP_ZIP" -d "$TMP_DIR"
if [ ! -f "$TMP_DIR/agentic" ]; then
  echo "❌ Release archive is invalid: missing agentic binary."
  exit 1
fi
cp "$TMP_DIR/agentic" "$INSTALL_DIR/bin/agentic"
chmod +x "$INSTALL_DIR/bin/agentic"
cleanup
trap - EXIT INT TERM

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

# ── Verify ──────────────────────────────────────

# ── Reload PATH ─────────────────────────────────

SHELL_NAME=$(basename "${SHELL:-}")
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
echo "     Ask Agentic: 如何开启或关闭记忆模块？（按需加载内置 agentic-config skill）"
echo "     export ANTHROPIC_API_KEY=sk-ant-xxx   # or OPENAI/GEMINI/OPENROUTER/MINIMAX"
echo "     # 国产厂商用 OpenAI 兼容模式，例如 DeepSeek:"
echo "     export OPENAI_API_KEY=\$DEEPSEEK_API_KEY"
echo "     export OPENAI_BASE_URL=https://api.deepseek.com/v1"
echo "     # 或写入 ~/.agentmemory/.env 文件（重启生效）"
