//
//  PauseMenu.swift
//  UnToothAble
//
//  Created by Richard Rodrigues on 15/03/26.
//

import SwiftUI

struct PauseMenu: View {
    @Environment(GameManager.self) var gameManager
    @Binding var showPauseMenu: Bool

    @AppStorage("isHapticOn") private var isHapticOn: Bool = true
    @AppStorage("isMusicOn") private var isMusicOn: Bool = true

    var body: some View {
        ZStack {
            Color.black.opacity(0.75)
                .ignoresSafeArea()

            ZStack {
                Image(.pauseBackGround)

                VStack(spacing: 40) {
                    VStack(spacing: 32) {
                        HStack(spacing: 40) {
                            Button {
                                isHapticOn.toggle()
                            } label: {
                                Image(.iconHaptics)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                            }
                            .background(
                                Image(isHapticOn ? .iconSelected : .iconNotSelected)
                                    .resizable()
                                    .frame(width: 41, height: 41)
                            )

                            Button {
                                isMusicOn.toggle()
                                AudioManager.shared.toggleMute()
                            } label: {
                                Image(.iconMusic)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                            }
                            .background(
                                Image(isMusicOn ? .iconSelected : .iconNotSelected)
                                    .resizable()
                                    .frame(width: 41, height: 41)
                            )
                        }
                        .padding(.top, 30)

                        HStack(spacing: 40) {
                            Button {
                                gameManager.gameScene.resumeGame()
                                gameManager.resetReviveForNewRun()
                                gameManager.gameScene.restartGame()
                                showPauseMenu = false
                            } label: {
                                Image(.iconRestart)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                            }
                            .background(
                                Image(.iconDefault)
                                    .resizable()
                                    .frame(width: 41, height: 41)
                            )

                            Button {
                                gameManager.resetReviveForNewRun()
                                gameManager.gameScene.restartGame()
                                showPauseMenu = false
                                gameManager.goToScene(.home)
                            } label: {
                                Image(.iconHome)
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                            }
                            .background(
                                Image(.iconDefault)
                                    .resizable()
                                    .frame(width: 41, height: 41)
                            )
                        }
                    }

                    CustomButton(label: "RESUME", state: .normal, icon: Optional.none) {
                        gameManager.gameScene.resumeGame()
                        showPauseMenu = false
                    }
                }
            }
            .overlay(alignment: .top) {
                Text(" PAUSED! ")
                    .font(.bangers(34))
                    .foregroundStyle(.white)
                    .customStroke(color: Color(.lightBlueStroke), width: 1)
                    .padding(.top, 3)
            }
        }
    }
}
