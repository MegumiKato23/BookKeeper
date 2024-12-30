import SwiftUI

struct NoteInputSheet: View {
    @Binding var note: String
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationView {
            TextField("添加备注", text: $note)
                .textFieldStyle(.roundedBorder)
                .padding()
                .focused($isFocused)
                .navigationTitle("添加备注")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    leading: Button("取消") { dismiss() },
                    trailing: Button("确定") { dismiss() }
                )
                .onAppear {
                    isFocused = true
                }
        }
    }
}

#Preview {
    NoteInputSheet(note: .constant(""))
} 