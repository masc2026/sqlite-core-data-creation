//
//  SqliteUtil.swift
//
//  Created by Markus Schmid on 17.07.22.
//

import Foundation
import Cocoa
import DataController

public final class SqliteUtil {
    private let arguments: [String]

    public init(arguments: [String] = CommandLine.arguments) { 
        self.arguments = arguments
    }

    public func printCountSpecies(source: URL, model: URL) throws -> Void {
        let dataController = DataController(source:source,model:model)
        print(dataController.countSpec())
    }

    public func printSpeciesInfo(source: URL, name: String, model: URL) throws -> Void {
        let dataController = DataController(source:source,model:model)
        let (foundname, nr)=dataController.specNr(name:name)
        if(nr == -1) {
            print("Taxa \(name) not found")
        }
        else {
            print("Taxa <\(foundname)> found with nr = \(nr)")
        }
    }

    public func new(config: String, momd: URL, target: URL) throws -> Void {
        let configuration = config
        let sqliteFileURL  = target
        let momTaxa = NSManagedObjectModel.init(contentsOf: momd)

        let persistentContainerConfig: NSPersistentContainer? = {
            let persistentStoreCoordinator = NSPersistentStoreCoordinator.init(managedObjectModel: momTaxa!)
            
            let modelVersion = momTaxa!.versionIdentifiers.popFirst()

            print("Create Core Data SQLite database \(sqliteFileURL.absoluteString)")

            print("Use Core Data SQLite database model \(momd.absoluteString)")
            
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
    }

    public func run2() throws {
        print("Hello world 2")
    }
}