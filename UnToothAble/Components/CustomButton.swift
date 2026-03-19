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
    
    var icon: IconName
    
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
    
    private var iconImage: ImageResource {
        switch icon {
        case .person:
            return .leaderboardIcon
        
        case .play:
            return .playIcon
            
        case .settings:
            return .settingsIcon
            
        case .tooth:
            return .toothIcon
            
        }
    }
    

    var body: some View {
        Button {
            action()
        } label: {
            
            HStack(spacing:0) {
                
                Image(iconImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    
                Text("\(label)  ")
                    .font(.bangers(24))
                    .foregroundStyle(.white)
                    .customStrok(color: .black, width: 1)

            }
            .frame(width: 120)
            
        }
        .background(
            Image(bgImage)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 41)
        )
        .frame(width: 120, height: 42)

    }
    
}

#Preview {
    CustomButton(label: "teste", state:.normal, icon: .play){
        print("teste")
    }
}
