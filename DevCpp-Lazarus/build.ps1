# build.ps1 - 在正确工作目录下构建 DevCpp-Lazarus，并过滤构建日志
#
# 关键：用 $PSScriptRoot 自动切到项目目录再调用 lazbuild，
#       这样资源编译器能按相对路径找到 devcpp.ico（否则会误报 "not found"）。
#
# 用法:
#   .\build.ps1                 # 增量构建（默认构建模式）
#   .\build.ps1 -Clean          # 全量重建 (-B)
#   .\build.ps1 -BuildMode Release
#   .\build.ps1 -BuildMode Debug -Clean
#   .\build.ps1 -Verbose        # 同时逐条列出 Warning / Hint
param(
  [switch]$Clean,
  [string]$BuildMode = "",
  [switch]$Verbose
)

$ErrorActionPreference = 'Stop'
$projDir  = $PSScriptRoot
$lazbuild = "C:\lazarus\lazbuild.exe"
$lpi      = Join-Path $projDir "DevCpp.lpi"
$log      = Join-Path $projDir "build.log"

if (-not (Test-Path $lpi)) {
  Write-Error "找不到项目文件: $lpi"
  exit 1
}

# 切到项目目录（资源编译器按相对路径解析外部资源依赖此 cwd）
Set-Location $projDir

$args = @($lpi)
if ($Clean)        { $args += '-B' }
if ($BuildMode -ne '') { $args += "--build-mode=$BuildMode" }

Write-Host "==> $lazbuild $($args -join ' ')" -ForegroundColor Cyan
Write-Host "    cwd = $projDir" -ForegroundColor DarkGray

# 运行并落盘（OEM 编码以保留行号/关键字，便于后续过滤）
$output   = @(& $lazbuild @args 2>&1)
$exitCode = $LASTEXITCODE
$output | Out-File -FilePath $log -Encoding OEM

# 过滤
$lines   = [System.IO.File]::ReadAllLines($log)
$errs    = @($lines | Where-Object { $_ -match 'Error:' })
$fatals  = @($lines | Where-Object { $_ -match 'Fatal:' })
$warns   = @($lines | Where-Object { $_ -match 'Warning:' })
$hints   = @($lines | Where-Object { $_ -match 'Hint:' })
$notes   = @($lines | Where-Object { $_ -match 'Note:' })
$summary = @($lines | Where-Object { $_ -match 'lines compiled' })

Write-Host ""
$failed = ($fatals.Count -gt 0) -or ($errs.Count -gt 0) -or ($exitCode -ne 0)
if ($failed) {
  Write-Host "BUILD FAILED (exit=$exitCode)" -ForegroundColor Red
  $fatals | ForEach-Object { Write-Host $_ -ForegroundColor Red }
  $errs   | ForEach-Object { Write-Host $_ -ForegroundColor Red }
} else {
  Write-Host "BUILD OK" -ForegroundColor Green
}
Write-Host ("Warnings: {0}   Hints: {1}   Notes: {2}" -f $warns.Count, $hints.Count, $notes.Count)
if ($summary.Count -gt 0) { Write-Host $summary[-1] }

if ($Verbose -and (($warns.Count -gt 0) -or ($hints.Count -gt 0))) {
  Write-Host "`n-- Warnings / Hints --" -ForegroundColor Yellow
  $warns  | ForEach-Object { Write-Host $_ }
  $hints  | ForEach-Object { Write-Host $_ }
}
Write-Host "`n完整日志: $log"
