//
//  CustomButton.swift
//  UnToothAble
//
//  Created by Antonio Costa on 18/03/26.
//
import SwiftUI

struct CustomButton: View {
    
    var label: String
    var state: ButtonState
    var icon: IconName?
    var width: CGFloat = 120
    var action: () -> Void
    
    private var bgImage: ImageResource {
        switch state {
        case .normal:
            return .buttonDefault
        case .pressed:
            return .buttonSelected
        case .notPressed:
            return .buttonNotSelected
        }
    }
    
    private var iconImage: ImageResource? {
        guard let icon else { return nil }
        
        switch icon {
        case .person:
            return .leaderboardIcon
        case .play:
            return .playIcon
        case .settings:
            return .settingsIcon
        case .tooth:
            return .toothIcon
        case .none:
            return nil
        case .home:
            return .homeIcon
        case .restart:
            return .restartIcon
        }
    }

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 0) {
                
                if let iconImage {
                    Image(iconImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
                
                Text("\(label)  ")
                    .font(.bangers(21))
                    .foregroundStyle(.white)
            }
            .frame(width: width)
        }
        .background(
            Image(bgImage)
                .resizable()
//                .scaledToFit()
                .frame(width: width, height: 41)
        )
        .frame(width: width, height: 42)
    }
}

#Preview {
    VStack(spacing: 20) {
        CustomButton(label: "teste", state: .normal, icon: .play) {
            print("teste")
        }

        CustomButton(label: " Continue? (Ad) ", state: .normal, icon: .none, width: 170) {
            print("continue")
        }
    }
}
