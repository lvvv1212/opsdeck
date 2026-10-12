# OpsDeck

容器化部署与监控平台——把 **LifeArchive**（Spring Boot + Vue3）改造成一套规范的生产级部署。

技术栈：Dockerfile + Docker Compose + Nginx + GitHub Actions + Prometheus + Grafana + Loki。

## 快速开始

```bash
cp .env.example .env          # 按需填 DEEPSEEK_API_KEY / JWT 密钥 / GRAFANA_PASSWORD
docker compose up -d --build
curl http://localhost:8088/               # 前端（Nginx 托管）
curl http://localhost:8088/api/health     # API（Nginx 反代）
curl http://localhost:8081/actuator/prometheus   # 应用指标（Prometheus 采集源）
```

后端 Dockerfile 复用 LifeArchive 的多阶段构建（通过 `LIFEARCHIVE_DIR` 指向其源码，默认 `../life`）。

## 监控体系

| 服务 | 地址 | 说明 |
|---|---|---|
| Prometheus | http://localhost:9090 | 指标采集（Targets / Rules / Alerts）|
| Grafana | http://localhost:3000 | 可视化（admin / admin，已预置仪表盘）|
| Alertmanager | http://localhost:9093 | 告警路由与通知 |
| Node Exporter | http://localhost:9100 | 宿主机指标 |

采集范围：
- **后端应用**：Actuator 的 `/actuator/prometheus`（JVM 内存 / GC / HTTP / 线程 / CPU）
- **宿主机**：node_exporter（CPU / 内存 / 磁盘 / 网络 / 负载）

预置 Grafana 仪表盘：`LifeArchive 应用监控`、`宿主机监控`（provisioning 自动加载，无需手动导入）。

告警规则（`prometheus/alert.rules.yml`）：实例宕机、后端不可用、JVM 堆内存过高、宿主机 CPU 过高、宿主机内存不足。通知走 Alertmanager webhook（`alertmanager/alertmanager.yml` 内为占位 URL，替换成企业微信 / 钉钉 / 飞书机器人即可）。

> 说明：在 Docker Desktop（Windows/macOS）上，node_exporter 采集的是 Docker 内部 Linux 虚拟机的指标；部署到 Linux 服务器后即为真实宿主机指标。

## 进度

- [x] 阶段 0：环境与仓库
- [x] 阶段 1：最小闭环（Dockerfile + Compose 起 backend / mysql / redis）
- [x] 阶段 2：镜像加固（多阶段构建 + 数据卷 + Nginx + Actuator）
- [x] 阶段 3：监控体系（Prometheus + Grafana + Alertmanager + node_exporter）
- [ ] 阶段 4：CI/CD 流水线（GitHub Actions + 云服务器 + HTTPS）
- [ ] 阶段 5：日志与故障演练（Loki + Promtail）
