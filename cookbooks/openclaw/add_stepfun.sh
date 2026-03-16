#!/bin/bash

# 脚本用途：向 OpenClaw 配置添加 StepFun 3.5 Flash 模型并设为主模型
# 使用方式：
#   sudo -i
#   curl -fsSL https://gh-proxy.com/https://raw.githubusercontent.com/Daiyimo/openclaw-napcat/napcat-qq/add_stepfun.sh | bash

set -e

CONFIG_FILE="$HOME/.openclaw/openclaw.json"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "错误：配置文件不存在: $CONFIG_FILE"
    echo "请确认 OpenClaw 已正确安装"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "错误：需要安装 jq"
    echo "Ubuntu/Debian: apt install jq"
    echo "macOS: brew install jq"
    exit 1
fi

echo "=========================================="
echo "  OpenClaw 配置 - 添加 StepFun 3.5 Flash"
echo "=========================================="
echo ""
echo "请选择接入方式："
echo "  1) OpenRouter 免费版（无需付费，有速率限制 50 RPM）"
echo "  2) StepFun 官方 API（按量计费，需要官方 API Key）"
echo ""

CHOICE=""
while true; do
    read -r -p "请输入数字选择 [1/2]: " CHOICE </dev/tty
    case "$CHOICE" in
        1|2) break ;;
        *) echo "无效输入，请输入 1 或 2" ;;
    esac
done

echo ""

if [ "$CHOICE" = "1" ]; then
    echo "已选择：OpenRouter 免费版"
    echo ""

    OPENROUTER_APIKEY=""
    while true; do
        read -r -p "请输入 OpenRouter API Key（sk-or-v1-...）: " OPENROUTER_APIKEY </dev/tty
        [ -n "$OPENROUTER_APIKEY" ] && break
        echo "API Key 不能为空，请重新输入"
    done

    echo "配置文件: $CONFIG_FILE"
    echo "API Key: ${OPENROUTER_APIKEY:0:15}..."
    echo ""

    cp "$CONFIG_FILE" "${CONFIG_FILE}.bak.$(date +%Y%m%d%H%M%S)"
    echo "已备份原配置文件"

    jq --arg apikey "$OPENROUTER_APIKEY" '
        .models.providers.openrouter = {
            "baseUrl": "https://openrouter.ai/api/v1",
            "apiKey": $apikey,
            "api": "openai-completions",
            "models": [
                {
                    "id": "stepfun/step-3.5-flash:free",
                    "name": "Step 3.5 Flash Free",
                    "api": "openai-completions",
                    "reasoning": true,
                    "input": ["text"],
                    "cost": {
                        "input": 0,
                        "output": 0,
                        "cacheRead": 0,
                        "cacheWrite": 0
                    },
                    "contextWindow": 256000,
                    "maxTokens": 8192
                }
            ]
        } |
        .agents.defaults.model.primary = "openrouter/stepfun/step-3.5-flash:free"
    ' "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"

    echo "=========================================="
    echo "  配置更新完成!"
    echo "=========================================="
    echo "  - 已添加 OpenRouter StepFun 3.5 Flash Free"
    echo "  - 默认模型: openrouter/stepfun/step-3.5-flash:free"
    echo "  - 速率限制: 50 RPM"
    echo "  - 备份文件: ${CONFIG_FILE}.bak.*"

else
    echo "已选择：StepFun 官方 API"
    echo ""

    STEPFUN_APIKEY=""
    while true; do
        read -r -p "请输入 StepFun API Key: " STEPFUN_APIKEY </dev/tty
        [ -n "$STEPFUN_APIKEY" ] && break
        echo "API Key 不能为空，请重新输入"
    done

    echo "配置文件: $CONFIG_FILE"
    echo "API Key: ${STEPFUN_APIKEY:0:10}..."
    echo ""

    cp "$CONFIG_FILE" "${CONFIG_FILE}.bak.$(date +%Y%m%d%H%M%S)"
    echo "已备份原配置文件"

    jq --arg apikey "$STEPFUN_APIKEY" '
        .models.providers.stepfun = {
            "baseUrl": "https://api.stepfun.com/v1",
            "apiKey": $apikey,
            "api": "openai-completions",
            "models": [
                {
                    "id": "stepfun/step-3.5-flash",
                    "name": "Step 3.5 Flash",
                    "api": "openai-completions",
                    "reasoning": false,
                    "input": ["text"],
                    "cost": {
                        "input": 0,
                        "output": 0,
                        "cacheRead": 0,
                        "cacheWrite": 0
                    },
                    "contextWindow": 256000,
                    "maxTokens": 8192
                }
            ]
        } |
        .agents.defaults.model.primary = "stepfun/step-3.5-flash"
    ' "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"

    echo "=========================================="
    echo "  配置更新完成!"
    echo "=========================================="
    echo "  - 已添加 StepFun 3.5 Flash"
    echo "  - 默认模型: stepfun/step-3.5-flash"
    echo "  - 备份文件: ${CONFIG_FILE}.bak.*"
fi
