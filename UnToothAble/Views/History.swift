//
// History.swift
// UnToothAble
//
// Created by Antonio Costa on 26/03/26.
//

import SwiftUI
struct History: View {
    @State var currentDialogueIndex = 0
    @State var currentImage: ImageResource = .history
    @Environment(GameManager.self) var gameManager
    var dialogues = ["A child has just lost a tooth.\nExcited, they decide to place it under their pillow for the Tooth Fairy.", "He doesn’t want to disappear in the middle of the night or be taken by the Tooth Fairy. As soon as he touches the ground, he decides to run away. Now he will need to run, dodge obstacles, and face everything that comes his way.", "Because this is not just any tooth… \nThis tooth is…"]
    
    private var text: String { guard dialogues.indices.contains(currentDialogueIndex) else { return "" }
        return dialogues[currentDialogueIndex]
    }
    
    var body: some View {
        VStack{
            Spacer()
            HStack {
                ZStack{
                    ZStack {
                        
                        Image(.dialogue)
                            .resizable(capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20), resizingMode: .stretch)
                            .foregroundStyle(.clear)
                        
                        Text(text)
                            .foregroundStyle(.darkGrayStroke)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .frame(maxWidth: 534, alignment: .leading)
                            .overlay {
                                if currentDialogueIndex == 2 {
                                    Image(.miniLogo)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 127, height: 25)
                                        .offset(x: -100, y: 12)
                                }
                            }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
                
                
                CustomButton(label: "NEXT", state: .normal) {
                    backgroundControl()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Image(currentImage)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
    }
    
    func backgroundControl() {
        indexIncrement()
        switch currentDialogueIndex {
        case 1: self.currentImage = .history2
        case 2: self.currentImage = .history3
        case 3: gameManager.hasSawHistory = true
            gameManager.goToScene(.home)
        default: break
        }
    }
    func indexIncrement() {
        currentDialogueIndex += 1
    }
}

#Preview("Dialogue 3") {
    History(currentDialogueIndex: 2, currentImage: .history3)
        .environment(GameManager())
}
