//
//  Credits.swift
//  UnToothAble
//
//  Created by sofia leitao on 18/03/26.
//
import SwiftUI

struct CreditsView: View {
    let onBack: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Button {
                onBack()
            } label: {
                Text("Back")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(.black)
            }

            Text("Créditos")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.black)

            Text("Desenvolvido por: Giovana, Sofia, Chico, Richard e Rafael")
            .font(.system(size: 22))
            .foregroundStyle(.black)

            Spacer()
        }
        .padding(24)
        .background(Color.white.ignoresSafeArea())
    }
}
