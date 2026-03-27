//
//  SettingsRow.swift
//  UnToothAble
//
//  Created by Antonio Costa on 27/03/26.
//

import Foundation
import SwiftUI

struct SettingsRow: View {
    let title: String
    @Binding var isOn: Bool
    var isHapticsOption: Bool = false
    var onToggle: ((Bool) -> Void)? = nil

    var body: some View {
        Button {
            isOn.toggle()
            onToggle?(isOn)

            if isHapticsOption && isOn {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.prepare()
                        generator.impactOccurred()
                    }
        } label: {
            HStack {
                Text(title)
                    .font(.bangers(22))
                    .foregroundStyle(.white)
                    .customStroke(color: .stroke, width: 1)

                Spacer()

                ZStack {
                    Image("checkOff")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)

                    if isOn {
                        Image("checkOn")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }
                }
            }
            .frame(height: 36)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
