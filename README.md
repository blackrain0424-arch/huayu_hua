# 华语花 (Huayu Hua)

循着花期，去看中国的春夏秋冬 🌸

一款基于 Flutter 的中国花卉观赏应用，集地图导航、AI 识花、社区互动于一体。

---

## 开发平台

### 核心框架

| 平台 | 版本 |
|------|------|
| Flutter | 3.41.9 (stable) |
| Dart | 3.11.5 |
| DevTools | 2.54.2 |

### Android 构建

| 组件 | 版本 |
|------|------|
| Android Gradle Plugin (AGP) | 8.11.1 |
| Kotlin | 2.2.20 |
| Gradle | 8.14 |
| JDK | Java 17 |

### Flutter 依赖

| 包名 | 版本 | 用途 |
|------|------|------|
| `flutter_map` | 7.0.2 | 交互式地图控件 |
| `latlong2` | 0.9.1 | 经纬度坐标类型 |
| `geolocator` | 14.0.2 | GPS 定位 |
| `image_picker` | 1.2.2 | 相机拍照 / 相册选图 |
| `shared_preferences` | 2.5.5 | 本地轻量键值存储 |
| `http` | 1.6.0 | HTTP 网络请求 |
| `supabase_flutter` | 2.12.4 | BaaS 后端（认证、数据库、存储、Edge Function） |
| `flutter_tts` | 4.2.5 | 中文语音播报 |

### 后端服务 —— Supabase

| 服务 | 说明 |
|------|------|
| Auth | 邮箱注册 / 登录 |
| Database (PostgreSQL) | 表：`posts`、`comments`、`likes`、`profiles` |
| Storage | 存储桶：`post-images`（社区帖子图片） |
| Edge Function: `chat` | AI 花卉问答 + 图片识别（多模态 LLM） |

### 地图服务 —— 高德地图

| 服务 | 说明 |
|------|------|
| 瓦片图层 | `webrd01.is.autonavi.com`（style=7） |
| 地点搜索 | `restapi.amap.com/v3/assistant/inputtips` |
| 逆地理编码 | `restapi.amap.com/v3/geocode/regeo` |

### Android 权限

| 权限 | 用途 |
|------|------|
| `ACCESS_FINE_LOCATION` | GPS 精确定位 |
| `ACCESS_COARSE_LOCATION` | 网络定位 |
| `CAMERA` | 拍照识花 / 社区发帖 |
| `INTERNET` | 网络访问 |

### 应用信息

| 项目 | 值 |
|------|------|
| 包名 (Application ID) | `com.example.huayu_hua` |
| 显示名称 | 华语花 |
| 版本 | 1.0.0+1 |
| 签名 | debug（开发阶段） |

---

## 项目结构

```
lib/
├── main.dart                          # 入口：初始化 → 登录页 / 主页
├── data/
│   ├── flower_data.dart               # 22 个赏花地点数据
│   ├── city_flower_data.dart          # 42 个城市市花数据
│   └── daily_flower_data.dart         # 36 种每日花卉数据
├── models/
│   ├── flower_spot.dart               # 赏花地点模型
│   ├── browse_record.dart             # 浏览记录模型
│   ├── upload_record.dart             # 上传记录模型
│   ├── community_post.dart            # 社区帖子模型
│   └── daily_flower.dart              # 每日花卉模型
├── services/
│   ├── supabase_service.dart          # Supabase SDK 初始化
│   ├── auth_service.dart              # 注册 / 登录 / 登出
│   ├── chat_service.dart              # AI 对话 + 本地花库匹配
│   ├── community_service.dart         # 帖子 / 点赞 / 评论 CRUD
│   ├── profile_service.dart           # 用户资料同步
│   └── storage_service.dart           # shared_preferences 本地存储
├── pages/
│   ├── main_tab_page.dart             # 底部 Tab 主页（5 个 tab）
│   ├── map_home_page.dart             # 地图首页（搜索、标记、定位）
│   ├── discover_page.dart             # 发现页（每日花历、推荐、月份指南）
│   ├── community_page.dart            # 社区页（帖子列表）
│   ├── chatbot_page.dart              # 花语 Bot（AI 对话 + TTS）
│   ├── mine_page.dart                 # 我的页（资料、收藏、记录、设置）
│   ├── login_page.dart / register_page.dart  # 登录 / 注册
│   ├── flower_detail_page.dart        # 花卉/地点详情
│   ├── favorites_page.dart            # 收藏列表
│   ├── browse_history_page.dart       # 浏览记录
│   ├── upload_form_page.dart          # 上传花卉照片
│   ├── my_uploads_page.dart           # 我的上传记录
│   ├── create_post_page.dart          # 发社区帖子
│   ├── post_detail_page.dart          # 帖子详情 + 评论
│   ├── location_picker_page.dart      # 地图选点
│   ├── photo_viewer_page.dart         # 大图查看
│   └── settings_page.dart             # 设置页
├── widgets/
│   ├── common_widgets.dart            # 公共颜色、组件
│   ├── daily_flower_card.dart         # 每日花历卡片
│   ├── flower_image_widget.dart       # 花卉图片组件（实景图 + emoji 回退）
│   └── chat_message_widget.dart       # 聊天消息气泡
└── utils/
    └── flower_image_mapper.dart       # 花名 → 图片路径映射
```

---

## 功能一览

| 功能 | 说明 |
|------|------|
| 🗺️ 赏花地图 | 全国 22 个赏花地点标记，支持搜索城市/地名/花卉 |
| 📍 GPS 定位 | 自动定位当前位置，查看周边赏花地 |
| 🌸 每日花历 | 每天推荐一种花，展示诗词、花语、别称、观赏地 |
| 🤖 花语 Bot | AI 对话问答 + 拍照识花，支持 TTS 语音播报 |
| 👥 花卉社区 | 发帖分享花卉见闻，点赞评论互动 |
| ❤️ 收藏 & 记录 | 收藏赏花地点，自动记录浏览历史 |
| 📷 拍照上传 | 拍摄花卉照片，记录发现位置 |
| 🏙️ 城市市花 | 收录 42 个中国城市的市花及介绍 |

---

## 快速开始

```bash
# 1. 安装依赖
flutter pub get

# 2. 运行
flutter run

# 3. 构建 APK
flutter build apk --release
```

## 花卉图片

实景花卉照片存放于 `assets/flowers/` 目录，共 35 种花卉 JPEG 图片。应用自动根据花名匹配对应图片，找不到图片时回退显示 emoji。

---

最后更新：2026-07-18
