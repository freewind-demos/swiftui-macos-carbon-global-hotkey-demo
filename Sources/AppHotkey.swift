import AppKit
import Foundation

/// Carbon 风格热键值对象。
struct AppHotkey: Equatable, Hashable {
  /// macOS 虚拟键码。
  let keyCode: UInt32
  /// Carbon modifier bitmask。
  let modifiers: UInt32

  /// 展示名。
  var displayName: String {
    // 先拼修饰键。
    var parts: [String] = []
    if modifiers & 256 != 0 { parts.append("⌘") }
    if modifiers & 512 != 0 { parts.append("⇧") }
    if modifiers & 2048 != 0 { parts.append("⌥") }
    if modifiers & 4096 != 0 { parts.append("⌃") }
    // 再拼主键。
    return parts.joined() + Self.keyName(for: keyCode)
  }

  /// 常见键码映射。
  private static func keyName(for keyCode: UInt32) -> String {
    // 预设组合只用到少量数字和字母。
    let mapping: [UInt32: String] = [
      18: "1",
      19: "2",
      20: "3",
      21: "4",
      23: "5",
      22: "6",
      13: "W",
      15: "R"
    ]
    return mapping[keyCode] ?? "#\(keyCode)"
  }
}
