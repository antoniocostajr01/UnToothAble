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

    @AppStorage("isSoundOn") private var isSoundOn: Bool = true
    @AppStorage("isMusicOn") private var isMusicOn: Bool = true

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            ZStack {
                Image(.pauseBackGround)

                VStack(spacing: 40) {
                    VStack(spacing: 32) {
                        HStack(spacing: 40) {
                            Button {
                                isSoundOn.toggle()
                            } label: {
                                Image(.iconSound)
                                    .frame(width: 24, height: 24)
                            }
                            .background(
                                Image(isSoundOn ? .iconSelected : .iconNotSelected)
                                    .resizable()
                                    .frame(width: 41, height: 41)
                            )

                            Button {
                                isMusicOn.toggle()
                            } label: {
                                Image(.iconMusic)
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
                                    .frame(width: 24, height: 24)
                            }
                            .background(
                                Image(.iconDefault)
                                    .resizable()
                                    .frame(width: 41, height: 41)
                            )
                        }
                    }

                    CustomButton(label: "RESUME", state: .normal, icon: .none) {
                        gameManager.gameScene.resumeGame()
                        showPauseMenu = false
                    }
                }
            }
            .overlay(alignment: .top) {
                Image(.paused)
                    .offset(x: 10, y: -30)
            }
        }
    }
}
