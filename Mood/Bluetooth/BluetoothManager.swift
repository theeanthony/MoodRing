import Foundation
import CoreBluetooth

class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    var discoveredPeripherals: [CBPeripheral] = []
    var connectingPeripherals: [UUID: CBPeripheral] = [:]
    var connectedPeripherals: [UUID: CBPeripheral] = [:]
    var characteristicsByPeripheral: [UUID: [CBUUID: CBCharacteristic]] = [:]

    var onPeripheralDiscovered: (([CBPeripheral]) -> Void)?
    var onPeripheralConnected: ((CBPeripheral) -> Void)?
    var onServicesDiscovered: ((CBPeripheral, Error?) -> Void)?
    var onPeripheralDisconnected: ((CBPeripheral) -> Void)?
    var onResendRequested: (() -> Void)?
    var heartRate: ((String) -> Void)?
    var determineHeartState: ((HeartCondition) -> Void)?

    private let persistenceController = PersistenceController.shared


    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Filter out peripherals without a name
        guard let name = peripheral.name, !name.isEmpty else {
            return
        }
        
        // Add the peripheral if it's new
        if !discoveredPeripherals.contains(where: { $0.identifier == peripheral.identifier }) {
            discoveredPeripherals.append(peripheral)
            onPeripheralDiscovered?(discoveredPeripherals)
            
            if let savedDevice = persistenceController.fetchBluetoothDevice(byId: peripheral.identifier){
                connectToPeripheral(peripheral)
            }
        }
    }


    func connectToPeripheral(_ peripheral: CBPeripheral) {
        connectingPeripherals[peripheral.identifier] = peripheral
        centralManager.connect(peripheral, options: nil)
        print("connected to peripheral")
        
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            reconnectToSavedDevices { disconnectedSavedDevices in
                
            }
//            reconnectToSavedDevices()
        } else {
            print("Bluetooth is not available: \(central.state.rawValue)")
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "Unknown Device")")
        peripheral.delegate = self
        peripheral.discoverServices(nil)

        connectedPeripherals[peripheral.identifier] = peripheral
        connectingPeripherals.removeValue(forKey: peripheral.identifier)

        saveConnectedDeviceIdentifier(peripheral.identifier)
        onPeripheralConnected?(peripheral) // Notify ViewModel about the connection
    }


    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from \(peripheral.name ?? "Unknown Device")")
        
        // Invoke the disconnection callback
        onPeripheralDisconnected?(peripheral)
        
        // Clean up after forgetting a device
        forgetDeviceIdentifier(peripheral.identifier)
        connectedPeripherals.removeValue(forKey: peripheral.identifier)
        connectingPeripherals.removeValue(forKey: peripheral.identifier)
    }


    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral.name ?? "Unknown Device") with error: \(error?.localizedDescription ?? "N/A")")
        connectingPeripherals.removeValue(forKey: peripheral.identifier)
    }

    // Peripheral delegate methods as before...

    func saveConnectedDeviceIdentifier(_ identifier: UUID) {
        var savedIdentifiers = getSavedDeviceIdentifiers()
        if !savedIdentifiers.contains(identifier) {
            savedIdentifiers.append(identifier)
            UserDefaults.standard.set(savedIdentifiers.map { $0.uuidString }, forKey: "savedDeviceIdentifiers")
        }
    }

    func forgetDeviceIdentifier(_ identifier: UUID) {
        var identifiers = getSavedDeviceIdentifiers()
        if let index = identifiers.firstIndex(of: identifier) {
            identifiers.remove(at: index)
            UserDefaults.standard.set(identifiers.map { $0.uuidString }, forKey: "savedDeviceIdentifiers")
        }
        
        // Clean up after forgetting a device
        connectedPeripherals.removeValue(forKey: identifier)
        connectingPeripherals.removeValue(forKey: identifier)
    }

    func getSavedDeviceIdentifiers() -> [UUID] {
        guard let uuidStrings = UserDefaults.standard.array(forKey: "savedDeviceIdentifiers") as? [String] else {
            return []
        }
        return uuidStrings.compactMap(UUID.init)
    }

    func reconnectToSavedDevices(completion: @escaping ([BluetoothDeviceModel]) -> Void) {
        guard let savedDevices = persistenceController.fetchAllBluetoothDevices(), !savedDevices.isEmpty else {
            print("No saved devices to reconnect.")
            completion([]) // No devices to reconnect to
            return
        }

        let savedIdentifiers = savedDevices.compactMap { $0.id }
        let knownPeripherals = centralManager.retrievePeripherals(withIdentifiers: savedIdentifiers)
        let knownIdentifiers = knownPeripherals.map { $0.identifier }

        for peripheral in knownPeripherals {
            print("Attempting to reconnect to \(peripheral)")
            print("Name is \(peripheral.name ?? "Unknown")")
            connectToPeripheral(peripheral)
        }

        // Calculate the difference between savedIdentifiers and knownIdentifiers
        let nonKnownIdentifiers = savedIdentifiers.filter { !knownIdentifiers.contains($0) }
        var nonKnownDevices : [BluetoothDeviceModel] = []
        for nonKnownIdentifier in nonKnownIdentifiers {
            if let entity = persistenceController.fetchBluetoothDevice(byId: nonKnownIdentifier){
                let deviceModel = BluetoothDeviceModel(entity: entity, customName: entity.name ?? "Unknown Device", isConnected: false, peripheral: nil)
                print("Cannot find this device \(entity.name)")
                nonKnownDevices.append(deviceModel)
            }
          

        }
        completion(nonKnownDevices) // Return non-known peripherals' UUIDs
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else {
            print("No services found.")
            return
        }
        
        for service in services {
            print("Discovered service: \(service)")
            // Optionally discover characteristics here
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else {
            print("No characteristics found for service \(service.uuid)")
            return
        }
        
        for characteristic in characteristics {
              print("Discovered characteristic: \(characteristic)")
              let peripheralCharacteristics = characteristicsByPeripheral[peripheral.identifier] ?? [:]
              characteristicsByPeripheral[peripheral.identifier] = peripheralCharacteristics.merging([characteristic.uuid: characteristic]) { (_, new) in new }

              // Check if this is the characteristic we want to subscribe to notifications for
              if characteristic.uuid == CBUUID(string: "FFE1") { // Replace "FFE1" with your characteristic's UUID
                  print("Subscribing to notifications for characteristic: \(characteristic.uuid)")
                  peripheral.setNotifyValue(true, for: characteristic)
              }
          }
    }
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            // Handle the error
            print("Error writing to characteristic \(characteristic.uuid): \(error.localizedDescription)")
            return
        }

        // Successfully wrote value to characteristic
        print("Successfully wrote value to characteristic \(characteristic.uuid)")
    }

    func writeValue(_ data: Data, forPeripheral peripheral: CBPeripheral) {
        let characteristicUUID = CBUUID(string: "FFE1") // The UUID of the characteristic you want to write to
        
        guard let characteristics = characteristicsByPeripheral[peripheral.identifier],
              let characteristic = characteristics[characteristicUUID] else {
            print("Characteristic \(characteristicUUID.uuidString) not found for peripheral \(peripheral.identifier.uuidString).")
            return
        }
        
        peripheral.writeValue(data, for: characteristic, type: .withResponse) // Choose .withResponse or .withoutResponse based on your characteristic's properties
    }
    func writeValue(toCharacteristic characteristic: CBCharacteristic, onPeripheral peripheral: CBPeripheral, data: Data) {
        let properties = characteristic.properties
        
        if properties.contains(.write) {
            // Characteristic supports writing with response
            peripheral.writeValue(data, for: characteristic, type: .withResponse)
        } else if properties.contains(.writeWithoutResponse) {
            // Characteristic supports writing without response
            peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
        } else {
            print("Characteristic does not support writing.")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else { print("returning from resend")
            return }
        let message = String(data: data, encoding: .utf8) ?? ""
        // Check if the message is a resend request
        if message.contains("H") {
            // Assuming the message is in the format "HeartRate:75"
            // Extract the heart rate value from the message
//            let components = message.components(separatedBy: ":")
//            if components.count > 1, let heartRateValue = Int(components[1]) {
                // Call the heartRate closure with the extracted value
//            print("Message : \(message)")
                heartRate?(message)
            determineHeartState?(.PulseDetected)

//            }
        } else if message == "NO PULSE" {
            determineHeartState?(.NoPulseDetected)
            
        }else if message == "LOCATING" {
            determineHeartState?(.Searching)

        }else if message == "RESEND_LAST_COMMAND" {
            // Handle resend request
            
            onResendRequested?()
        } else if message.isEmpty{
            onResendRequested?()

            // Handle other messages or data processing
        }else{
            print("Other message received: \(message)")

        }
        
    }






}
