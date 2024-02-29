//
//  DarkBackground.swift
//  Mood
//
//  Created by Anthony Contreras on 2/7/24.
//

import SwiftUI

struct DarkBackground<S: Shape>: View {
    var isHighlighted: Bool
    var shape: S

    var body: some View {
        ZStack {
            if isHighlighted {
                shape
                    .fill(LinearGradient(Color.darkEnd, Color.darkStart))
                         .overlay(shape.stroke(LinearGradient(Color.darkStart, Color.darkEnd), lineWidth: 4))
//                         .shadow(color: Color.darkStart, radius: 10, x: 5, y: 5)
//                         .shadow(color: Color.darkEnd, radius: 10, x: -5, y: -5)

            } else {
                shape
                    .fill(LinearGradient(Color.darkStart, Color.darkEnd))
                      .overlay(shape.stroke(LinearGradient(Color.darkStart, Color.darkEnd), lineWidth: 4))
                    .shadow(color: Color.darkStart, radius: 10, x: 5, y: 5)
                    .shadow(color: Color.darkEnd, radius: 10, x: -5, y: -5)
            }
        }
    }
}

struct DarkPressedBackground<S: Shape>: View {
    var shape: S

    var body: some View {
        ZStack {
                shape
                    .fill(LinearGradient(Color.darkEnd, Color.darkStart))
                         .overlay(shape.stroke(LinearGradient(Color.darkStart, Color.darkEnd), lineWidth: 4))
            
//                         .shadow(color: Color.darkStart, radius: 10, x: 5, y: 5)
//                         .shadow(color: Color.darkEnd, radius: 10, x: -5, y: -5)

           
        }
    }
}
struct DarkPressedRectangleBackground<S: Shape>: View {
    var shape: S

    var body: some View {
        ZStack {
            shape
                .fill(LinearGradient(gradient: Gradient(colors: [Color.darkEnd, Color.darkStart]), startPoint: .topLeading, endPoint: .bottomTrailing))
                     .overlay(shape.stroke(LinearGradient(gradient: Gradient(colors: [Color.darkStart, Color.darkEnd]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 4))
        
           
        }
    }
}

//struct DarkPressedRectangleBackground<S: Shape>: View {
//    var shape: S
//
//    var body: some View {
//        ZStack {
//            shape
//                .fill(
//                    LinearGradient(gradient: Gradient(colors: [
//                        Color.darkEnd,
//                        Color.darkMid6,
//                        Color.darkMid5,
//                        Color.darkMid4,
//                        Color.darkMid3,
//                        Color.darkMid2,
//                        Color.darkMid1,
//                        Color.darkStart
//                    ]), startPoint: .topLeading, endPoint: .bottomTrailing)
//                )
//                .overlay(
//                    shape.stroke(
//                        LinearGradient(gradient: Gradient(colors: [
//                            Color.darkStart,
//                            Color.darkMid1,
//                            Color.darkMid2,
//                            Color.darkMid3,
//                            Color.darkMid4,
//                            Color.darkMid5,
//                            Color.darkMid6,
//                            Color.darkEnd
//                        ]), startPoint: .topLeading, endPoint: .bottomTrailing),
//                        lineWidth: 4
//                    )
//                )
//
//        
//           
//        }
//    }
//}
