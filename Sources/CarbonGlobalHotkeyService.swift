import Carbon
import Foundation

/// Carbon 全局热键注册器。
final class CarbonGlobalHotkeyService {
  /// 固定签名。
  private static let signature = OSType(0x46574448)

  /// 每个 id 对应的动作。
  private var actionsByID: [UInt32: CarbonGlobalHotkeyAction] = [:]
  /// 每个 id 对应的 Carbon ref。
  private var refsByID: [UInt32: EventHotKeyRef] = [:]
  /// 统一 handler ref。
  private var handlerRef: EventHandlerRef?
  /// 触发回调。
  private var onTrigger: ((CarbonGlobalHotkeyAction) -> Void)?

  /// 注册整套全局热键。
  func register(
    bindings: [(action: CarbonGlobalHotkeyAction, hotkey: AppHotkey)],
    onTrigger: @escaping (CarbonGlobalHotkeyAction) -> Void
  ) {
    // 先清旧注册。
    unregister()
    // 记录回调。
    self.onTrigger = onTrigger
    // 安装统一 handler。
    installHandlerIfNeeded()

    for (index, binding) in bindings.enumerated() {
      // Carbon id 从 1 开始。
      let hotkeyIDValue = UInt32(index + 1)
      // 记录动作映射。
      actionsByID[hotkeyIDValue] = binding.action
      // 组装 Carbon id。
      let hotkeyID = EventHotKeyID(signature: Self.signature, id: hotkeyIDValue)
      // 承接 Carbon ref。
      var hotkeyRef: EventHotKeyRef?
      // 注册系统级热键。
      RegisterEventHotKey(
        binding.hotkey.keyCode,
        binding.hotkey.modifiers,
        hotkeyID,
        GetApplicationEventTarget(),
        0,
        &hotkeyRef
      )
      // 保存 ref 以便之后反注册。
      if let hotkeyRef {
        refsByID[hotkeyIDValue] = hotkeyRef
      }
    }
  }

  /// 取消所有注册。
  func unregister() {
    // 逐个反注册。
    for hotkeyRef in refsByID.values {
      UnregisterEventHotKey(hotkeyRef)
    }
    // 清空表。
    refsByID.removeAll()
    actionsByID.removeAll()
    // 移除 handler。
    if let handlerRef {
      RemoveEventHandler(handlerRef)
      self.handlerRef = nil
    }
    // 清掉回调。
    onTrigger = nil
  }

  /// 安装全局事件 handler。
  private func installHandlerIfNeeded() {
    // 已安装就不重复做。
    guard handlerRef == nil else {
      return
    }

    // 只关心 hotkey pressed。
    var eventSpec = EventTypeSpec(
      eventClass: OSType(kEventClassKeyboard),
      eventKind: UInt32(kEventHotKeyPressed)
    )

    InstallEventHandler(
      GetApplicationEventTarget(),
      { _, event, userData in
        // 事件或 userData 丢了就直接返回。
        guard let event, let userData else {
          return noErr
        }

        // 取出 Carbon hotkey id。
        var hotkeyID = EventHotKeyID()
        GetEventParameter(
          event,
          EventParamName(kEventParamDirectObject),
          EventParamType(typeEventHotKeyID),
          nil,
          MemoryLayout<EventHotKeyID>.size,
          nil,
          &hotkeyID
        )

        // 回到 Swift 对象。
        let service = Unmanaged<CarbonGlobalHotkeyService>.fromOpaque(userData).takeUnretainedValue()
        // 转发给业务动作。
        service.handle(hotkeyID.id)
        return noErr
      },
      1,
      &eventSpec,
      Unmanaged.passUnretained(self).toOpaque(),
      &handlerRef
    )
  }

  /// 把 Carbon id 映射回动作。
  private func handle(_ id: UInt32) {
    // 找动作。
    guard let action = actionsByID[id] else {
      return
    }
    // 转发给外层。
    onTrigger?(action)
  }
}
