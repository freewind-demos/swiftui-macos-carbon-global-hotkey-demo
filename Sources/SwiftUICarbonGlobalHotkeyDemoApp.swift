import SwiftUI

/// App 入口。
@main
struct SwiftUICarbonGlobalHotkeyDemoApp: App {
  /// 根状态。
  @StateObject private var store = CarbonGlobalHotkeyStore()

  var body: some Scene {
    // 单窗口 demo。
    Window("Carbon Global Hotkey Demo", id: "main") {
      ContentView()
        .environmentObject(store)
    }
    .defaultSize(width: 1200, height: 780)
  }
}
