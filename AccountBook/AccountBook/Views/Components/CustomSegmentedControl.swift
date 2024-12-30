import SwiftUI

struct CustomSegmentedControl<T: Hashable>: View {
    @Binding var selection: T
    let items: [(title: String, value: T)]
    let accentColor: Color
    var width: CGFloat? = nil
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(items, id: \.value) { item in
                segmentButton(item.title, value: item.value)
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .frame(width: width)
    }
    
    private func segmentButton(_ title: String, value: T) -> some View {
        Button(action: { selection = value }) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity)
        }
        .background(selection == value ? accentColor : Color.clear)
        .foregroundColor(selection == value ? .white : .primary)
        .animation(.easeInOut(duration: 0.2), value: selection)
    }
} 
