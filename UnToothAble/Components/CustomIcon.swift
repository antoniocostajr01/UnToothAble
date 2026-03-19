//
//  CustomIcon.swift
//  UnToothAble
//
//  Created by Antonio Costa on 18/03/26.
//

import SwiftUI

struct CustomIcon: View {
    
    var state: ButtonState
    
    var icon: IconName
    
    var action: () -> Void
    
    private var bgImage: ImageResource {
        switch state {
        case .normal:
            return .iconDefault
        case .pressed:
            return .iconSelected
        case .notPressed:
            return .iconNotSelected
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
            ZStack(alignment: .center){
                Image(bgImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 41, height: 41)
                
                Image(iconImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
            
        }
    }
}

#Preview {
    CustomIcon(state: .normal, icon: .play) {
        print("ervgev")
    }
}

