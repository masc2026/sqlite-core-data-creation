//
//  RANK+CoreDataProperties.swift

import Foundation
import CoreData


extension RANK {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RANK> {
        return NSFetchRequest<RANK>(entityName: "RANK")
    }

    @NSManaged public var abbrev: String?
    @NSManaged public var color: String?
    @NSManaged public var de_name: String?
    @NSManaged public var en_name: String?
    @NSManaged public var fr_name: String?
    @NSManaged public var icon: String?
    @NSManaged public var kingdom: NSNumber?
    @NSManaged public var level: NSNumber?
    @NSManaged public var sci_name: String?
    @NSManaged public var status: NSNumber?

}

extension RANK : Identifiable {

}
