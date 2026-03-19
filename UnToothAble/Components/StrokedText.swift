//
//  TextOutline.swift
//  UnToothAble
//
//  Created by Antonio Costa on 18/03/26.
//

import Foundation
import SwiftUI

// MARK: - Modificador de Contorno (Stroke)
struct StrokedText: View {
    let text: String
    let font: Font
    let strokeColor: Color
    let strokeWidth: CGFloat
    let fillColor: Color
    
    var body: some View {
        ZStack {
            // Camadas de stroke ao redor
            ForEach([-strokeWidth, strokeWidth], id: \.self) { x in
                ForEach([-strokeWidth, strokeWidth], id: \.self) { y in
                    Text("\(text) ")
                        .font(font)
                        .foregroundStyle(strokeColor)
                        .offset(x: x, y: y)
                }
            }
            // Texto principal por cima
            Text("\(text) ")
                .font(font)
                .foregroundStyle(fillColor)
        }
    }
}
