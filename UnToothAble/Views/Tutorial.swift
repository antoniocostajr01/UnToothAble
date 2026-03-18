//
//  Tutorial.swift
//  UnToothAble
//
//  Created by sofia leitao on 17/03/26.
//
import SwiftUI

struct Tutorial: View {
    let fromSettings: Bool
    let onSkip: () -> Void
    let onDismiss: (() -> Void)? //so usado quando vem de settings

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Text("Tutorial")
                .foregroundStyle(.white)
                .font(.system(size: 48, weight: .bold))

            VStack {
                Spacer()
                Button {
                    if fromSettings {
                        onDismiss?()
                    } else {
                        onSkip()
                    }
                } label: {
                    Text("Skip")
                        .foregroundStyle(.black)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(.white)
                        .clipShape(Capsule())
                }
                .padding(.bottom, 60)
            }
        }
    }
}
