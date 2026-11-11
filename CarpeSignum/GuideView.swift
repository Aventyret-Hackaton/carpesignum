import SwiftUI

/// Skärm 6 · Guide.
struct GuideView: View {
    let reading: Reading
    @Environment(ReadingStore.self) private var store
    @State private var stardust = 0

    var body: some View {
        list
            .overlay { Stardust(trigger: stardust) }
    }

    private var list: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("GUIDE · \(reading.date.swedishDayHeader)").labelStyle()
                Spacer().frame(height: 40)
                Text("Att göra").titleStyle()
                Spacer().frame(height: 6)
                Text("för att rädda din själ").italicStyle()
                Spacer().frame(height: 28)

                HStack(spacing: 12) {
                    Text("VARDAGLIGT").labelStyle(Theme.faint)
                    Rectangle().fill(Theme.line).frame(height: 1)
                    Text("DRASTISKT").labelStyle(Theme.accent)
                }
                Spacer().frame(height: 8)

                VStack(spacing: 0) {
                    ForEach(reading.todos) { todo in
                        AttGoraRad(todo: todo) {
                            if !todo.done { stardust += 1 }
                            store.toggle(todo)
                        }
                    }
                }

                Spacer().frame(height: 52)
                Text("NY GUIDE I MORGON KL. 07:00")
                    .labelStyle(Theme.faint)
                    .frame(maxWidth: .infinity)
                Spacer().frame(height: 24)
            }
            .padding(.horizontal, Theme.gutter)
            .padding(.top, 20)
        }
        .scrollIndicators(.hidden)
    }
}

/// Komponent "Att göra-rad", varianterna Klar=Nej och Klar=Ja.
struct AttGoraRad: View {
    let todo: TodoItem
    let toggle: () -> Void

    var body: some View {
        Button(action: toggle) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    if todo.done {
                        Rectangle().fill(Theme.accent)
                        Image("IkonBock").resizable().frame(width: 12, height: 12)
                    } else {
                        Rectangle().stroke(Theme.muted, lineWidth: 1)
                    }
                }
                .frame(width: 18, height: 18)

                VStack(alignment: .leading, spacing: 6) {
                    Text(todo.text)
                        .bodyStyle(todo.done ? Theme.muted : Theme.text)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(todo.source).labelStyle(Theme.faint).lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Text("\(todo.level)/5").labelStyle(todo.done ? Theme.faint : Theme.accent)
            }
            .padding(.vertical, 14)
            .overlay(alignment: .bottom) { Rectangle().fill(Theme.line).frame(height: 1) }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.2), value: todo.done)
    }
}
