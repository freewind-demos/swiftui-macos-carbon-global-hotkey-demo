import Foundation

/// 演示动作。
enum CarbonGlobalHotkeyAction: String, CaseIterable, Identifiable {
  /// 打开面板。
  case openPalette
  /// 粘贴片段。
  case pasteSnippet
  /// 归档条目。
  case archiveItem
  /// 清空队列。
  case clearQueue

  /// `ForEach` 用 id。
  var id: String { rawValue }

  /// 标题。
  var title: String {
    switch self {
    case .openPalette:
      return "Open Palette"
    case .pasteSnippet:
      return "Paste Snippet"
    case .archiveItem:
      return "Archive Item"
    case .clearQueue:
      return "Clear Queue"
    }
  }
}

/// 可选预设。
enum GlobalHotkeyPreset: String, CaseIterable, Identifiable {
  /// `⌘⌥1`
  case commandOption1
  /// `⌘⌥2`
  case commandOption2
  /// `⌘⌥3`
  case commandOption3
  /// `⌘⌥4`
  case commandOption4
  /// `⌘⇧W`
  case commandShiftW
  /// `⌘⇧R`
  case commandShiftR

  /// `ForEach` 用 id。
  var id: String { rawValue }

  /// 对应热键。
  var hotkey: AppHotkey {
    switch self {
    case .commandOption1:
      return .init(keyCode: 18, modifiers: 256 | 2048)
    case .commandOption2:
      return .init(keyCode: 19, modifiers: 256 | 2048)
    case .commandOption3:
      return .init(keyCode: 20, modifiers: 256 | 2048)
    case .commandOption4:
      return .init(keyCode: 21, modifiers: 256 | 2048)
    case .commandShiftW:
      return .init(keyCode: 13, modifiers: 256 | 512)
    case .commandShiftR:
      return .init(keyCode: 15, modifiers: 256 | 512)
    }
  }

  /// 展示标题。
  var title: String {
    hotkey.displayName
  }
}

/// 单条日志。
struct CarbonGlobalHotkeyEvent: Identifiable {
  /// 唯一 id。
  let id = UUID()
  /// 动作。
  let action: CarbonGlobalHotkeyAction
  /// 来源。
  let source: String
  /// 热键。
  let hotkeyName: String
  /// 时间。
  let happenedAt: Date
}
