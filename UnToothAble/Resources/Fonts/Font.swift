//
//  Font.swift
//  UnToothAble
//
//  Created by Antonio Costa on 18/03/26.
//

import Foundation
import SwiftUI


enum AppFont {
    enum Bangers: String {
        case regular = "Bangers-Regular"
    }
}

extension Font{
    static func bangers(_ size: CGFloat) -> Font {
        .custom(AppFont.Bangers.regular.rawValue, size: size)
    }
    
}


/*
 Example:
 
Text("Credits")
    .font(.jotiOne(36))

*/
