//
//  GameOver.swift
//  UnToothAble
//
//  Created by Rafael Toneto on 16/03/26.
//


import SwiftUI

struct GameOver: View {

    @Environment(GameManager.self) var gameManager

    var score: Int
    var onRestart: () -> Void
    var onContinue: () -> Void

    var body: some View {

        VStack(spacing: 30) {

            Text("Game Over")
                .font(.system(size: 60, weight: .bold))
                .foregroundStyle(.black)

            Text("Score: \(score)")
                .font(.system(size: 40))
                .foregroundStyle(.black)

            VStack(spacing: 20) {

                Button("Continue Run") {
                    onContinue()
                    gameManager.goToScene(.game)
                }
                .buttonStyle(.bordered)

                Button("Restart Run") {
                    onRestart()
                    gameManager.goToScene(.game)
                }
                .buttonStyle(.bordered)

                Button("Back to Menu") {
                    gameManager.goToScene(.home)
                }
                .buttonStyle(.bordered)
            }
            .font(.system(size: 30))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
    }
}
