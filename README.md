# 微北洋APP(鸿蒙版)

![GitHub commit activity](https://img.shields.io/github/commit-activity/t/twtstudio/WePeiYang-HMOS?color=green)

![GitHub contributors](https://img.shields.io/github/contributors-anon/twtstudio/WePeiYang-HMOS?color=blue)

![GitHub Repo stars](https://img.shields.io/github/stars/twtstudio/WePeiYang-HMOS?logo=star&color=yellow)

## 项目背景

微北洋 Flutter 项目的 HarmonyOS NEXT 适配版本。本项目基于 **Johnson1662/WePeiYang-Flutter-HMOS** 进行修改开发,感谢**Johnson1662**的工作。

本仓库目标是让同环境开发者 clone 后，可以在 DevEco Studio 中直接打开 `harmonyos` 工程，配置本机签名后点击 Run 直接运行。

## 项目说明

本项目基于 WePeiYang-Flutter，保留原 Flutter 业务代码，并补充 HarmonyOS NEXT 运行所需的工程配置、本地 HAR 依赖和 DevEco Studio 调试流程。

当前重点支持：

- bundleName: `com.weipeiyang.cn`
- targetSdkVersion: `6.1.1(24)`
- compatibleSdkVersion: `5.0.0(12)`

## 环境要求

建议使用以下环境：

| 工具          | 版本/说明                                 |
| ------------- | ----------------------------------------- |
| DevEco Studio | 支持 HarmonyOS SDK 6.1.1 Release / API 24 |
| HarmonyOS SDK | `6.1.1(24) Release`                     |
| Flutter SDK   | OHOS 分支 Flutter                         |
| JDK           | JDK 21，推荐`21.0.10`                   |
| PUB_CACHE     | 推荐设置为`D:\pub-cache`                |
| 设备          | HarmonyOS NEXT / OpenHarmony API 24 真机  |

## Flutter 依赖

根目录可按需执行：

```
flutter pub get
```

HarmonyOS Flutter module 需要单独执行：

```
cd harmonyos\wepei_module
$env:PUB_CACHE="D:\pub-cache"
flutter pub get
```

## HarmonyOS 工程运行方式

用 DevEco Studio 打开：

```
harmonyos
```

打开后等待 Sync / Index 完成，然后连接真机，点击 DevEco Studio 的 Run。

## 签名说明

签名材料不提交到仓库。

仓库中的：

```
harmonyos/build-profile.json5
```

默认不包含本机签名密码、证书路径或 profile 路径。

首次运行时，需要在 DevEco Studio 中为本机生成或选择调试签名。生成后 DevEco Studio 可能会把本机签名信息写入 `harmonyos/build-profile.json5`，例如：

```
.p12
.p7b
.cer
keyPassword
storePassword
```

## 本地 HAR 依赖说明

`harmonyos/entry/libs` 下的 HAR 文件用于固定 Flutter OHOS 相关依赖，避免 `ohpm install` 时从远端拉取不存在的包导致 404。

```
harmonyos/entry/libs/flutter_module.har
harmonyos/entry/libs/flutter_embedding_debug.har
harmonyos/entry/libs/arm64_v8a_debug.har
harmonyos/entry/libs/photo_manager.har
```

如果删除这些文件，可能出现类似错误：

```
@ohos/flutter_ohos 404
flutter_native_arm64_v8a 404
photo_manager 404
```

## 命令行构建

也可以在命令行构建：

```
cd harmonyos
devecocli build
```

如果只想重新生成 Flutter HAR：

```
cd harmonyos\wepei_module
$env:PUB_CACHE="D:\pub-cache"
flutter build har --debug
```

也可以使用：

```
cd harmonyos\wepei_module
build_har.bat
```

## 常见问题

### ohpm install 404

如果出现：

```
@ohos/flutter_ohos 404
flutter_native_arm64_v8a 404
photo_manager 404
```

说明本地 HAR 固定依赖没有生效，检查：

```
harmonyos/entry/oh-package.json5
harmonyos/oh-package.json5
harmonyos/entry/libs/
```

### no signature file

如果安装时报：

```
no signature file
```

说明当前 HAP 没有签名。请在 DevEco Studio 中配置本机调试签名，然后通过 DevEco Studio Run 安装运行。

### AutoFill ArkTS 编译错误

如果报错位置在：

```
@ohos/flutter_ohos/src/main/ets/plugin/editing/OhosAutoFillHelper.ets
```

通常说明 Flutter OHOS embedding 和当前 SDK 的 AutoFill API 不完全匹配。

本仓库已通过本地 HAR 固定了可运行版本。请不要删除 `harmonyos/entry/libs` 下的 HAR 文件，也不要让 ohpm 回退到远程依赖。

### DevEco Studio 点击 Run 后白屏

请先确认：

1. 打开的是 `harmonyos` 工程。
2. 真机已解锁。
3. 使用的是 DevEco Studio Run，而不是安装未签名 HAP。
4. `harmonyos/entry/libs` 下 HAR 文件存在。
5. 本机签名已配置完成。

## 安装 (Installation)

- 正在准备向华为应用市场提交

## 以下为原版内容

主要功能列表

| 功能                  | 描述             |
| --------------------- | ---------------- |
| schedule              | 课程表           |
| map_calender          | 地图校历         |
| wiki                  | 北洋wiki入口     |
| gpa                   | GPA查询          |
| lake                  | 青年湖底（论坛） |
| studyroom             | 自习室           |
| 考试信息（开发中……) | 考试信息         |
| lost_and_found        | 失物招领         |
| xiaotian              | 小天AI           |

## Android 原生内容

## 安装运行

### 运行问题汇总：

[
    【教程】在运行WePeiYang - Flutter项目时可能遇到的问题 (持续更新)](https://www.cnblogs.com/ZzTzZ/p/17344002.html)

## 开发指南

### [分模块信息](twtstudio/WePeiYang-Flutter/tree/master/lib)

| 文件                                                              | 基建                                             | 常用修改                                           |
| :---------------------------------------------------------------- | ------------------------------------------------ | -------------------------------------------------- |
| [auth](twtstudio/WePeiYang-Flutter/tree/master/lib/auth)           | 注册登录绑定、个人信息页、设置页面               | 头像框、信息更新重设置、                           |
| [commons](twtstudio/WePeiYang-Flutter/tree/master/lib/commons)     | 与手机关联设置、当地缓存、网络请求               | 规定了页面主要外观、字体格式颜色、图标弹窗信息展示 |
| [feedback](twtstudio/WePeiYang-Flutter/tree/master/lib/feedback)   | 请求回显                                         | 请求回显                                           |
| [gpa](twtstudio/WePeiYang-Flutter/tree/master/lib/gpa)             | GPA显示                                          | 曲线显示、饼状显示                                 |
| [home](twtstudio/WePeiYang-Flutter/tree/master/lib/home)           | 主页                                             | 主要功能展示、活动弹窗                             |
| [message](twtstudio/WePeiYang-Flutter/tree/master/lib/message)     | 消息列表                                         | 一键已读                                           |
| [schedule](twtstudio/WePeiYang-Flutter/tree/master/lib/schedule)   | 小窗展示、主页面展示课程安排、课程细节、考试信息 | 夜猫子模式、考试信息                               |
| [studyroom](twtstudio/WePeiYang-Flutter/tree/master/lib/studyroom) | 自习室信息                                       |                                                    |
| [main.dart](twtstudio/WePeiYang-Flutter/blob/master/lib/main.dart) | 程序入口、初始化，启动！                         | 启动页设置                                         |

目前代码质量较高的模块有xx 。里面的代码涵盖了xx的用法，xx的高级使用方式，架构的抽象封装，自定义 View 等。 如果不知道从哪里做起，可以先从xx看起，然后一步步追溯到 xxx，看处理方式。

看代码可以用两种方法：自顶向下和自下而上。

### 应用依赖关系

多个模块需要使用的依赖放在 `commons` 模块里，使用 api 关键字添加依赖，以暴露给其他模块。

`app` 模块依赖包括 `commons` 模块在内的其他所有模块，其他模块依赖  `commons` 模块，以获取应用内框架的依赖和公共依赖。

### 应用内框架

应用内框架集中在 `commons` 模块中

### 网络请求

微北洋中网络请求统一使用xxx

### 泛型包装

## 开发规范

### 架构

| 文件分类  |                  |
| --------- | ---------------- |
| extension | 延申条件         |
| model     | 定义元素结构行为 |
| network   | 网络请求部分     |
| util      | 使用工具打包     |
| page      | 展示信息         |
| view      | 页面布局         |
| …        |                  |

### 依赖规范

### 命名规范

## 当前版本：4.4.8

本期更新内容：

### 比较大的更新记录：

## Git规范

## 其他资源

### 古早版本：

[ WePeiYang-Android 微北洋（安卓版） ](https://github.com/twtstudio/WePeiYang-Android)

[ WePeiYang-iOS-Everest 微北洋（IOS版本）](https://github.com/twtstudio/WePeiYang-iOS-Everest)

## 版权声明

## 备案号

津ICP备05004358号-18A(https://beian.miit.gov.cn/)

## 一些没有用的东西

Here is the 7th flag:
flag7{bmcgQzMwMSBhbnl0aW1lISBX}
