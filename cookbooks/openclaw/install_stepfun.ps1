# 脚本用途：向 OpenClaw 配置添加 StepFun 3.5 Flash 模型并设为主模型
# 使用方式（一行命令，自动提权）：
#   curl -fsSL https://raw.githubusercontent.com/Daiyimo/openclaw-napcat/napcat-qq/install_stepfun.ps1 | iex
#
# 注意：首次运行可能需要设置执行策略：
#   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 设置控制台为 UTF-8 编码，避免中文乱码
chcp 65001 > $null 2>&1
$OutputEncoding = [System.Text.UTF8Encoding]::new()
[Console]::InputEncoding = [System.Text.UTF8Encoding]::new()
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

# 检查是否以管理员身份运行
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "需要管理员权限来修改配置文件。" -ForegroundColor Yellow
    Write-Host "正在请求提升权限..." -ForegroundColor Yellow

    # 重新启动脚本并请求管理员权限
    $scriptPath = $MyInvocation.MyCommand.Path
    if ($scriptPath) {
        Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
    } else {
        # 如果是从管道输入运行，需要先保存到临时文件
        $tempScript = Join-Path $env:TEMP "install_stepfun_$([Guid]::NewGuid()).ps1"
        $content = $ExecutionContext.SessionState.InvokeCommand.GetCommand($MyInvocation.InvocationName).ScriptBlock
        $content.ToString() | Out-File -FilePath $tempScript -Encoding UTF8
        Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -File `"$tempScript`""
        exit
    }
    exit
}

$ErrorActionPreference = "Stop"

$CONFIG_FILE = Join-Path $env:USERPROFILE ".openclaw\openclaw.json"

