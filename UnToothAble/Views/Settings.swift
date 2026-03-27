import SwiftUI
import UIKit

struct Settings: View {
    @Binding var isPresented: Bool
    
    @State private var showTutorial = false
    @State private var showCredits = false
    
    @State private var showHistoryAlways = UserDefaults.standard.bool(forKey: "showHistoryAlways")
    @AppStorage("musicEnabled") private var musicEnabled = true
    @State private var hapticsEnabled = UserDefaults.standard.object(forKey: "hapticsEnabled") as? Bool ?? true
    
    // ✅ NOVO ESTADO
    @State private var currentScreen: SettingsScreen = .main
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            
            switch currentScreen {
            case .main:
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
                        ) { isOn in
                            UserDefaults.standard.set(isOn, forKey: "hapticsEnabled")
                        }
                        
                        HStack(spacing: 14) {
                            CustomButton(label: "TUTORIAL ", state: .normal, icon: nil) {
                                showTutorial = true
                            }
                            
                            CustomButton(label: "CREDITS ", state: .normal, icon: nil) {
                                withAnimation {
                                    currentScreen = .credits
                                }
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
                
            case .credits:
                CreditsView ()
            }
            
            
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                    if currentScreen == .main {
                        isPresented = false
                    } else {
                        currentScreen = .main
                    }
                }
            } label: {
                Image("x")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
            }
            .offset(x: currentScreen == .main ? 5 : 30, y: currentScreen == .main ? 20 : 10)
            
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
    }
}



#Preview {
    Settings(isPresented: .constant(true))
        .background(Color.black)
        .environment(GameManager())
}
