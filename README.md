# SQmusic UI Neo

Simple SQ Music Plus 的开源 Web 前端。单文件 `frontend/index.html`，纯 HTML/CSS/JS，**无构建步骤**，可直接部署在任意静态服务器或反向代理之后。

> 本项目是第三方社区前端，基于 [Simple SQ Music Plus](https://github.com/59799517/simple_sq_music_plus) 的 Web 接口开发，与原作者无隶属关系。

## 功能

- 登录与会话（双认证头自动处理）
- 搜索：单曲 / 歌手 / 专辑，多音源聚合，分页，歌词，详情弹窗逐项下载
- 下载：单曲、歌手全部专辑、单专辑
- 下载任务：列表、高级筛选、批量操作、重试、清理（waiting/success/error）
- 设置：按系统 / 插件 / 扩展分组，仅保存脏字段，含字段校验
- 监听歌单：列表、URL 解析、新增、删除、刷新状态
- 文本 / 链接解析：批量 `歌手 - 歌曲` 解析与下载
- 阿里云同步：授权、目录、同步、上传记录
- 插件操作：QQ VIP / 酷狗二维码登录、刷新、签到、平台状态
- 移动端响应式、明暗主题、运行时 PWA manifest、退出登录、歌单导入
- **登录页可填写后端 API 地址**，方便局域网 / 反代 / 直连后端场景

## 快速开始

最简方式：把 `frontend/index.html` 放在反向代理后，由代理把 `/api`、`/mcp` 转发到你的 Simple SQ Music Plus 后端，打开站点用 SQMusic 账号登录即可。

完整部署、登录页填地址、CORS 等第三方场景，见 **[DEPLOY.md](DEPLOY.md)**。

## 后端接口契约

受保护接口需双认证头：`Authorization: Bearer <token>` 与 `sqmusic: <token>`（前端已自动处理）。响应信封 `{ code, msg, data }`，`code !== 200` 视为错误。

主要接口（路径已在前端按此实现）：

| 模块 | 接口 |
| --- | --- |
| 配置 | `/api/config/getConfigList`、`updateConfig`、`getOption`、`getCurrentNetwork`、`importSongList`、`version` |
| 搜索 | `/api/music/searchTips`、`searchSong`、`searchArtist`、`searchAlbum`、`SongInfoById`、`artistAlbumById`、`albumInfoById`、`getLyric`、`getDownloadUrl` |
| 下载 | `/api/download/downloadSong`、`downloadAlbum`、`downloadArtistAlbum`、`downloadParserText`、`downloadParserUrl` |
| 任务 | `/api/task/list`、`del`、`refreshTask`、`againTask`、`delErrorTask`、`delSuccessTask`、`delWaitingTask`、`errorTaskRetry` |
| 监听 | `/api/monitor/list`、`add`、`delete` |
| 解析 | `/api/parser/parserUrlInfo` |
| 插件 | `/api/plug/kg/*`、`/api/plug/qqvip/*`（二维码、状态、Cookie/Token 刷新、签到） |
| 阿里云 | `/api/expand/ali/*`（授权、目录、同步、上传记录） |

### 已知行为 / 坑

- 下载任务列表 `POST /api/task/list` 过滤字段为 `downloadStatus` / `downloadPlugName` / `downloadMusicname` / `downloadArtistname` / `downloadAlbumname` / `downloadTimeStart` / `downloadTimeEnd`；分页 `pageIndex` + `pageSize`，响应包络 `records/total/size/current/pages`。
- `getDownloadUrl` 必须传完整歌曲对象（`...song`），只传 `{id, plugName, brType}` 会 NPE。
- `getOption` 路径是 `/api/config/getOption`，不是 `/api/music/getOption`（后者返回“静态资源不存在”）。
- `errorTaskRetry` **仅查询**错误重试子任务，不执行重试；单项重试用 `POST /api/task/refreshTask`，全部错误重试用 `GET /api/task/againTask`。
- 监听歌单接口返回的 `plugNmae` 是后端拼写错误字段（非 `plugName`）；前端已兼容 `parsed.plugName || parsed.plugNmae`。
- 下载文件名模板 `system.download.file.template` 仅支持静态变量：`${musicName}` `${artists}` `${artist}` `${album}` `${albumId}` `${albumTime}` `${albumYear}` `${albumMonth}` `${albumDay}` `${artistsId}`。**v3.1.15+ 已取消 SpEL 表达式**，不能写 `if/then` 等条件逻辑。

## 本地开发

单文件前端，无构建。校验 JS 语法：

```sh
awk '/<script>/{flag=1;next}/<\/script>/{flag=0}flag' frontend/index.html > /tmp/sqmusic-frontend.js
node --check /tmp/sqmusic-frontend.js
```

## 相关项目

- 原项目（后端）：[Simple SQ Music Plus](https://github.com/59799517/simple_sq_music_plus)

## License

[MIT](LICENSE)
