//
//  ImagePlaceholder.swift
//  UnToothAble
//
//  Created by Antonio Costa on 13/03/26.
//

import Foundation
import SwiftUI

struct ImagePlaceholder: View {
    var image: Image
    
    var body: some View {
        ZStack {
            image
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
    }
}
