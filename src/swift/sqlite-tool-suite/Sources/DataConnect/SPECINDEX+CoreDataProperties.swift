//
//  SPECINDEX+CoreDataProperties.swift

import Foundation
import CoreData


extension SPECINDEX {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SPECINDEX> {
        return NSFetchRequest<SPECINDEX>(entityName: "SPECINDEX")
    }

    @NSManaged public var bbnr: NSNumber?
    @NSManaged public var column: NSNumber?
    @NSManaged public var len: NSNumber?
    @NSManaged public var nr: NSNumber?
    @NSManaged public var pattern: String?
    @NSManaged public var pos: NSNumber?
    @NSManaged public var specnr: NSNumber?

}

extension SPECINDEX : Identifiable {

}
