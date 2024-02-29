//
//  BluetoothDeviceModel.swift
//  Mood
//
//  Created by Anthony Contreras on 2/20/24.
//

import Foundation
import CoreBluetooth


struct BluetoothDeviceModel: Identifiable {
    let entity: BluetoothDeviceEntity?
    let customName: String
    let isConnected: Bool
    let peripheral: CBPeripheral?
    
    var id: UUID {
        entity?.id ?? UUID()
    }
}

