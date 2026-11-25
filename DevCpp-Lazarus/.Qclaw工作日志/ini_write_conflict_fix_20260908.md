# 修复 INI 文件写入冲突（EFCreateError）

## 日期：2026-09-08

## 问题
调试模式下关闭 DevCpp 时频繁出现 `EFCreateError: Unable to create file "...XL7DevCpp.ini": 另一个程序正在使用此文件`。

## 根因
FPC `TIniFile` 默认 `CacheUpdates = False`，每次 `WriteString` 都立即调用 `UpdateFile` → `SaveToFile`（打开/写入/关闭文件）。

`SaveOptions`（devcfg.pas）依次调用 7 个子配置的 `SaveSettings`，每个内部通过 `devData.WriteObject` 循环调用 `fINI.WriteString`，导致关闭时产生数十次独立的文件 I/O 操作。

在调试模式下，GDB 子进程、文件监控、自动保存计时器等可能仍持有文件句柄或正在退出，与密集的 INI 写入冲突 → Windows 文件锁错误。

## 解决方案
在 `TConfigData`（ConfigData.pas）中新增 `BeginBatch`/`EndBatch` 方法，代理 `fIni.CacheUpdates` 属性：
- `BeginBatch`：设 `CacheUpdates := True`，后续写入只更新内存缓存，标记 Dirty
- `EndBatch`：设 `CacheUpdates := False`，触发 `UpdateFile` 一次性写入全部内容

在 `SaveOptions`（devcfg.pas）中用 `try...finally` 包裹所有保存调用：
```pascal
devData.BeginBatch;
try
  devData.SaveSelf;
  devDirs.SaveSettings;
  ... (6 个子配置保存)
finally
  devData.EndBatch; // 一次性 flush
end;
```

将数十次文件 I/O 压缩为 1 次，极大降低冲突概率。

## 修改文件
- `ConfigData.pas`：interface 段新增 `BeginBatch`/`EndBatch` 声明；implementation 段新增两个方法实现
- `devcfg.pas`：`SaveOptions` 用 `BeginBatch`/`EndBatch` + `try...finally` 包裹

## 编译结果
编译通过（仅有已知的 `devcpp.ico not found` 非阻断警告）。
