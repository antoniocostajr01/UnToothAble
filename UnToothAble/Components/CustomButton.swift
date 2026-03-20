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
    var icon: IconName? = nil
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

        case .sound:
            return .iconSound

        case .restart:
            return .iconRestart

        case .home:
            return .iconHome

        case .music:
            return .iconMusic
        }
    }

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 6) {
                if let iconImage {
                    Image(iconImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                
                Text(label)
                    .font(.bangers(24))
                    .foregroundStyle(.white)
                    .customStroke(color: .black, width: 1)
            }
            .frame(width: 120, height: 42)
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

