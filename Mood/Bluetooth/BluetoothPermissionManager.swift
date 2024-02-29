//
//  BluetoothPermissionManager.swift
//  Mood
//
//  Created by Anthony Contreras on 2/3/24.
//

import Foundation
import CoreBluetooth

enum BluetoothStatus {
    case off, unauthorized, unknown, resetting, unsupported, on, error
}


class BluetoothPermissionManager: NSObject, CBCentralManagerDelegate {
    var centralManager: CBCentralManager?
    var onStatusChanged: ((BluetoothStatus) -> Void)?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }
    
    func checkBluetoothPermission() {
        guard let centralManager = centralManager else { return }
        
        let status = convertStateToStatus(centralManager.state)
        onStatusChanged?(status)
    }
    
    private func convertStateToStatus(_ state: CBManagerState) -> BluetoothStatus {
        switch state {
        case .poweredOff: return .off
        case .unauthorized: return .unauthorized
        case .unknown: return .unknown
        case .resetting: return .resetting
        case .unsupported: return .unsupported
        case .poweredOn: return .on
        @unknown default: return .error
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        checkBluetoothPermission()
    }
}
