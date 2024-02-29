//
//  PulseSearchView.swift
//  Mood
//
//  Created by Anthony Contreras on 2/21/24.
//

import SwiftUI

struct PulseSearchView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.red.opacity(0.5))
                .frame(width: 100, height: 100)
                .scaleEffect(animate ? 1.0 : 0.5)
                .opacity(animate ? 0.0 : 1.0)
                .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true), value: animate)
            
            Image(systemName: "heart.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .foregroundColor(.red)
        }
        .onAppear {
            self.animate = true
        }
    }
}
struct HeartBeat : Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX-20, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: (rect.midY+rect.maxY)/2))
        path.addLine(to: CGPoint(x: rect.midX+10, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX+20, y: (rect.midY/2)))
        path.addLine(to: CGPoint(x: rect.midX+40, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}
struct HeartBeatView : View {
    @State var trimValue1 : CGFloat = 0
    @State var trimValue2 : CGFloat = 0
    @State private var animate = false

    var body: some View {
            
            HeartBeat()
                 .trim(from: 0, to: animate ? 1 : 0)
                 .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                 .foregroundColor(.red)
                 .onAppear {
                     withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: false)) {
                         animate = true
                     }
                 }
                 .frame(width: 100, height: 125)
            
    }
}
