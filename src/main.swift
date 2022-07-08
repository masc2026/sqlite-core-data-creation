//
//  main.swift
//  TaxaDBTool
//
//  Created by Markus Schmid on 28.06.22.
//

import Foundation
import Cocoa

let configuration = CommandLine.arguments[1]
let momdURL = URL(fileURLWithPath: CommandLine.arguments[2], isDirectory: true)
let sqliteFileURL  = URL(fileURLWithPath: CommandLine.arguments[3], isDirectory: false)
let momTaxa = NSManagedObjectModel.init(contentsOf: momdURL)

let persistentContainerConfig: NSPersistentContainer? = {
    let persistentStoreCoordinator = NSPersistentStoreCoordinator.init(managedObjectModel: momTaxa!)
    
    let modelVersion = momTaxa!.versionIdentifiers.popFirst()

    print("Create Core Data SQLite database \(sqliteFileURL.absoluteString)")

    print("Use Core Data SQLite database model \(momdURL.absoluteString)")
    
    print("Model version: \(modelVersion!)")
        
    let options : [AnyHashable : Any]? = [NSReadOnlyPersistentStoreOption : false,
        NSIgnorePersistentStoreVersioningOption : false,
        NSMigratePersistentStoresAutomaticallyOption : true,
        NSInferMappingModelAutomaticallyOption : true,
        NSSQLitePragmasOption : ["journal_mode" : "OFF", "cache_size" : "50"]]
    
    let _ : NSPersistentStore? = {
        do {
            let persistentStore = try persistentStoreCoordinator.addPersistentStore(type:NSPersistentStore.StoreType.sqlite, configuration:configuration, at: sqliteFileURL, options: options)
            return persistentStore
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }()
    
    let sourceMetaData : [String : Any]? = {
        do {
            let sourceMetaData = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: sqliteFileURL, options: nil)
            return sourceMetaData
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }()
           
    let isCompatible : Bool? = {
        return momTaxa?.isConfiguration(withName: configuration, compatibleWithStoreMetadata: sourceMetaData!)
    }()
           
    let container = NSPersistentContainer(name: "Taxa", managedObjectModel: momTaxa!)
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
        if let error = error {
            fatalError("Unresolved error \(error)")
        }
    })
    
    if (isCompatible == true) {
        print("Core Data SQLite database file is compatible")
    }
    else {
        print("Core Data SQLite database file is not compatible")
    }
    
    return container
}()

if persistentContainerConfig != nil {
    print("Core Data SQLite database file created \(sqliteFileURL.absoluteString)")
}
else {
    print("Error")
}
