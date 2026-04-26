import SwiftUI

struct HomeView: View {
    // In production, inject via environment or @State init with DI container
    // HomeViewModel is left as a demonstration — wire it at the AppCoordinator level
    @State private var showWardrobe: Bool = false
    @State private var showAddAlarm: Bool = false
    @State private var showAlarmDetail: AlarmModel? = nil

    // Placeholder data — replace with real ViewModel in DI-wired context
    private let streakCount: Int = 5
    private let petState: PetModel = .default
    private let alarms: [AlarmModel] = [.default]

    var body: some View {
        NavigationStack {
            ZStack {
                Rise.Color.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Rise.Spacing.lg) {

                        // MARK: Pet Sun hero
                        ZStack(alignment: .topTrailing) {
                            SunView(
                                expression: PetEvolutionEngine.expression(for: petState),
                                size: PetEvolutionEngine.sunSize(for: petState.level)
                            )
                            .onTapGesture { showWardrobe = true }
                            .frame(maxWidth: .infinity)
                            .padding(.top, Rise.Spacing.xl)

                            // Streak badge
                            StreakBadge(count: streakCount)
                                .padding(.top, Rise.Spacing.md)
                                .padding(.trailing, Rise.Spacing.xl)
                        }

                        // MARK: Pet level label
                        Text(PetEvolutionEngine.levelDescription(for: petState.level))
                            .font(Rise.Font.rounded(14, weight: .medium))
                            .foregroundStyle(Rise.Color.textSecondary)

                        // MARK: Next alarm card
                        if let alarm = alarms.first {
                            RiseCard {
                                AlarmCardRow(alarm: alarm)
                            }
                            .padding(.horizontal, Rise.Spacing.xl)
                            .onTapGesture { showAlarmDetail = alarm }
                        }

                        // MARK: Alarm list
                        if alarms.count > 1 {
                            VStack(spacing: Rise.Spacing.sm) {
                                ForEach(alarms.dropFirst()) { alarm in
                                    RiseCard {
                                        AlarmCardRow(alarm: alarm)
                                    }
                                    .padding(.horizontal, Rise.Spacing.xl)
                                    .onTapGesture { showAlarmDetail = alarm }
                                }
                            }
                        }

                        Spacer(minLength: 80)
                    }
                }

                // MARK: Add alarm FAB
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            showAddAlarm = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(Rise.Color.text)
                                .frame(width: 56, height: 56)
                                .background(Rise.Color.primary, in: Circle())
                                .shadow(color: Rise.Color.primary.opacity(0.4), radius: 8, y: 4)
                        }
                        .padding(.trailing, Rise.Spacing.xl)
                        .padding(.bottom, Rise.Spacing.xl)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showWardrobe) {
            PetWardrobeSheet(petState: petState)
        }
        .sheet(item: $showAlarmDetail) { alarm in
            AlarmDetailView(alarm: alarm)
        }
    }
}

// MARK: - Streak badge
private struct StreakBadge: View {
    let count: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .font(.system(size: 13, weight: .bold))
            Text("\(count)")
                .font(Rise.Font.rounded(14, weight: .bold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Rise.Color.streakAmber, in: Capsule())
    }
}

// MARK: - Alarm card row
private struct AlarmCardRow: View {
    let alarm: AlarmModel

    var body: some View {
        VStack(alignment: .leading, spacing: Rise.Spacing.xs) {
            HStack {
                Text(alarm.time.formattedTime)
                    .font(Rise.Font.rounded(32, weight: .bold))
                    .foregroundStyle(Rise.Color.text)
                Spacer()
                Toggle("", isOn: .constant(alarm.isActive))
                    .tint(Rise.Color.primary)
                    .labelsHidden()
            }
            Text(alarm.repeatDays.isEmpty ? "One-time" : alarm.repeatDays.shortSummary)
                .font(Rise.Font.rounded(14))
                .foregroundStyle(Rise.Color.textSecondary)

            if let toneID = ToneLibrary.tone(id: alarm.toneID)?.name {
                HStack(spacing: 4) {
                    Image(systemName: "music.note")
                        .font(.system(size: 11))
                    Text(toneID)
                        .font(Rise.Font.rounded(12))
                }
                .foregroundStyle(Rise.Color.textSecondary)
            }
        }
    }
}

// MARK: - DateComponents convenience
private extension DateComponents {
    var formattedTime: String {
        let h = hour ?? 0
        let m = minute ?? 0
        let period = h >= 12 ? "PM" : "AM"
        let displayH = h == 0 ? 12 : (h > 12 ? h - 12 : h)
        return String(format: "%d:%02d %@", displayH, m, period)
    }
}

private extension Set<Weekday> {
    var shortSummary: String {
        if self == Set(Weekday.allCases.filter { $0 != .saturday && $0 != .sunday }) {
            return "Weekdays"
        }
        if self == Set([.saturday, .sunday]) { return "Weekends" }
        return self.sorted(by: { $0.rawValue < $1.rawValue }).map { $0.shortName }.joined(separator: " · ")
    }
}
