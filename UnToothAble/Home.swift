//
//  Home.swift
//  UnToothAble
//
//  Created by Antonio Costa on 13/03/26.
//

import SwiftUI

struct Home: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Text("UnToothAble")
                    .foregroundStyle(.red)
                    .font(.system(size: 80))

                NavigationLink {
                    ContentView()
                } label: {
                    Text("Play")
                        .foregroundStyle(.black)
                        .font(.system(size: 60))
                }
            }
            .padding()
        }
        .background(.white)

    }
}

#Preview {
    Home()
}
