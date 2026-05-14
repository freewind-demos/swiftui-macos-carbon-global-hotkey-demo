# SwiftUI macOS Carbon Global Hotkey Demo

## 简介

这个 Demo 演示最经典的 macOS 全局快捷键做法：`Carbon RegisterEventHotKey`。

它和内置 `keyboardShortcut`、当前本地 `NSEvent` 局部接管 demo 不同。这里注册后，即使切到别的 app，快捷键也还能触发。

## 快速开始

### 环境要求

- macOS 14 及以上
- Xcode 15 及以上
- XcodeGen：`brew install xcodegen`

### 运行

```bash
cd /Volumes/SN550-2T/freewind-demos/swiftui-macos-carbon-global-hotkey-demo

xcodegen generate

export DEVELOPER_DIR=/System/Volumes/Data/Applications/Xcode.app/Contents/Developer
xcodebuild \
  -project SwiftUICarbonGlobalHotkeyDemo.xcodeproj \
  -scheme SwiftUICarbonGlobalHotkeyDemo \
  -configuration Debug \
  -derivedDataPath .build/DerivedData \
  build

open SwiftUICarbonGlobalHotkeyDemo.xcodeproj
```

也可以直接：

```bash
./dev.sh
```

## 注意事项

- 这里用的是全局 hotkey，注册后离开当前 app 也能触发。
- 全局快捷键必须尽量避开系统保留组合。
- Demo 里用了几组较少冲突的预设组合，通过 Picker 切换。

## 教程

### 1. 关键概念

1. `RegisterEventHotKey`
   把某组按键注册成系统级全局 hotkey。
2. `EventHotKeyID`
   给每个动作分配一个 Carbon id，回调时再映射回动作。
3. `EventHandler`
   统一接收所有热键事件，再交给 SwiftUI store。

### 2. demo 原理

1. 左侧先给动作挑一个预设热键。
2. 点 `Register All` 注册全局 hotkey。
3. 切到别的 app，再按组合键。
4. 当前 Demo 窗口回到前台后，右侧日志里能看到刚才触发了哪个动作。

### 3. 关键代码

`Sources/CarbonGlobalHotkeyService.swift`

- 封装 `InstallEventHandler`
- 封装 `RegisterEventHotKey`
- 把 Carbon id 映射回业务动作

`Sources/CarbonGlobalHotkeyStore.swift`

- 管理预设选择
- 控制注册 / 反注册
- 统一写日志与提示

## 操作

1. 打开 app。
2. 给每个动作选一个预设组合。
3. 点 `Register All`。
4. 切到别的 app。
5. 试按 `⌘⌥1`、`⌘⌥2`、`⌘⌥3`、`⌘⌥4` 或你切换后的组合。
