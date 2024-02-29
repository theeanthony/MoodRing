//
//  AppColors.swift
//  Mood
//
//  Created by Anthony Contreras on 2/7/24.
//

import Foundation
import SwiftUI

extension Color {
    static let offWhite = Color(red: 225 / 255, green: 225 / 255, blue: 235 / 255)
    
    static let darkStart = Color(red: 50 / 255, green: 60 / 255, blue: 65 / 255)
    static let darkMid1 = Color(red: 45 / 255, green: 55 / 255, blue: 60 / 255)
        static let darkMid2 = Color(red: 40 / 255, green: 50 / 255, blue: 55 / 255)
        static let darkMid3 = Color(red: 35 / 255, green: 45 / 255, blue: 50 / 255)
        static let darkMid4 = Color(red: 30 / 255, green: 40 / 255, blue: 45 / 255)
        static let darkMid5 = Color(red: 27 / 255, green: 32 / 255, blue: 37 / 255)
        static let darkMid6 = Color(red: 26 / 255, green: 29 / 255, blue: 33 / 255)
    static let darkEnd = Color(red: 25 / 255, green: 25 / 255, blue: 30 / 255)
}

extension LinearGradient {
    init(_ colors: Color...) {
        self.init(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
