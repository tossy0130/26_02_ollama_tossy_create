#!/usr/bin/env bash
set -euo pipefail

# この .sh が置かれているディレクトリ＝プロジェクト直下
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
VENV_DIR="$PROJECT_DIR/venv"

OLLAMA_ADDR="127.0.0.1:12000"
STREAMLIT_APP="$PROJECT_DIR/test-3.py"

echo "==> cd $PROJECT_DIR"

cd "$PROJECT_DIR"

# venv 有効化
if [[ ! -f "$VENV_DIR/bin/activate" ]]; then
    echo "ERROR: venv not found: $VENV_DIR"
    exit 1
fi

# venv 起動
source "$VENV_DIR/bin/activate"

# ollama サーバ立ち上げ
if ! command -v ollama >/dev/null 2>&1; then
    echo "ERROR: ollama command not found."
    exit 1
fi

# Ollama がすでに起動中か確認
if curl -s "http://$OLLAMA_ADDR/v1/models" >/dev/null 2>&1; then
    echo "==> Ollama already running on $OLLAMA_ADDR"
    OLLAMA_PID=""
else
    echo "==> start Ollama server on $OLLAMA_ADDR"
    export OLLAMA_HOST="$OLLAMA_ADDR"
    LOGFILE="$PROJECT_DIR/ollama_serve.log"
    nohup ollama serve > "$LOGFILE" 2>&1 &
    OLLAMA_PID=$!

    # 起動待ち（最大30秒）
    for _ in {1..30}; do
        curl -s "http://$OLLAMA_ADDR/v1/models" >/dev/null 2>&1 && break
        sleep 1
    done

    if ! curl -s "http://$OLLAMA_ADDR/v1/models" >/dev/null 2>&1; then
        echo "ERROR: Ollama did not start. Check log: $LOGFILE"
        exit 1
    fi
fi

# Ctrl+C などで終了したら、スクリプトが起動した Ollama も止める
cleanup() {
    if [[-n "${OLLAMA_PID:-}"]]; then
        echo ""
        echo "==> stopping Ollama (PID: $OLLAMA_PID)"
        kill "$OLLAMA_PID" >/dev/null 2>&1 || true
    fi
}

trap cleanup EXIT INT TERM

export OLLAMA_HOST="$OLLAMA_ADDR"

# streamlit 起動
echo "==> start Streamlit: $STREAMLIT_APP"
exec streamlit run "$STREAMLIT_APP"