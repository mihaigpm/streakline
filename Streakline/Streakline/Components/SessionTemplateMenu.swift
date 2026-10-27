import SwiftUI

/// Swaps the template on one slot. The other two slots are not in this menu.
struct SessionTemplateMenu: View {
    let slot: WorkoutDay
    let selectedRaw: String
    let onSelect: (SessionTemplate) -> Void

    var body: some View {
        Menu("Change \(slot.slotName)", systemImage: "ellipsis.circle") {
            ForEach(SessionTemplate.options(for: slot)) { template in
                Button {
                    onSelect(template)
                } label: {
                    if template.rawValue == selectedRaw {
                        Label(template.menuTitle, systemImage: "checkmark")
                    } else {
                        Text(template.menuTitle)
                    }
                }
            }
        }
        .labelStyle(.iconOnly)
        .tint(DesignSystem.Colors.textSecondary)
    }
}
