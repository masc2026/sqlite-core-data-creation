//
//  BOOKMARK+CoreDataProperties.swift

import Foundation
import CoreData


extension BOOKMARK {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BOOKMARK> {
        return NSFetchRequest<BOOKMARK>(entityName: "BOOKMARK")
    }

    @NSManaged public var abbrev: String?
    @NSManaged public var adduserdata: Bool
    @NSManaged public var bbnr: NSNumber?
    @NSManaged public var childs: String?
    @NSManaged public var level: NSNumber?
    @NSManaged public var objectid: String?
    @NSManaged public var order: NSNumber?
    @NSManaged public var parents: String?
    @NSManaged public var rankobjectid: String?
    @NSManaged public var selected: NSNumber?
    @NSManaged public var setnr: NSNumber?
    @NSManaged public var specnr: NSNumber?
    @NSManaged public var status: NSNumber?
    @NSManaged public var total: NSNumber?

}

extension BOOKMARK : Identifiable {

}
