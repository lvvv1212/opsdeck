# OpsDeck 生产 Nginx 镜像：站点配置 + 前端静态资源一并打进镜像
# 构建 context 为 OpsDeck 仓库根目录（CI 里 life/frontend/dist 已由前端 job 产出）

FROM nginx:1.27-alpine

# 站点配置：反向代理 /api → backend，SPA history fallback
COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf

# 前端静态资源（CI 里从 life-archive 前端构建产出）
COPY life/frontend/dist /usr/share/nginx/html
