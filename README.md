# OpsDeck

容器化部署与监控平台——把 **LifeArchive**（Spring Boot + Vue3）改造成一套规范的生产级部署。

技术栈：Dockerfile + Docker Compose + Nginx + GitHub Actions + Prometheus + Grafana + Loki。

## 快速开始

```bash
cp .env.example .env          # 按需填 DEEPSEEK_API_KEY / JWT 密钥
docker compose up -d --build
curl http://localhost:8081/api/health
```

后端 Dockerfile 复用 LifeArchive 的多阶段构建（通过 `LIFEARCHIVE_DIR` 指向其源码，默认 `../life`）。

## 进度

- [x] 阶段 0：环境与仓库
- [x] 阶段 1：最小闭环（Dockerfile + Compose 起 backend / mysql / redis）
- [ ] 阶段 2：镜像加固（多阶段构建 + 数据卷 + Nginx + Actuator）
- [ ] 阶段 3：监控体系（Prometheus + Grafana + Alertmanager）
- [ ] 阶段 4：CI/CD 流水线（GitHub Actions + 云服务器 + HTTPS）
- [ ] 阶段 5：日志与故障演练（Loki + Promtail）
