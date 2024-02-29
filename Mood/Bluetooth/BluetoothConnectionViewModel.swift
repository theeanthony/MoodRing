import Foundation
import CoreBluetooth

import CoreData

class BluetoothConnectionViewModel: ObservableObject {
//    @Published var discoveredPeripherals: [CBPeripheral] = []
//    @Published var connectedPeripherals: [CBPeripheral] = [] // Track connected devices
//    @Published var disconnectedPeripherals: [CBPeripheral] = [] // Track connected devices

    @Published var discoveredDevices: [BluetoothDeviceModel] = []
     @Published var connectedDevices: [BluetoothDeviceModel] = [] // Track connected devices
     @Published var disconnectedDevices: [BluetoothDeviceModel] = [] // Track disconnected devices

    
    @Published var savedDevices : [BluetoothDeviceEntity] = []
    @Published var rssiForPeripheral: [UUID: NSNumber] = [:]
    private var bluetoothManager: BluetoothManager?
    private let persistenceController = PersistenceController.shared

    
    init() {
        setupBluetoothManager()
        reconnectToSavedDevices()

    }
    
    func returnBluetoothManager() -> BluetoothManager {
        return self.bluetoothManager!
    }
    func setupBluetoothManager() {
        bluetoothManager = BluetoothManager()
        bluetoothManager?.onPeripheralDiscovered = { [weak self] peripherals in
            DispatchQueue.main.async {
                let discoveredDevices: [BluetoothDeviceModel] = peripherals.compactMap { peripheral in
                    // Attempt to fetch existing device entity
                    let entity = self?.persistenceController.fetchBluetoothDevice(byId: peripheral.identifier)
                    // Create a BluetoothDeviceModel regardless of whether the entity exists
                    return BluetoothDeviceModel(entity: entity, customName: peripheral.name ?? "Unknown Device", isConnected: false, peripheral: peripheral)
                }
                self?.discoveredDevices = discoveredDevices
            }
        }
        bluetoothManager?.onPeripheralConnected = { [weak self] peripheral in
            DispatchQueue.main.async {
                self?.updateConnectedPeripherals(peripheral, isConnected: true)
            }
        }
        bluetoothManager?.onPeripheralDisconnected = { [weak self] peripheral in
            DispatchQueue.main.async {
                self?.updateConnectedPeripherals(peripheral, isConnected: false)
            }
        }
    }

    
    func startScanning() {
        bluetoothManager?.centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func connectToPeripheral(_ peripheral: CBPeripheral) {
        // Connect to the peripheral
        bluetoothManager?.connectToPeripheral(peripheral)
        // Check if this device is already saved, if not save it
        savePeripheralIfNeeded(peripheral)
        // Update UI or internal state as needed
        updateConnectedPeripherals(peripheral, isConnected: true)
    }

    func savePeripheralIfNeeded(_ peripheral: CBPeripheral) {
        // Attempt to fetch the existing device
        if let _ = persistenceController.fetchBluetoothDevice(byId: peripheral.identifier) {
            // Device already exists, no need to save
            print("Device already saved")
        } else {
            // Device not found, save it
            let deviceName = peripheral.name ?? "Unknown Device"
            persistenceController.saveNewBluetoothDevice(id: peripheral.identifier, name: deviceName)
            print("New device saved")
        }
    }


    func reconnectToSavedDevices() {
        bluetoothManager?.reconnectToSavedDevices(completion: { nonKnownIdentifiers in
            DispatchQueue.main.async {
                self.disconnectedDevices.append(contentsOf: nonKnownIdentifiers)

            }
        })
    }

    
//
//    func updateConnectedPeripherals(_ peripheral: CBPeripheral, isConnected: Bool) {
//        DispatchQueue.main.async {
//            if isConnected {
//                if !self.connectedPeripherals.contains(peripheral) {
//                    self.connectedPeripherals.append(peripheral)
//                }
//            } else {
//                self.connectedPeripherals.removeAll { $0.identifier == peripheral.identifier }
//            }
//        }
//    }
    func updateConnectedPeripherals(_ peripheral: CBPeripheral, isConnected: Bool) {
        DispatchQueue.main.async {
            // Fetch or create a BluetoothDeviceModel for the peripheral
            let entity = self.persistenceController.fetchBluetoothDevice(byId: peripheral.identifier)
            let deviceModel = BluetoothDeviceModel(entity: entity, customName: peripheral.name ?? "Unknown Device", isConnected: isConnected, peripheral: peripheral)

            if isConnected {
                if !self.connectedDevices.contains(where: { $0.entity?.id == deviceModel.entity?.id }) {
                    self.connectedDevices.append(deviceModel)
                }
                self.disconnectedDevices.removeAll { $0.entity?.id == deviceModel.entity?.id }
            } else {
                print("Disconnecting \(deviceModel.entity?.name ?? "Unknown Device")")
                if !self.disconnectedDevices.contains(where: { $0.entity?.id == deviceModel.entity?.id }) {
                    self.disconnectedDevices.append(deviceModel)
                }
                self.connectedDevices.removeAll { $0.entity?.id == deviceModel.entity?.id }
            }

        }
    }

    
//    func loadColorCollection(for device: BluetoothDevice) {
//        // Retrieve the color collection for the connected device
//        let colorCollection = PersistenceController.shared.loadColorCollection(forDeviceId: device.id)
//        // Apply the color collection settings as needed
//    }



}
