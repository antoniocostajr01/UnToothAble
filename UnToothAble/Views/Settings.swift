//
//  Settings.swift
//  UnToothAble
//
//  Created by Antonio Costa on 15/03/26.
//

import SwiftUI
import UIKit

struct Settings: View {
    @Environment(GameManager.self) var gameManager

    @State private var showTutorial = false
    @State private var showCredits = false

    @State private var showHistoryAlways = false
    @State private var musicEnabled = false
    @State private var hapticsEnabled = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Settings")
                .font(.system(size: 18))
                .foregroundStyle(.gray)
                .padding(.top, 10)

            Button {
                gameManager.goToScene(.home)
            } label: {
                Text("Back")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(.black)
            }

            VStack(alignment: .leading, spacing: 26) {
                SettingsCheckboxRow(
                    title: "Mostrar História sempre",
                    isOn: $showHistoryAlways
                )

                SettingsCheckboxRow(
                    title: "Música",
                    isOn: $musicEnabled
                )

                SettingsCheckboxRow(
                    title: "Haptics",
                    isOn: $hapticsEnabled,
                    isHapticsOption: true
                )
            }
            .padding(.top, 10)

            VStack(alignment: .leading, spacing: 16) {
                Button {
                    showTutorial = true
                } label: {
                    Text("Jogar Tutorial")
                        .font(.system(size: 28))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .overlay(
                            Rectangle()
                                .stroke(Color.black, lineWidth: 2)
                        )
                }

                Button {
                    showCredits = true
                } label: {
                    Text("Creditos")
                        .font(.system(size: 26))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .overlay(
                            Rectangle()
                                .stroke(Color.black, lineWidth: 2)
                        )
                }
            }
            .padding(.top, 10)

            Spacer()
        }
        .padding(.horizontal, 24)
        .background(Color.white.ignoresSafeArea())
        .fullScreenCover(isPresented: $showTutorial) {
            Tutorial(
                fromSettings: true,
                onSkip: {},
                onDismiss: {
                    showTutorial = false
                }
            )
        }
        .fullScreenCover(isPresented: $showCredits) {
            CreditsView {
                showCredits = false
            }
        }
    }
}

struct SettingsCheckboxRow: View {
    let title: String
    @Binding var isOn: Bool
    var isHapticsOption: Bool = false

    var body: some View {
        Button {
            isOn.toggle()

            if isHapticsOption && isOn {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            }
        } label: {
            HStack(spacing: 20) {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(width: 36, height: 36)
                    .overlay {
                        if isOn {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.black)
                        }
                    }

                Text(title)
                    .font(.system(size: 26))
                    .foregroundStyle(.black)

                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
}
