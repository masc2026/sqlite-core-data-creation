//
//  SEARCH+CoreDataProperties.swift

import Foundation
import CoreData


extension SEARCH {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SEARCH> {
        return NSFetchRequest<SEARCH>(entityName: "SEARCH")
    }

    @NSManaged public var bbnr: NSNumber?
    @NSManaged public var match: String?
    @NSManaged public var objectid: String?
    @NSManaged public var pattern: String?
    @NSManaged public var spec: NSObject?
    @NSManaged public var specnr: NSNumber?
    @NSManaged public var timestamp: Date?

}

extension SEARCH : Identifiable {

}
