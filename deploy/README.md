# OpsDeck 生产部署指南

CI 已把后端/前端打成镜像推到 GHCR（`ghcr.io/lvvv1212/opsdeck-backend`、`opsdeck-nginx`）。拿到云服务器后按下面步骤即可上线。

## 前置条件

- 一台 Linux 云服务器（腾讯云/阿里云轻量应用服务器，Ubuntu 22.04 即可），已装 Docker + Docker Compose v2
- 一个域名解析到服务器公网 IP（HTTPS 必需；若只要 HTTP 可跳过证书部分）

## 一次性初始化（服务器上执行）

```bash
# 1. 装 Docker（若未装）
curl -fsSL https://get.docker.com | sh

# 2. 拉取部署文件
git clone https://github.com/lvvv1212/opsdeck.git /opt/opsdeck
cd /opt/opsdeck

# 3. 创建 .env，填入真实密钥
cp .env.example .env
vim .env    # 填 DB_PASSWORD / DEEPSEEK_API_KEY / LIFEARCHIVE_JWT_SECRET / GRAFANA_PASSWORD

# 4. 配置 HTTPS（见下方「HTTPS 证书」两选一）

# 5. 启动
docker compose -f docker-compose.prod.yml up -d
```

## HTTPS 证书（两选一）

### 方案 A：云厂商免费证书（推荐，国内最省事）

腾讯云 / 阿里云控制台均可申请免费 DV 证书（一年期）。下载 **Nginx 格式** 的证书文件（`.pem` + `.key`），放到服务器：

```bash
mkdir -p /opt/opsdeck/certbot/conf/live/your-domain.com
# 上传证书后重命名：
#   fullchain.pem  ← 下载的完整证书链
#   privkey.pem    ← 下载的私钥
```

然后在 `deploy/nginx-https.conf` 里把 `your-domain.com` 换成你的域名，重启 nginx 即可。

### 方案 B：certbot 自动签发（Let's Encrypt，可自动续期）

```bash
# 1. 首次签发（standalone 模式，临时占用 80 端口；此时 nginx 尚未启动）
docker run --rm -p 80:80 \
  -v /opt/opsdeck/certbot/conf:/etc/letsencrypt \
  -v /opt/opsdeck/certbot/www:/var/www/certbot \
  certbot/certbot certonly --standalone \
  -d your-domain.com --email you@example.com --agree-tos --no-eff-email

# 2. 替换 nginx-https.conf 里的域名，启动 nginx
docker compose -f docker-compose.prod.yml up -d nginx

# 3. 开启自动续期（certbot 每 12 小时检查一次，走 webroot）
docker compose -f docker-compose.prod.yml --profile certbot up -d
```

> 若暂时不用 HTTPS：把 `docker-compose.prod.yml` 里 nginx 只映射 `80:80`，并把挂载配置换回 `nginx/nginx.conf`（HTTP 版）。

## 日常发布（GitHub 上手动触发）

1. 代码推到 `main`，CI 自动「测试 + 构建 + 推镜像」
2. GitHub 仓库 **Settings → Secrets → Actions** 配 3 个密钥：
   - `SERVER_HOST`：服务器公网 IP 或域名
   - `SERVER_USER`：SSH 用户（如 `root`）
   - `SERVER_SSH_KEY`：该用户 SSH 私钥（`~/.ssh/id_ed25519` 内容）
3. 仓库页 **Actions → Deploy → Run workflow**，自动 SSH 登录、pull 镜像、重启服务

## 安全建议

- 用云厂商**安全组/防火墙**只放行 80 / 443（对外）；`9090`(Prometheus)、`3000`(Grafana)、`9093`(Alertmanager)、`3306`、`6379` 仅对可信 IP 或内网开放
- `alertmanager/alertmanager.yml` 里的 webhook 换成企业微信/钉钉/飞书机器人，才能真正收到告警
- `DB_PASSWORD` / `DEEPSEEK_API_KEY` / JWT 密钥只放服务器 `.env`，绝不提交 git（`.gitignore` 已排除 `.env` 与 `certbot/`）
