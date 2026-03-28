//
//  Credits.swift
//  UnToothAble
//
//  Created by sofia leitao on 18/03/26.
//
import SwiftUI

struct CreditsView: View {
//    let onBack: () -> Void

    var body: some View {
        VStack(alignment: .leading) {

            Spacer()
            

            Text(" Created with ♥︎ by a team from \n the Apple Developer Academy poa ")
                .font(.bangers(20))
                .multilineTextAlignment(.leading)
                .lineLimit(3)
                .customStroke(color: .black, width: 1)

            VStack(alignment: .leading){
                Text(" Antonio costa    -   iOS Developer ")
                    
                Text(" Giovana Hossein  -   UX/UI DESIGNER ")
                    
                Text(" RAFAEL TONETO    -   iOS Developer ")
                    
                Text(" RICHARD FAGUNDES  -   iOS Developer ")
                    
                Text(" SOFIA LEITAO    -   iOS Developer ")
                    
            }
            .font(.bangers(15))
            .customStroke(color: .black, width: 0.5)

            
            Spacer()
        }
        .frame(width: 400, height: 200)
        .padding(.top, 24)
        .background(
            Image(.creditsBG)
                .resizable()
                .scaledToFill()
        )
    }
}

#Preview {
    CreditsView()
    
}
