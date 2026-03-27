import SwiftUI
import UIKit

struct Settings: View {
    @Binding var isPresented: Bool

    @State private var showTutorial = false
    @State private var showCredits = false

    @State private var showHistoryAlways = UserDefaults.standard.bool(forKey: "showHistoryAlways")
    @AppStorage("musicEnabled") private var musicEnabled = true
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true

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
                    ) { isOn in
                        UserDefaults.standard.set(isOn, forKey: "showHistoryAlways")
                    }

                    SettingsRow(
                        title: " MUSIC ",
                        isOn: $musicEnabled
                    ) { isOn in
                        AudioManager.shared.setMusicEnabled(isOn)

                        if isOn {
                            AudioManager.shared.playMusic(named: "backgroundSong.mp3")
                        }
                    }

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
                    .frame(maxWidth: .infinity, alignment: .center)

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
    var onToggle: ((Bool) -> Void)? = nil

    var body: some View {
        Button {
            isOn.toggle()
            onToggle?(isOn)

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
