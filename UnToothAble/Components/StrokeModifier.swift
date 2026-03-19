//
//  TextOutline.swift
//  UnToothAble
//
//  Created by Antonio Costa on 18/03/26.
//

import Foundation
import SwiftUI

struct StrokeModifier: ViewModifier {
    var strokeSize: CGFloat = 1
    var strokeColor: Color = .blue

    func body(content: Content) -> some View {
        content
            .padding(strokeSize)
            .background(
                Rectangle()
                    .foregroundStyle(strokeColor)
                    .mask(outline(context: content))
            )
    }

    private func outline(context: Content) -> some View {
        // 1. Criamos um ID constante para o símbolo
        let textID = 0
        
        return Canvas { canvasContext, size in
            canvasContext.addFilter(.alphaThreshold(min: 0.01))
            canvasContext.drawLayer { layer in
                // 2. Usamos o ID constante aqui para buscar o texto
                if let text = canvasContext.resolveSymbol(id: textID) {
                    layer.draw(text, at: CGPoint(x: size.width / 2, y: size.height / 2))
                }
            }
        } symbols: {
            // 3. Usamos o MESMO ID constante aqui na tag
            context.tag(textID).blur(radius: strokeSize)
        }
    }
}

extension View {
    func customStrok(color: Color, width: CGFloat) -> some View {
        self.modifier(StrokeModifier(strokeSize: width, strokeColor: color))
    }
}
