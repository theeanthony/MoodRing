import SwiftUI
import CoreBluetooth

struct SearchDeviceView: View {
    @EnvironmentObject private var bluetoothViewModel: BluetoothConnectionViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
                Spacer()
            }
            .padding()
            
            List(bluetoothViewModel.discoveredDevices) { device in
                HStack {
                    Text(device.customName )
                    Spacer()
//                    Text("RSSI: \(bluetoothViewModel.rssiForPeripheral[peripheral.identifier] ?? 0)")
                }
                .onTapGesture {
                    if let peripheral = device.peripheral {
                        bluetoothViewModel.connectToPeripheral(peripheral)

                    }
                    dismiss()
                }
            }
        }
        .onAppear(perform: searchForPeripheral)
    }
    
    private func searchForPeripheral() {
        bluetoothViewModel.startScanning()
    }
}
