# Keepalive

用于以**随机时间间隔**访问订阅地址，降低固定周期访问带来的规律性，同时减少请求频率。

## 默认配置

- URL: `https://qw.danao.eu.org/sub`
- 随机间隔: 每次请求完成后重新随机选择 **2–4 小时**
- 最短间隔: 7200 秒（2 小时）
- 最长间隔: 14400 秒（4 小时）
- 日志: `/var/log/keepalive.log`
- 启动方式: `nohup` 后台运行

每轮请求结束后都会重新生成随机等待时间，因此不会固定在相同的分钟或小时访问。

## 文件

- `scripts/keepalive.sh`：随机间隔保活循环。
- `scripts/start-keepalive.sh`：后台启动脚本，避免重复启动。

## 环境变量

可覆盖默认值：

```bash
export KEEPALIVE_URL="https://qw.danao.eu.org/sub"
export KEEPALIVE_MIN_INTERVAL=7200
export KEEPALIVE_MAX_INTERVAL=14400
export KEEPALIVE_LOG="/var/log/keepalive.log"
export KEEPALIVE_PID_FILE="/var/run/keepalive.pid"
```

例如改成随机 3–6 小时：

```bash
export KEEPALIVE_MIN_INTERVAL=10800
export KEEPALIVE_MAX_INTERVAL=21600
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

```bash
ps aux | grep '[k]eepalive.sh'
```

日志会显示本次请求结果和下一轮随机等待时间，例如：

```
2026-09-20 10:47:42 UTC - 保活成功: HTTP 200
2026-09-20 10:47:42 UTC - 下一次访问约在 3.27 小时后（随机等待 11772 秒）
```

## 容器重启

当前运行环境 PID 1 为 `supervisord`，但 `supervisorctl` socket 不可用，因此运行实例采用 `nohup` 后台启动。

**注意：仅提交到 GitHub 不会自动让正在运行的容器在重启后执行。**

需要在容器的实际启动入口中调用：

```bash
/path/to/repository/scripts/start-keepalive.sh
```

如果后续恢复可用的 Supervisor 配置，也可以由 Supervisor 管理核心脚本。

## 安全

脚本不包含 API Key、密码或其他凭据。URL、随机时间范围和日志路径均可通过环境变量覆盖。
