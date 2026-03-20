import SwiftUI
import UIKit

struct Settings: View {
    @Binding var isPresented: Bool

    @State private var showTutorial = false
    @State private var showCredits = false

    @State private var showHistoryAlways = false
    @State private var musicEnabled = false
    @State private var hapticsEnabled = false

    var body: some View {
        ZStack(alignment: .top) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(red: 0.45, green: 0.58, blue: 0.88))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .strokeBorder(Color(red: 0.25, green: 0.35, blue: 0.70), lineWidth: 4)
                    )

                HStack {
                    Spacer()

                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(red: 0.60, green: 0.70, blue: 0.95).opacity(0.45))
                        .frame(width: 16)
                        .padding(.vertical, 20)
                        .padding(.trailing, 10)
                }
                .clipShape(RoundedRectangle(cornerRadius: 24))

                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 18) {
                        SettingsCheckboxRow(
                            title: "ALWAYS SHOW STORY ",
                            isOn: $showHistoryAlways
                        )

                        SettingsCheckboxRow(
                            title: " MUSIC ",
                            isOn: $musicEnabled
                        )

                        SettingsCheckboxRow(
                            title: " HAPTICS ",
                            isOn: $hapticsEnabled,
                            isHapticsOption: true
                        )
                    }

                    HStack(spacing: 14) {
                        CustomButton(label: "TUTORIAL ", state: .normal, icon: nil) {
                            showTutorial = true
                        }

                        CustomButton(label: "CREDITS ", state: .normal, icon: nil) {
                            showCredits = true
                        }
                    }
                    .padding(.top, 6)
                }
                .padding(.top, 28)
                .padding(.bottom, 28)
                .padding(.leading, 24)
                .padding(.trailing, 44)
            }
            .frame(width: 382, height: 264)
            .shadow(color: .black.opacity(0.45), radius: 16, x: 0, y: 8)

            Text("SETTINGS ")
                .font(.bangers(52))
                .foregroundStyle(.white)
                .customStroke(color: .black, width: 2)
                .offset(y: -30)

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                    isPresented = false
                }
            } label: {
                ZStack {
                    Image("x")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                }
            }
            .frame(width: 382, height: 264, alignment: .topTrailing)
            .offset(x: 10, y: -15)
        }
        .frame(width: 382, height: 264)
        .padding(.top, 36)
        .fullScreenCover(isPresented: $showTutorial) {
            Tutorial(
                fromSettings: true,
                onSkip: {},
                onDismiss: { showTutorial = false }
            )
        }
        .fullScreenCover(isPresented: $showCredits) {
            CreditsView {
                showCredits = false
            }
        }
    }
}

// MARK: - Checkbox Row

struct SettingsCheckboxRow: View {
    let title: String
    @Binding var isOn: Bool
    var isHapticsOption: Bool = false

    var body: some View {
        Button {
            isOn.toggle()

            if isHapticsOption && isOn {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.prepare()
                generator.impactOccurred()
            }
        } label: {
            HStack {
                Text(title)
                    .font(.bangers(26))
                    .foregroundStyle(.white)
                    .customStroke(color: .black, width: 1)

                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: 0.62, green: 0.70, blue: 0.88))
                        .frame(width: 36, height: 36)

                    if isOn {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .black))
                            .foregroundStyle(.black)
                    }
                }
            }
            .padding(.trailing, 16)
        }
        .buttonStyle(.plain)
    }
}
