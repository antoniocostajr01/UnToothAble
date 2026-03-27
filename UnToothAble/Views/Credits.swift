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
                Image(.x)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
                    .offset(x: 610)
            }

            Text("Created with 􀊵 by a team from the Apple Developer Academy poa")
                .font(.bangers(19))
                .customStroke(color: .black, width: 2)

            Text("""
            Antonio costa    -   iOS Developer
            Giovana Hossein  -   UX/UI DESIGNER
            RAFAEL TONETO    -   iOS Developer
            RICHARD FAGUNDES  -   iOS Developer
            SOFIA LEITAO    -   iOS Developer
            """)
            .font(.bangers(19))
            .customStroke(color: .black, width: 1)
            
            Spacer()
        }
        .padding(24)
        .background(
            
            Image(.creditsBG)
                .resizable()
                .scaledToFill()
        )
    }
}

#Preview {
    CreditsView() {
        print("")
    }
    .background(
        Color.black
            .ignoresSafeArea()
        
    )
}
