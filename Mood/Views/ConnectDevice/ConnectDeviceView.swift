import SwiftUI

struct ConnectDeviceView: View {
    @Environment(\.colorScheme) var color
    @EnvironmentObject var viewModel: BluetoothConnectionViewModel
    

    @State private var showSearchDeviceView = false
    @State private var showDeletionActionSheet = false
    @State private var selectedCollectionIDForDeletion: UUID?

    var body: some View {
        NavigationStack {
            
            VStack{
                HeaderView(headerViewModel: HeaderViewModel(bluetoothManager: viewModel.returnBluetoothManager()))
                ScrollView{
                    HStack{
                        Spacer()
                        VStack {
                            
                            Spacer()
                            // Existing content
                            ForEach(viewModel.connectedDevices) { bluetoothDevice in
                                if let peripheral = bluetoothDevice.peripheral {
                                    DeviceLabelView(
                                        bluetoothDevice: bluetoothDevice,
                                        deviceViewModel: DeviceViewModel(
                                            peripheral: peripheral,
                                            bluetoothManager: viewModel.returnBluetoothManager()
                                        )
                                    )
                                }
                            }
                            
                            ForEach(viewModel.disconnectedDevices) { bluetoothDevice in
                                DeviceDisconnectedLabelView(
                                    bluetoothDevice: bluetoothDevice
                                    
                                )
                            }
                            
                            
                            Button("Add Apparel") {
                                self.showSearchDeviceView = true
                            }
                            .foregroundStyle(color == .light ? .black : .white )
                            
                            .padding()
                            
                            
                            Spacer()
                        }
                        Spacer()
                    }
                }
                .scrollIndicators(.hidden)
                .padding(.top)
            }
            
            .background(BackgroundView())
            
        }
        

        
        .fullScreenCover(isPresented: $showSearchDeviceView, content: {
            SearchDeviceView()
        })
    }
}

// Assume ColorPreviewView is a view that shows a preview of the colors in a collection
struct ColorPreviewView: View {
    var colors: [SavedColor]

    var body: some View {
        // Implementation depends on how you want to show the color(s)
        Circle() // Placeholder
    }
}