# 检查配置文件是否存在
if (-not (Test-Path $CONFIG_FILE)) {
    Write-Host "错误：配置文件不存在: $CONFIG_FILE" -ForegroundColor Red
    Write-Host "请确认 OpenClaw 已正确安装" -ForegroundColor Yellow
    exit 1
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  OpenClaw 配置 - 添加 StepFun 3.5 Flash" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "请选择接入方式：" -ForegroundColor White
Write-Host "  1) OpenRouter 免费版（无需付费，有速率限制 50 RPM）" -ForegroundColor Green
Write-Host "  2) StepFun 官方 API（按量计费，需要官方 API Key）" -ForegroundColor Green
Write-Host ""

do {
    $CHOICE = Read-Host "请输入数字选择 [1/2]"
} while ($CHOICE -notmatch '^[12]$')

Write-Host ""

if ($CHOICE -eq "1") {
    Write-Host "已选择：OpenRouter 免费版" -ForegroundColor Green
    Write-Host ""

    do {
        $OPENROUTER_APIKEY = Read-Host "请输入 OpenRouter API Key（sk-or-v1-...）"
        if ([string]::IsNullOrWhiteSpace($OPENROUTER_APIKEY)) {
            Write-Host "API Key 不能为空，请重新输入" -ForegroundColor Red
        }
    } while ([string]::IsNullOrWhiteSpace($OPENROUTER_APIKEY))

    Write-Host "配置文件: $CONFIG_FILE"
    Write-Host "API Key: $($OPENROUTER_APIKEY.Substring(0, [Math]::Min(15, $OPENROUTER_APIKEY.Length)))..."
    Write-Host ""

    # 备份配置文件
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $backupFile = "${CONFIG_FILE}.bak.$timestamp"
    Copy-Item $CONFIG_FILE $backupFile -Force
    Write-Host "已备份原配置文件: $backupFile"

    # 读取并修改配置文件
    try {
        $config = Get-Content $CONFIG_FILE -Raw | ConvertFrom-Json

        # 确保 models 对象存在
        if (-not $config.models) {
            $config | Add-Member -MemberType NoteProperty -Name "models" -Value ([PSCustomObject]@{})
        }
        # 确保 providers 对象存在
        if (-not $config.models.providers) {
            $config.models | Add-Member -MemberType NoteProperty -Name "providers" -Value ([PSCustomObject]@{})
        }

        # 创建 OpenRouter 提供商配置对象
        $openrouterConfig = [PSCustomObject]@{
            baseUrl = "https://openrouter.ai/api/v1"
            apiKey = $OPENROUTER_APIKEY
            api = "openai-completions"
            models = @(
                [PSCustomObject]@{
                    id = "stepfun/step-3.5-flash:free"
                    name = "Step 3.5 Flash Free"
                    api = "openai-completions"
                    reasoning = $true
                    input = @("text")
                    cost = [PSCustomObject]@{
                        input = 0
                        output = 0
                        cacheRead = 0
                        cacheWrite = 0
                    }
                    contextWindow = 256000
                    maxTokens = 8192
                }
            )
        }

        # 使用 Add-Member -Force 确保可以设置或替换
        $config.models.providers | Add-Member -MemberType NoteProperty -Name "openrouter" -Value $openrouterConfig -Force

        # 确保 agents 对象存在
        if (-not $config.agents) { $config | Add-Member -MemberType NoteProperty -Name "agents" -Value ([PSCustomObject]@{}) }
        if (-not $config.agents.defaults) { $config.agents | Add-Member -MemberType NoteProperty -Name "defaults" -Value ([PSCustomObject]@{}) }
        if (-not $config.agents.defaults.model) { $config.agents.defaults | Add-Member -MemberType NoteProperty -Name "model" -Value ([PSCustomObject]@{}) }

        # 设置默认模型（使用 -Force）
        $config.agents.defaults.model | Add-Member -MemberType NoteProperty -Name "primary" -Value "openrouter/stepfun/step-3.5-flash:free" -Force

        # 写回配置文件（保持格式）
        $config | ConvertTo-Json -Depth 100 | Set-Content $CONFIG_FILE -Encoding UTF8

        Write-Host "==========================================" -ForegroundColor Green
        Write-Host "  配置更新完成!" -ForegroundColor Green
        Write-Host "==========================================" -ForegroundColor Green
        Write-Host "  - 已添加 OpenRouter StepFun 3.5 Flash Free" -ForegroundColor White
        Write-Host "  - 默认模型: openrouter/stepfun/step-3.5-flash:free" -ForegroundColor White
        Write-Host "  - 速率限制: 50 RPM" -ForegroundColor White
        Write-Host "  - 备份文件: $backupFile" -ForegroundColor White
    }
    catch {
        Write-Host "配置文件处理失败: $_" -ForegroundColor Red
        Write-Host "调试: config.models = $($config.models | ConvertTo-Json -Compress)" -ForegroundColor Yellow
        exit 1
    }
}
else {
    Write-Host "已选择：StepFun 官方 API" -ForegroundColor Green
    Write-Host ""

    do {
        $STEPFUN_APIKEY = Read-Host "请输入 StepFun API Key"
        if ([string]::IsNullOrWhiteSpace($STEPFUN_APIKEY)) {
            Write-Host "API Key 不能为空，请重新输入" -ForegroundColor Red
        }
    } while ([string]::IsNullOrWhiteSpace($STEPFUN_APIKEY))

    Write-Host "配置文件: $CONFIG_FILE"
    Write-Host "API Key: $($STEPFUN_APIKEY.Substring(0, [Math]::Min(10, $STEPFUN_APIKEY.Length)))..."
    Write-Host ""

    # 备份配置文件
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $backupFile = "${CONFIG_FILE}.bak.$timestamp"
    Copy-Item $CONFIG_FILE $backupFile -Force
    Write-Host "已备份原配置文件: $backupFile"

    # 读取并修改配置文件
    try {
        $config = Get-Content $CONFIG_FILE -Raw | ConvertFrom-Json

        # 确保 models 对象存在
        if (-not $config.models) {
            $config | Add-Member -MemberType NoteProperty -Name "models" -Value ([PSCustomObject]@{})
        }
        # 确保 providers 对象存在
        if (-not $config.models.providers) {
            $config.models | Add-Member -MemberType NoteProperty -Name "providers" -Value ([PSCustomObject]@{})
        }

        # 创建 StepFun 提供商配置对象
        $stepfunConfig = [PSCustomObject]@{
            baseUrl = "https://api.stepfun.com/v1"
            apiKey = $STEPFUN_APIKEY
            api = "openai-completions"
            models = @(
                [PSCustomObject]@{
                    id = "stepfun/step-3.5-flash"
                    name = "Step 3.5 Flash"
                    api = "openai-completions"
                    reasoning = $false
                    input = @("text")
                    cost = [PSCustomObject]@{
                        input = 0
                        output = 0
                        cacheRead = 0
                        cacheWrite = 0
                    }
                    contextWindow = 256000
                    maxTokens = 8192
                }
            )
        }

        # 使用 Add-Member -Force 确保可以设置或替换
        $config.models.providers | Add-Member -MemberType NoteProperty -Name "stepfun" -Value $stepfunConfig -Force

        # 确保 agents 对象存在
        if (-not $config.agents) { $config | Add-Member -MemberType NoteProperty -Name "agents" -Value ([PSCustomObject]@{}) }
        if (-not $config.agents.defaults) { $config.agents | Add-Member -MemberType NoteProperty -Name "defaults" -Value ([PSCustomObject]@{}) }
        if (-not $config.agents.defaults.model) { $config.agents.defaults | Add-Member -MemberType NoteProperty -Name "model" -Value ([PSCustomObject]@{}) }

        # 设置默认模型（使用 -Force）
        $config.agents.defaults.model | Add-Member -MemberType NoteProperty -Name "primary" -Value "stepfun/step-3.5-flash" -Force

        # 写回配置文件（保持格式）
        $config | ConvertTo-Json -Depth 100 | Set-Content $CONFIG_FILE -Encoding UTF8

        Write-Host "==========================================" -ForegroundColor Green
        Write-Host "  配置更新完成!" -ForegroundColor Green
        Write-Host "==========================================" -ForegroundColor Green
        Write-Host "  - 已添加 StepFun 3.5 Flash" -ForegroundColor White
        Write-Host "  - 默认模型: stepfun/step-3.5-flash" -ForegroundColor White
        Write-Host "  - 备份文件: $backupFile" -ForegroundColor White
    }
    catch {
        Write-Host "配置文件处理失败: $_" -ForegroundColor Red
        Write-Host "调试: config.models = $($config.models | ConvertTo-Json -Compress)" -ForegroundColor Yellow
        exit 1
    }
}
