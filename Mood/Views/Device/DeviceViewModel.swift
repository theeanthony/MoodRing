//
//  DeviceViewModel.swift
//  Mood
//
//  Created by Anthony Contreras on 2/6/24.
//

import Foundation
import CoreBluetooth

class DeviceViewModel: ObservableObject {
    let peripheral: CBPeripheral
    var bluetoothManager: BluetoothManager
    
    var sequenceNumber : Int = 0
    var lastCommandSent: String?
//    var onResendRequested: (() -> Void)?

    init(peripheral: CBPeripheral, bluetoothManager: BluetoothManager) {
        self.peripheral = peripheral
        self.bluetoothManager = bluetoothManager
        setupResendCallback()

    }
    
    private func setupResendCallback() {
        bluetoothManager.onResendRequested = { [weak self] in
            self?.resendLastCommand()
        }
    }
    
    func sendColorCommand(red: UInt8, green: UInt8, blue: UInt8) {
         let command = "\(red):\(green):\(blue)\n" // Added newline as command terminator
         guard let data = command.data(using: .utf8) else { return }
         
         // Assuming you've discovered services and characteristics previously
         // Let's find the specific characteristic you want to write to
         let targetServiceUUID = CBUUID(string: "FFE0") // UUID for the service
         let targetCharacteristicUUID = CBUUID(string: "FFE1") // UUID for the writable characteristic
         
         // Search for the target service
         if let targetService = peripheral.services?.first(where: { $0.uuid == targetServiceUUID }) {
             // Search for the target characteristic within the service
             if let targetCharacteristic = targetService.characteristics?.first(where: { $0.uuid == targetCharacteristicUUID }) {
                 // Write the command to the characteristic
                 print("color data \(command)")

                 print("color data \(data)")

                 bluetoothManager.writeValue(toCharacteristic: targetCharacteristic, onPeripheral: peripheral, data: data)
             } else {
                 print("Target characteristic not found.")
             }
         } else {
             print("Target service not found.")
         }
     }
    func sendArrayColorCommands(_ colors: [SavedColorModel], rateOfChange: Int) {
        let targetServiceUUID = CBUUID(string: "FFE0")
        let targetCharacteristicUUID = CBUUID(string: "FFE1")
        
        if let targetService = peripheral.services?.first(where: { $0.uuid == targetServiceUUID }),
           let targetCharacteristic = targetService.characteristics?.first(where: { $0.uuid == targetCharacteristicUUID }) {
            
     
            let payload = ColorCommandPayload(colors: colors, rateOfChange: rateOfChange, sequenceNumber: sequenceNumber)
            
            self.sequenceNumber += 1
            let serializedPayload = payload.serialize()
            lastCommandSent = serializedPayload // Store the last command sent

             guard let data = serializedPayload.data(using: .utf8) else {
                 print("Failed to convert payload to data.")
                 return
             }
            
//         
            bluetoothManager.writeValue(toCharacteristic: targetCharacteristic, onPeripheral: peripheral, data: data)
        } else {
            print("Target service or characteristic not found.")
        }
    }
    
    
    func resendLastCommand() {
        guard let lastCommand = lastCommandSent else {
            print("No last command to resend.")
            return
        }
        let targetServiceUUID = CBUUID(string: "FFE0")
        let targetCharacteristicUUID = CBUUID(string: "FFE1")
        print("resend command being called")
        if let targetService = peripheral.services?.first(where: { $0.uuid == targetServiceUUID }),
           let targetCharacteristic = targetService.characteristics?.first(where: { $0.uuid == targetCharacteristicUUID }) {
            guard let data = lastCommand.data(using: .utf8) else {
                print("Failed to convert payload to data.")
                return
            }
            bluetoothManager.writeValue(toCharacteristic: targetCharacteristic, onPeripheral: peripheral, data: data)

        }
        
    }



    func sendHeartCommand() {
        let targetServiceUUID = CBUUID(string: "FFE0") // UUID for the service
        let targetCharacteristicUUID = CBUUID(string: "FFE1") // UUID for the writable characteristic
        
        self.sequenceNumber += 1

        let payload = ColorCommandPayload(colors: [], rateOfChange: 0, sequenceNumber: sequenceNumber)
        let serializedPayload = payload.heartSerialize()
//        serializedPayload = "H" + serializedPayload
        lastCommandSent = serializedPayload // Store the last command sent
        
        
        guard let data = serializedPayload.data(using: .utf8) else {
            print("Failed to convert payload to data.")
            return
        }
        
        // Assuming you've discovered services and characteristics previously
        // Let's find the specific characteristic you want to write to
      
        
        // Search for the target service
        if let targetService = peripheral.services?.first(where: { $0.uuid == targetServiceUUID }) {
            // Search for the target characteristic within the service
            if let targetCharacteristic = targetService.characteristics?.first(where: { $0.uuid == targetCharacteristicUUID }) {
                // Write the warm command to the characteristic
                bluetoothManager.writeValue(toCharacteristic: targetCharacteristic, onPeripheral: peripheral, data: data)
            } else {
                print("Target characteristic not found.")
            }
        } else {
            print("Target service not found.")
        }
    }
    
    
    
    func sendWarmCommand() {
        let warmCommand = "WARM\n" // Command string to trigger warm colors effect
        guard let data = warmCommand.data(using: .utf8) else { return }
        
        // Assuming you've discovered services and characteristics previously
        // Let's find the specific characteristic you want to write to
        let targetServiceUUID = CBUUID(string: "FFE0") // UUID for the service
        let targetCharacteristicUUID = CBUUID(string: "FFE1") // UUID for the writable characteristic
        
        // Search for the target service
        if let targetService = peripheral.services?.first(where: { $0.uuid == targetServiceUUID }) {
            // Search for the target characteristic within the service
            if let targetCharacteristic = targetService.characteristics?.first(where: { $0.uuid == targetCharacteristicUUID }) {
                // Write the warm command to the characteristic
                print("warm data \(data)")

                bluetoothManager.writeValue(toCharacteristic: targetCharacteristic, onPeripheral: peripheral, data: data)
            } else {
                print("Target characteristic not found.")
            }
        } else {
            print("Target service not found.")
        }
    }

}
