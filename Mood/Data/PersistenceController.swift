//
//  PersistenceController.swift
//  Mood
//
//  Created by Anthony Contreras on 2/7/24.
//

import Foundation
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ColorCollectionData") // Replace "YourModelName" with the name of your Core Data Model
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Real apps should handle this error appropriately.
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }

    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
   

    func fetchColorCollections(forDeviceId deviceId: UUID) -> [ColorCollection] {
        let request: NSFetchRequest<ColorCollection> = ColorCollection.fetchRequest()
        request.predicate = NSPredicate(format: "device.id == %@", deviceId as CVarArg)
        
        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("Error fetching color collections for device: \(error)")
            return []
        }
    }



    func createAndSaveNewColorCollection(forDeviceId deviceId: UUID,collectionID:UUID, with colors: [SavedColorModel], timeOption: Int) {
        let context = container.viewContext
        
        // Attempt to fetch the associated device
        let deviceFetchRequest: NSFetchRequest<BluetoothDeviceEntity> = BluetoothDeviceEntity.fetchRequest()
        deviceFetchRequest.predicate = NSPredicate(format: "id == %@", deviceId as CVarArg)
        
        do {
            let devices = try context.fetch(deviceFetchRequest)
            guard let device = devices.first else {
                print("Bluetooth device not found")
                return
            }
            
            let colorCollection = ColorCollection(context: context)
            colorCollection.id = collectionID

            colorCollection.device = device // Assume 'device' is the relationship property name
            colorCollection.rateOfChange = Int32(timeOption)
            for colorModel in colors {
                let newSavedColor = SavedColor(context: context)
                newSavedColor.id = UUID()
                newSavedColor.red = colorModel.red // Ensure type conversion if necessary
                newSavedColor.green = colorModel.green
                newSavedColor.blue = colorModel.blue
                newSavedColor.alpha = colorModel.alpha
                colorCollection.addToSavedColors(newSavedColor)
            }
            saveContext()
        } catch {
            print("Failed to fetch Bluetooth device or save color collection: \(error)")
        }
    }

    
    func updateColorCollection(collectionID: UUID, with newColors: [SavedColorModel], rateOfChange : Int) {
        let fetchRequest: NSFetchRequest<ColorCollection> = ColorCollection.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", collectionID as CVarArg)
        
        do {
            let results = try container.viewContext.fetch(fetchRequest)
            if let collectionToUpdate = results.first {
                // Clear existing colors if you want to replace them
                let existingColors = collectionToUpdate.savedColors as? Set<SavedColor> ?? []
                existingColors.forEach { container.viewContext.delete($0) }
                collectionToUpdate.rateOfChange = Int32(rateOfChange)
                // Add new colors
                for colorModel in newColors {
                    let newColor = SavedColor(context: container.viewContext)
                    newColor.id = UUID() // Ensure a unique identifier
                    newColor.red = colorModel.red // Make sure to convert these as per your data model
                    newColor.green = colorModel.green
                    newColor.blue = colorModel.blue
                    newColor.alpha = colorModel.alpha
                    collectionToUpdate.addToSavedColors(newColor)
                }
                
                try container.viewContext.save()
            }
        } catch {
            print("Failed to update color collection: \(error)")
        }
    }
    func deleteCollection(collectionID: UUID, completion: @escaping (Bool) -> Void) {
        let fetchRequest: NSFetchRequest<ColorCollection> = ColorCollection.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", collectionID as CVarArg)

        do {
            let results = try container.viewContext.fetch(fetchRequest)
            if let collectionToDelete = results.first {
                container.viewContext.delete(collectionToDelete)

                try container.viewContext.save()
                completion(true)
            } else {
                print("No collection found with ID: \(collectionID)")
                completion(false)
            }
        } catch {
            print("Failed to delete color collection: \(error)")
            completion(false)
        }
    }
    func saveNewBluetoothDevice(id: UUID, name: String) {
        let context = container.viewContext
        
        // Create a new BluetoothDeviceEntity
        let newDevice = BluetoothDeviceEntity(context: context)
        newDevice.id = id
        newDevice.name = name
        
        // Save the context
        saveContext()
    }
    func fetchBluetoothDevice(byId id: UUID) -> BluetoothDeviceEntity? {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<BluetoothDeviceEntity> = BluetoothDeviceEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first // Return the first matching device, if any
        } catch {
            print("Failed to fetch Bluetooth device: \(error.localizedDescription)")
            return nil
        }
    }
    func fetchAllBluetoothDevices() -> [BluetoothDeviceEntity]? {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<BluetoothDeviceEntity> = BluetoothDeviceEntity.fetchRequest()

        do {
            let results = try context.fetch(fetchRequest)
            return results // Return all fetched devices
        } catch {
            print("Failed to fetch all Bluetooth devices: \(error.localizedDescription)")
            return nil
        }
    }


}
