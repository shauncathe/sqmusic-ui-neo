# SQmusic UI Neo — 部署与配置

Simple SQ Music Plus 的开源 Web 前端。单文件 `frontend/index.html`，**无构建步骤**，纯 HTML/CSS/JS。本文面向第三方：你已有（或准备自建）一个 Simple SQ Music Plus 后端，想用它来访问。

## 前置条件

- 一个正在运行的 Simple SQ Music Plus 后端，对外暴露：
  - `/api/*`：REST 接口（配置 / 搜索 / 下载 / 任务 / 监听 / 解析 / 插件 / 阿里云）
  - `/mcp`：可选 MCP 接口
- 一个 SQMusic 登录账号（存于后端 `sq_config` 的 `system.login.account` / `system.login.password`）。
- 受保护接口浏览器需同时带两个请求头：`Authorization: Bearer <token>` 与 `sqmusic: <token>`。前端已自动处理，你无需手动加。

## 方式一：反向代理部署（推荐）

前端只调用相对路径 `/api`。把它和一个反向代理一起部署，由代理把 `/api`、`/mcp` 转发到后端即可——这与官方前端部署方式一致，且不依赖跨域。

1. 把 `frontend/index.html` 放到任意静态目录（如 `/srv/sqmusic-ui/`）。
2. 配置反向代理（按你的后端地址/端口修改 `proxy_pass`）：

**Nginx**

```nginx
server {
  listen 80;
  server_name music.example.com;

  root /srv/sqmusic-ui;
  index index.html;

  location / {
    try_files $uri $uri/ /index.html;
  }

  # 转发到 Simple SQ Music Plus 后端（端口按实际修改，常见 8099 或 9876）
  location /api/ {
    proxy_pass http://127.0.0.1:8099/api/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
  }
  location /mcp {
    proxy_pass http://127.0.0.1:8099/mcp;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
  }
}
```

**Caddy**

```
music.example.com {
  root * /srv/sqmusic-ui
  file_server
  reverse_proxy /api/* 127.0.0.1:8099
  reverse_proxy /mcp 127.0.0.1:8099
}
```

3. 打开站点，登录页「后端 API 地址」**留空**（使用同源 `/api`），用 SQMusic 账号登录即可。

## 方式二：前端直接填后端地址（跨域场景）

如果前后端不同源、不想配反代：

1. 登录页「后端 API 地址」填入**带 `/api` 前缀的完整地址**，例如：
   - `https://music.example.com/api`（反代后的地址）
   - `http://192.168.1.10:8099/api`（后端直连地址）
2. 留空则使用同源 `/api`。
3. 该值保存在浏览器 `localStorage`，下次自动填充。

> 填的是「API 前缀」这一级（含 `/api`），不是后端根地址。

⚠️ **跨域要求**：前后端不同源时，后端必须开启 CORS（允许你的前端源），否则浏览器会拦截请求。多数 SQMusic 默认部署未开 CORS，跨域直连通常不通——此时请用方式一（反代让前后端同源）。

## 更新

直接替换 `frontend/index.html` 即可，无需其他步骤。后端地址等偏好存于浏览器本地，不会因更新丢失。

## 已知限制

- 下载文件名模板（`system.download.file.template`）仅支持静态变量：`${musicName}` `${artists}` `${artist}` `${album}` `${albumId}` `${albumTime}` `${albumYear}` `${albumMonth}` `${albumDay}` `${artistsId}`。**v3.1.15+ 已取消 SpEL 表达式**，不能写条件逻辑。
- 旧版端口（如 `1020` / `1021`）是本仓库作者的内部部署端口，与通用部署无关。

## 接口契约（前端已按此实现）

- 受保护接口需双认证头 `Authorization: Bearer <token>` + `sqmusic: <token>`。
- 响应信封 `{ code, msg, data }`，`code !== 200` 视为错误。
- 主要路由见仓库 README 的「已确认后端接口」。
