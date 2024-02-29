//
//  NeoButtonStyle.swift
//  Mood
//
//  Created by Anthony Contreras on 2/7/24.
//

import SwiftUI

struct NeumorphicButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(20)
            .contentShape(Circle())
            .background(
                Group {
                    if configuration.isPressed {
                        Circle()
                            .fill(Color.offWhite)
                            .overlay(
                                Circle()
                                    .stroke(Color.gray, lineWidth: 4)
                                    .blur(radius: 4)
                                    .offset(x: 2, y: 2)
                                    .mask(Circle().fill(LinearGradient(Color.black, Color.clear)))
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 8)
                                    .blur(radius: 4)
                                    .offset(x: -2, y: -2)
                                    .mask(Circle().fill(LinearGradient(Color.clear, Color.black)))
                            )
                    } else {
                        Circle()
                            .fill(Color.offWhite)

//                            .fill(Color(UIColor.systemBackground)) // Adapts to light or dark mode
                            .shadow(color: .black.opacity(0.2), radius: 10, x: -10, y: -10)
                            .shadow(color: .white.opacity(0.7), radius: 10, x: 10, y: 10)
                    }
                }
            )
//            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}
struct NeumorphicPressedButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(20)
            .contentShape(Circle())
            .background(
                Group {
                        Circle()
                            .fill(Color.offWhite)
                            .overlay(
                                Circle()
                                    .stroke(Color.gray, lineWidth: 4)
                                    .blur(radius: 4)
                                    .offset(x: 2, y: 2)
                                    .mask(Circle().fill(LinearGradient(Color.black, Color.clear)))
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 8)
                                    .blur(radius: 4)
                                    .offset(x: -2, y: -2)
                                    .mask(Circle().fill(LinearGradient(Color.clear, Color.black)))
                            )
  
                }
            )
//            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}
struct DarkPressedButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(20)
            .contentShape(Circle())
            .animation(nil)

            .background(
                DarkPressedBackground( shape: Circle())
            )
    }
}
struct DarkButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(20)
            .contentShape(Circle())
            .animation(nil)

            .background(
                DarkBackground(isHighlighted: configuration.isPressed, shape: Circle())
            )
    }
}
struct ConditionalButtonStyle: ButtonStyle {
    var useDarkStyle: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        Group {
            if useDarkStyle {
                DarkButtonStyle().makeBody(configuration: configuration)
            } else {
                NeumorphicButtonStyle().makeBody(configuration: configuration)
            }
        }
    }
}

struct ConditionalPressedButtonStyle: ButtonStyle {
    var useDarkStyle: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        Group {
            if useDarkStyle {
                DarkPressedButtonStyle().makeBody(configuration: configuration)
            } else {
                NeumorphicPressedButtonStyle().makeBody(configuration: configuration)
            }
        }
    }
}

struct ConditionalBackgroundModifier<S: Shape>: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    let shape: S

    func body(content: Content) -> some View {
        content
            .background(
                Group {
                    if colorScheme == .dark {
                        DarkPressedRectangleBackground(shape: shape)
                    } else {
                        NeumorphicAlwaysPressedBackground(shape: shape)
                    }
                }
            )
    }
}

// View extension to easily apply the modifier
extension View {
    func conditionalBackground<S: Shape>(shape: S) -> some View {
        self.modifier(ConditionalBackgroundModifier(shape: shape))
    }
}


struct NeumorphicAlwaysPressedBackground<S: Shape>: View {
    let shape: S

    private var baseGradient: LinearGradient {
      
            LinearGradient(Color.offWhite, Color.offWhite)
    }
    
    private var strokeGradient: LinearGradient {
       
            LinearGradient(Color.gray, Color.white)
    }

    var body: some View {
        shape
            .fill(baseGradient)
            .overlay(
                shape
                    .stroke(strokeGradient, lineWidth: 4)
                    .blur(radius: 4)
                    .offset(x: 2, y: 2)
                    .mask(
                        shape.fill(LinearGradient(Color.black, Color.clear))
                    )
            )
            .overlay(
                shape
                    .stroke(strokeGradient, lineWidth: 8)
                    .blur(radius: 4)
                    .offset(x: -2, y: -2)
                    .mask(
                        shape.fill(LinearGradient(Color.clear, Color.black))
                    )
            )
    }
}

// Extending Color to define colors for both light and dark themes

