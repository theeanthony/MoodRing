//
//  ColorModel.swift
//  Mood
//
//  Created by Anthony Contreras on 2/7/24.
//

import Foundation
import SwiftUI
import CoreData


class BluetoothDevice: Identifiable, Codable {
    var id: UUID
    var name: String
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}

struct ColorCollectionModel:  Codable {
    let savedTemplates: [SavedColorModels]
    
}

struct SavedColorModels : Hashable, Codable, Identifiable {
    let id : UUID
    var savedColorModels : [SavedColorModel]
    var rateOfChange: Int

    
}


struct SavedColorModel: Hashable, Codable, Identifiable {
    let id: UUID
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
    var alpha: CGFloat
    
    init(id:UUID, color: UIColor) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        self.id = id
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
    var uiColor: UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}


struct ColorCommandPayload {
    let colors: [SavedColorModel]
    let rateOfChange: Int
    var sequenceNumber: Int 
    
    func serialize() -> String {
//        var commandParts: [String] = ["[START]", "Seq:\(sequenceNumber)"]
        var commandParts: [String] = ["[START Seq:\(sequenceNumber)]"]

        print(" Color command being sent ")

        for color in colors {
            let colorCommand = "\(Int(color.red * 255)),\(Int(color.green * 255)),\(Int(color.blue * 255));"
            print(colorCommand)
            print(" - ")
            commandParts.append(colorCommand)
        }
        
        commandParts.append("R:\(rateOfChange)")
        
        // Calculate checksum
        let fullCommandWithoutChecksum = commandParts.joined(separator: ",")
        var checksum: UInt8 = 0
        for byte in fullCommandWithoutChecksum.utf8 {
            checksum = checksum &+ byte
        }
        
        commandParts.append("C:\(checksum)[END]\n")
        
        return commandParts.joined(separator: ",")
    }
    func heartSerialize() -> String {
        var commandParts: [String] = ["[HSTART Seq:\(sequenceNumber)]"]

        print(" Color command being sent ")

        for color in colors {
            let colorCommand = "\(Int(color.red * 255)),\(Int(color.green * 255)),\(Int(color.blue * 255));"
            print(colorCommand)
            print(" - ")
            commandParts.append(colorCommand)
        }
        
        commandParts.append("R:\(rateOfChange)")
        
        // Calculate checksum
        let fullCommandWithoutChecksum = commandParts.joined(separator: ",")
        var checksum: UInt8 = 0
        for byte in fullCommandWithoutChecksum.utf8 {
            checksum = checksum &+ byte
        }
        
        commandParts.append("C:\(checksum)[END]\n")
        
        return commandParts.joined(separator: ",")
    }
}
