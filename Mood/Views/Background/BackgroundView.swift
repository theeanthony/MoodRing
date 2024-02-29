//
//  BackgroundView.swift
//  Mood
//
//  Created by Anthony Contreras on 2/7/24.
//

import SwiftUI


struct BackgroundView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        
        ZStack {
            
            Group {
                if colorScheme == .light {
                    Color.offWhite
                } else {
                    LinearGradient(Color.darkStart, Color.darkEnd)
                    
                }
            }
        }
        .ignoresSafeArea(.all) // This should make it expand to all edges
    }
}


