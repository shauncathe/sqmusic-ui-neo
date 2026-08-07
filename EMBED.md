# Embedded 单服务部署（分支 `embedded`）

本分支把 SQmusic UI Neo 的前端**直接嵌入 Simple SQ Music Plus 后端**，最终只有一个应用服务，不再需要独立的 `sqmusic_web` 前端容器。

## 原理

- Spring Boot 后端从 `src/main/resources/static/` 提供静态文件（`application.yml` 中 `mvc.static-path-pattern: /**`）。
- 把本仓库的 `frontend/index.html` 复制为 `src/main/resources/static/index.html`，后端就在 `/` 提供 UI、在 `/api` 提供接口——同源，无需反代，也无需跨域。
- 端口沿用后端默认 `8099`。

## 本分支文件

- `Dockerfile`：多阶段构建。先浅克隆上游后端（`3.0` 分支，仅取 `src` + `pom.xml`），把 `frontend/index.html` 复制进 `src/main/resources/static/index.html`，再用 Maven 打包，最后在 JDK 21 运行，暴露 `8099`。
- `docker-compose.yml`：只定义一个应用服务 `sqmusic`（从本目录 `Dockerfile` 构建）+ 一个 `mysql` 数据服务。移除了原版 compose 里的 `sqmusic_web` 容器（以及可选的 `kugoumusicapi`；需要酷狗源时可另行加回）。

## 使用

```sh
docker compose up -d --build
# 打开 http://<host>:8099/
```

切换后端版本：

```sh
docker compose build --build-arg BACKEND_REF=3.0
```

## 给后端开发者的集成方式

如果你在自己的后端仓库里直接嵌入，只需把 `frontend/index.html` 复制到后端的 `src/main/resources/static/index.html` 并重新打包即可；本仓库的 `Dockerfile` 就是这一步的自动化版本。

> 说明：本分支的 `Dockerfile` 在构建时会从 GitHub 克隆上游后端源码并现场用 Maven 编译（需要网络拉取依赖）。生产环境更推荐由后端团队把 UI 直接合进自己的镜像，而不是每次都源码构建。
