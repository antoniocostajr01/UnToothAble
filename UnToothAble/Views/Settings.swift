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
            ZStack(alignment: .topLeading) {

                Image("settings")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 300)

                VStack(alignment: .leading, spacing: 10) {

                    Spacer().frame(height: 48)

                    SettingsRow(
                        title: " ALWAYS SHOW STORY ",
                        isOn: $showHistoryAlways
                    )

                    SettingsRow(
                        title: " MUSIC ",
                        isOn: $musicEnabled
                    )

                    SettingsRow(
                        title: " HAPTICS ",
                        isOn: $hapticsEnabled,
                        isHapticsOption: true
                    )


                    HStack(spacing: 14) {
                        CustomButton(label: "TUTORIAL ", state: .normal, icon: nil) {
                            showTutorial = true
                        }

                        CustomButton(label: "CREDITS ", state: .normal, icon: nil) {
                            showCredits = true
                        }
                    }

                    Spacer()
                }
                .padding(.leading, 24)
                .padding(.trailing, 24)
                .padding(.top, 70)
                .frame(width: 382, height: 264)
            }

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                    isPresented = false
                }
            } label: {
                Image("x")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
            }
            .frame(width: 382, height: 264, alignment: .topTrailing)
            .offset(x: 10, y: 30)
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

struct SettingsRow: View {
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
                    .font(.bangers(22))
                    .foregroundStyle(.white)
                    .customStroke(color: .stroke, width: 1)

                Spacer()

                ZStack {
                    Image("checkOff")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)

                    if isOn {
                        Image("checkOn")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }
                }
            }
            .frame(height: 36)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
