import SwiftUI

/// Pet wardrobe sheet — shows all accessories, locked ones greyed out.
struct PetWardrobeSheet: View {
    let petState: PetModel
    @Environment(\.dismiss) private var dismiss
    private let accessories = AccessoryInventory.accessories

    private let columns = [GridItem(.adaptive(minimum: 90), spacing: Rise.Spacing.md)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: Rise.Spacing.lg) {
                    ForEach(accessories) { accessory in
                        let isUnlocked = petState.unlockedAccessories.contains(accessory.id)
                        let isEquipped = petState.equippedAccessory == accessory.id

                        VStack(spacing: Rise.Spacing.sm) {
                            ZStack {
                                Circle()
                                    .fill(isUnlocked ? Rise.Color.primary.opacity(0.15) : Rise.Color.surface)
                                    .frame(width: 64, height: 64)

                                Image(systemName: isUnlocked ? "star.fill" : "lock.fill")
                                    .font(.system(size: 28))
                                    .foregroundStyle(isUnlocked ? Rise.Color.primary : Rise.Color.textSecondary.opacity(0.4))

                                if isEquipped {
                                    Circle()
                                        .strokeBorder(Rise.Color.primary, lineWidth: 3)
                                        .frame(width: 64, height: 64)
                                }
                            }

                            Text(accessory.name)
                                .font(Rise.Font.rounded(12, weight: isUnlocked ? .semibold : .regular))
                                .foregroundStyle(isUnlocked ? Rise.Color.text : Rise.Color.textSecondary)
                                .multilineTextAlignment(.center)

                            if !isUnlocked {
                                Text("\(accessory.requiredStreak)d streak")
                                    .font(Rise.Font.rounded(10))
                                    .foregroundStyle(Rise.Color.textSecondary)
                            }
                        }
                        .opacity(isUnlocked ? 1 : 0.5)
                    }
                }
                .padding(Rise.Spacing.xl)
            }
            .background(Rise.Color.background.ignoresSafeArea())
            .navigationTitle("Wardrobe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .tint(Rise.Color.primary)
                }
            }
        }
    }
}
