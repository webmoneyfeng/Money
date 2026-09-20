# Keepalive

用于定期访问订阅地址，降低 AutoSleep 风险。

## 默认配置

- URL: `https://qw.danao.eu.org/sub`
- 间隔: 1200 秒（20 分钟）
- 日志: `/var/log/keepalive.log`
- 启动方式: `nohup` 后台运行

## 文件

- `scripts/keepalive.sh`：核心保活循环。
- `scripts/start-keepalive.sh`：后台启动脚本，避免重复启动。

## 环境变量

可覆盖默认值：

```bash
export KEEPALIVE_URL="https://qw.danao.eu.org/sub"
export KEEPALIVE_INTERVAL=1200
export KEEPALIVE_LOG="/var/log/keepalive.log"
export KEEPALIVE_PID_FILE="/var/run/keepalive.pid"
```

## 启动

```bash
chmod +x scripts/keepalive.sh scripts/start-keepalive.sh
scripts/start-keepalive.sh
```

查看日志：

```bash
tail -f /var/log/keepalive.log
```

检查进程：

```ps aux | grep '[k]eepalive.sh'
```

## 容器重启

当前运行环境 PID 1 为 `supervisord`，但 `supervisorctl` socket 不可用，因此运行实例采用 `nohup` 后台启动。

**注意：仅提交到 GitHub 不会自动让正在运行的容器在重启后执行。**

需要在容器的实际启动入口中调用：

```bash
/path/to/repository/scripts/start-keepalive.sh
```

如果后续恢复可用的 Supervisor 配置，也可以由 Supervisor 管理核心脚本。

## 已验证状态

此前已验证订阅地址返回 HTTP 200：

```
2026-09-20 10:47:42 UTC - 保活脚本启动
2026-09-20 10:47:42 UTC - 保活成功: HTTP 200
```

## 安全

脚本不包含 API Key、密码或其他凭据。URL 和轮询参数可通过环境变量覆盖。
