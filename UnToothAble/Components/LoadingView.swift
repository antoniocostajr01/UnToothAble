//
//  LoadingView.swift
//  UnToothAble
//
//  Created by Antonio Costa on 26/03/26.
//

import SwiftUI


struct LoadingView: View {
    @State private var dotCount = 0
    
    var body: some View {
        Text(" Loading\(dots) ")
            .font(.bangers(32))
            .customStroke(color: .darkBlueStroke, width: 2)
            .task {
                while true {
                    try? await Task.sleep(for: .seconds(0.5))
                    dotCount = (dotCount + 1) % 4
                }
            }
    }
    
    var dots: String {
        String(repeating: ".", count: dotCount)
    }
}

#Preview {
    LoadingView()
}
