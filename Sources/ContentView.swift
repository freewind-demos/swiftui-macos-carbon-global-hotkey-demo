import SwiftUI

/// 主界面。
struct ContentView: View {
  /// 根状态。
  @EnvironmentObject private var store: CarbonGlobalHotkeyStore

  var body: some View {
    NavigationSplitView {
      // 左侧配置区。
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          // 标题。
          Text("Carbon Global Hotkeys")
            .font(.largeTitle.bold())
          // 说明。
          Text("这套走 RegisterEventHotKey。注册后离开当前 app 也能触发。")
            .foregroundStyle(.secondary)

          HStack {
            // 注册或反注册。
            Button(store.isRegistered ? "Unregister All" : "Register All") {
              if store.isRegistered {
                store.unregisterAll()
              } else {
                store.registerAll()
              }
            }
            // 立即写出状态。
            Text(store.isRegistered ? "Registered" : "Not Registered")
              .font(.caption.monospaced())
              .foregroundStyle(store.isRegistered ? .green : .secondary)
          }

          ForEach(CarbonGlobalHotkeyAction.allCases) { action in
            VStack(alignment: .leading, spacing: 10) {
              // 动作名。
              Text(action.title)
                .font(.headline)
              // 预设选择。
              Picker("Preset", selection: Binding(
                get: { store.preset(for: action) },
                set: { store.setPreset($0, for: action) }
              )) {
                ForEach(GlobalHotkeyPreset.allCases) { preset in
                  Text(preset.title).tag(preset)
                }
              }
              .labelsHidden()
              // 手动模拟。
              HStack {
                Text("Current: \(store.preset(for: action).title)")
                  .font(.caption.monospaced())
                  .foregroundStyle(.secondary)
                Spacer()
                Button("Trigger") {
                  store.trigger(action, source: "Button")
                }
              }
            }
            .padding(16)
            .background(Color(nsColor: .windowBackgroundColor))
            .overlay(
              RoundedRectangle(cornerRadius: 14)
                .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
          }
        }
        .padding(20)
      }
      .frame(minWidth: 430)
    } detail: {
      // 右侧结果区。
      ScrollView {
        VStack(alignment: .leading, spacing: 18) {
          // 主提示。
          VStack(alignment: .leading, spacing: 10) {
            Text("Latest Event")
              .font(.headline)
            Text(store.latestMessage)
              .font(.title2.weight(.semibold))
            Text("建议注册后切到别的 app 再试，这样最能体现和内置快捷键的区别。")
              .foregroundStyle(.secondary)
          }
          .padding(18)
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(Color.accentColor.opacity(0.08))
          .clipShape(RoundedRectangle(cornerRadius: 18))

          if !store.duplicateWarnings.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
              Text("Duplicate Bindings")
                .font(.headline)
              ForEach(store.duplicateWarnings, id: \.self) { warning in
                Text(warning)
                  .font(.callout.monospaced())
              }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.orange.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: 18))
          }

          // 事件日志。
          VStack(alignment: .leading, spacing: 12) {
            Text("Event Log")
              .font(.headline)

            if store.eventLog.isEmpty {
              Text("还没有触发记录。")
                .foregroundStyle(.secondary)
            } else {
              ForEach(store.eventLog) { event in
                HStack(alignment: .top, spacing: 12) {
                  Text(store.timeText(for: event.happenedAt))
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                  VStack(alignment: .leading, spacing: 4) {
                    Text(event.action.title)
                      .font(.body.weight(.semibold))
                    Text("\(event.source) · \(event.hotkeyName)")
                      .font(.caption.monospaced())
                      .foregroundStyle(.secondary)
                  }
                  Spacer()
                }
                .padding(.vertical, 6)
                Divider()
              }
            }
          }
          .padding(18)
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(Color(nsColor: .windowBackgroundColor))
          .overlay(
            RoundedRectangle(cornerRadius: 18)
              .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
          )
          .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .padding(20)
      }
      .frame(minWidth: 540)
    }
    .navigationSplitViewStyle(.balanced)
    .frame(minWidth: 1100, minHeight: 720)
  }
}
