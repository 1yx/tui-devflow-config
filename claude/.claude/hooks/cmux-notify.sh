#!/bin/bash
# ~/.claude/hooks/cmux-notify.sh
# cmux 环境检测 + 通知脚本
# 由 claude hooks 触发

SOCK="${CMUX_SOCKET_PATH:-/tmp/cmux.sock}"

# 检测 cmux 是否可用
if ! [ -S "$SOCK" ] || ! command -v cmux &>/dev/null; then
    exit 0
fi

# 根据事件类型发送不同通知
EVENT="$1"
TOOL_NAME="$2"

case "$EVENT" in
    Stop)
        cmux notify --title "claude" --body "任务完成，请 review"
        ;;
    PostToolUse)
        if [ "$TOOL_NAME" = "Task" ]; then
            cmux notify --title "claude" --body "子任务完成"
        fi
        ;;
esac
