import SwiftUI

struct HomeView: View {
    let viewModel: HomeViewModel

    @State private var showWardrobe: Bool = false
    @State private var showAddAlarm: Bool = false
    @State private var showAlarmDetail: AlarmModel? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "FAFAF7").ignoresSafeArea(.all)

                ScrollView {
                    VStack(spacing: Rise.Spacing.lg) {

                        // MARK: Pet Sun hero
                        ZStack(alignment: .topTrailing) {
                            SunView(
                                expression: PetEvolutionEngine.expression(for: viewModel.petState),
                                size: PetEvolutionEngine.sunSize(for: viewModel.petState.level)
                            )
                            .onTapGesture { showWardrobe = true }
                            .frame(maxWidth: .infinity)
                            .padding(.top, Rise.Spacing.xl)

                            StreakBadge(count: viewModel.streakCount)
                                .padding(.top, Rise.Spacing.md)
                                .padding(.trailing, Rise.Spacing.xl)
                        }

                        // MARK: Pet level label
                        Text(PetEvolutionEngine.levelDescription(for: viewModel.petState.level))
                            .font(Rise.Font.rounded(14, weight: .medium))
                            .foregroundStyle(Rise.Color.textSecondary)

                        // MARK: Alarm list
                        if viewModel.allAlarms.isEmpty {
                            emptyState
                        } else {
                            VStack(spacing: Rise.Spacing.sm) {
                                ForEach(viewModel.allAlarms) { alarm in
                                    RiseCard {
                                        AlarmCardRow(
                                            alarm: alarm,
                                            onToggle: { viewModel.toggleAlarm(alarm) }
                                        )
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
            PetWardrobeSheet(petState: viewModel.petState)
        }
        .sheet(isPresented: $showAddAlarm) {
            AddAlarmSheet { newAlarm in
                viewModel.saveAlarm(newAlarm)
            }
        }
        .sheet(item: $showAlarmDetail) { alarm in
            AlarmDetailView(
                alarm: alarm,
                onSave: { updated in viewModel.saveAlarm(updated) },
                onDelete: { viewModel.deleteAlarm(alarm) }
            )
        }
    }

    private var emptyState: some View {
        VStack(spacing: Rise.Spacing.md) {
            Image(systemName: "alarm")
                .font(.system(size: 44))
                .foregroundStyle(Rise.Color.primary.opacity(0.4))
            Text("No alarms yet")
                .font(Rise.Font.rounded(17, weight: .medium))
                .foregroundStyle(Rise.Color.textSecondary)
            Text("Tap + to add your first alarm")
                .font(Rise.Font.rounded(14))
                .foregroundStyle(Rise.Color.textSecondary.opacity(0.7))
        }
        .padding(.top, Rise.Spacing.xxl)
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
    let onToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Rise.Spacing.xs) {
            HStack {
                Text(alarm.time.formattedTime)
                    .font(Rise.Font.rounded(32, weight: .bold))
                    .foregroundStyle(Rise.Color.text)
                Spacer()
                Toggle("", isOn: Binding(
                    get: { alarm.isActive },
                    set: { _ in onToggle() }
                ))
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
