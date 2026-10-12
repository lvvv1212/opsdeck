# OpsDeck 故障演练（Chaos Drill）

演练目标：验证「故障发生 → 指标告警 + 日志留痕 → 快速定位 → 恢复」的完整可观测链路。

## 前提

```bash
cd C:/Users/Lv/Desktop/OpsDeck
docker compose up -d          # 全栈已起（含 prometheus / grafana / alertmanager / loki / promtail）
```

观察入口：
- Grafana：http://localhost:3000（admin / admin）
- Prometheus Alerts：http://localhost:9090/alerts
- Alertmanager：http://localhost:9093
- 日志：Grafana → 「容器日志」仪表盘（Loki）

---

## 演练 1：Redis 宕机

**目的**：验证依赖 Redis 的后端能否暴露健康状态异常，日志能否留痕。

1. 停掉 Redis：`docker stop opsdeck-redis`
2. 等 1 分钟（Prometheus 告警 `for: 1m` 生效窗口）
3. 观察：
   - Grafana「宿主机监控」→ Redis 相关指标归零
   - 后端 `/actuator/health` 的 `redis` 组件变为 `DOWN`（`curl http://localhost:8081/actuator/health`）
   - Grafana「容器日志」检索 `{container="opsdeck-backend"}` → 看到 Redis 连接异常堆栈
4. 恢复：`docker start opsdeck-redis`，确认健康恢复为 `UP`

**预期结果**：后端健康检查 `redis: DOWN`，日志出现 `RedisConnectionFailureException`，恢复后自动回到 `UP`（依赖 Redis 的 health indicator 自愈）。

---

## 演练 2：后端宕机

**目的**：验证 `InstanceDown` / `BackendDown` 告警触发 + Alertmanager 收到告警。

1. 停掉后端：`docker stop opsdeck-backend`
2. 等约 1–2 分钟
3. 观察：
   - Prometheus `/alerts` 出现 `BackendDown`（critical）与 `InstanceDown`
   - Alertmanager `/`（http://localhost:9093）里出现该告警（若 webhook 已配真实地址会收到通知）
   - Grafana「LifeArchive 应用监控」的「应用实例状态」变为 `DOWN`
4. 恢复：`docker start opsdeck-backend`，告警在 `for` 窗口后自动 resolved

**预期结果**：`up{job="life-archive"} == 0` 触发告警，Alertmanager 展示，恢复后状态回落。

---

## 演练 3：日志检索定位问题

**目的**：验证 Loki + Grafana 的日志检索能力。

1. 触发一次后端接口，制造访问日志：`curl http://localhost:8088/api/health`
2. Grafana → 「容器日志」仪表盘，用 LogQL 检索：
   - 看 nginx 访问日志：`{container="opsdeck-nginx"}`
   - 看后端日志：`{container="opsdeck-backend"}`
   - 按关键字过滤：`{container="opsdeck-backend"} |= "ERROR"`
3. 尝试组合：`{container=~"opsdeck-.*"} |= "exception"`

**预期结果**：能按容器、关键字、时间范围检索日志，快速定位到具体请求/异常。

---

## 演练小结（写进面试）

- 用 **Prometheus + Alertmanager** 做指标告警（`up`、JVM 堆、宿主机 CPU/内存）
- 用 **Loki + Promtail** 做日志聚合与检索（docker_sd 自动发现容器日志）
- 两者在 **Grafana** 统一呈现：指标看「应用监控/宿主机监控」，日志看「容器日志」
- 故障链路：指标异动 → 告警 → 日志定位 → 恢复，全流程可复现
