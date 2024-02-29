//
//  LabelBackgroundView.swift
//  Mood
//
//  Created by Anthony Contreras on 2/7/24.
//

import SwiftUI

struct LabelBackgroundView: View {
    @Environment (\.colorScheme) var color
    var body: some View {
        ZStack{
            if color == .light {
                Color.offWhite
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.offWhite)

                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                    .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5)

            }else{
                RoundedRectangle(cornerRadius: 25)
                    .fill(LinearGradient(Color.darkStart, Color.darkEnd))
//                    .shadow(color: Color.darkStart, radius: 10, x: 5, y: 5)
//                    .shadow(color: Color.darkEnd, radius: 10, x: -5, y: -5)

            }
        }
    }
}

#Preview {
    LabelBackgroundView()
}
