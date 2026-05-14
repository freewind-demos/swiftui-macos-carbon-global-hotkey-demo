import SwiftUI

/// 根状态。
@MainActor
final class CarbonGlobalHotkeyStore: ObservableObject {
  /// 当前动作到预设的绑定。
  @Published private(set) var presetsByAction: [CarbonGlobalHotkeyAction: GlobalHotkeyPreset]
  /// 当前是否已注册。
  @Published private(set) var isRegistered = false
  /// 最新提示。
  @Published var latestMessage = "先选择预设，再点 Register All。注册后切到别的 app 也能触发。"
  /// 日志。
  @Published var eventLog: [CarbonGlobalHotkeyEvent] = []

  /// Carbon service。
  private let service = CarbonGlobalHotkeyService()

  /// 默认初始化。
  init() {
    // 默认给每个动作分不同组合。
    presetsByAction = [
      .openPalette: .commandOption1,
      .pasteSnippet: .commandOption2,
      .archiveItem: .commandOption3,
      .clearQueue: .commandOption4
    ]
  }

  /// 当前动作的预设。
  func preset(for action: CarbonGlobalHotkeyAction) -> GlobalHotkeyPreset {
    presetsByAction[action] ?? .commandOption1
  }

  /// 改某个动作的预设。
  func setPreset(_ preset: GlobalHotkeyPreset, for action: CarbonGlobalHotkeyAction) {
    // 回写选择。
    presetsByAction[action] = preset
    // 给用户反馈。
    latestMessage = "已把 \(action.title) 改成 \(preset.title)。"
    // 若已注册则自动重注册。
    if isRegistered {
      registerAll()
    }
  }

  /// 注册全部全局热键。
  func registerAll() {
    // 组装动作表。
    let bindings = CarbonGlobalHotkeyAction.allCases.map { action in
      (action: action, hotkey: preset(for: action).hotkey)
    }
    // 注册到 Carbon。
    service.register(bindings: bindings) { [weak self] action in
      // Carbon 回调回主线程再写 UI。
      Task { @MainActor in
        self?.trigger(action, source: "Global Hotkey")
      }
    }
    // 改状态。
    isRegistered = true
    // 给出主提示。
    latestMessage = "已注册全局快捷键。现在可以切到别的 app 再试。"
  }

  /// 反注册全部热键。
  func unregisterAll() {
    // 清理 Carbon 注册。
    service.unregister()
    // 改状态。
    isRegistered = false
    // 给出提示。
    latestMessage = "已取消所有全局快捷键注册。"
  }

  /// 手动模拟触发。
  func trigger(_ action: CarbonGlobalHotkeyAction, source: String) {
    // 取当前热键文案。
    let hotkeyName = preset(for: action).title
    // 写最新提示。
    latestMessage = "刚才激活了 \(action.title)。"
    // 写日志。
    eventLog.insert(
      .init(action: action, source: source, hotkeyName: hotkeyName, happenedAt: Date()),
      at: 0
    )
    // 限制数量。
    eventLog = Array(eventLog.prefix(20))
  }

  /// 重复绑定提示。
  var duplicateWarnings: [String] {
    // 先按展示名聚合。
    let grouped = Dictionary(
      grouping: CarbonGlobalHotkeyAction.allCases,
      by: { preset(for: $0).title }
    )
    // 只保留重复项。
    return grouped
      .filter { $0.value.count > 1 }
      .sorted { $0.key < $1.key }
      .map { hotkeyName, actions in
        let titles = actions.map(\.title).joined(separator: ", ")
        return "\(hotkeyName): \(titles)"
      }
  }

  /// 格式化时间。
  func timeText(for date: Date) -> String {
    // 标准短时间。
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .medium
    return formatter.string(from: date)
  }
}
