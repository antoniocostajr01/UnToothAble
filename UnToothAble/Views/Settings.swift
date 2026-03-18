//
//  Settings.swift
//  UnToothAble
//
//  Created by Antonio Costa on 15/03/26.
//

import SwiftUI

struct Settings: View {
    @Environment(GameManager.self) var gameManager
    @State private var showTutorial = false
    
    var body: some View {
        VStack{
            Button {
                gameManager.goToScene(.home)
            } label: {
                Text("go back to home")
                    .foregroundStyle(.white)
                    .font(.system(size: 60))
            }
            
            Button("Ver Tutorial") {
                showTutorial = true
            }
        }
        .fullScreenCover(isPresented: $showTutorial) {
            Tutorial(fromSettings: true, onSkip: {
            }, onDismiss: {
                showTutorial = false  //volta para settings
            })
        }
    }
}

#Preview {
    Settings()
}
