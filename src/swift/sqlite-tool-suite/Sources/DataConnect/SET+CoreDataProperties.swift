//
//  SET+CoreDataProperties.swift

import Foundation
import CoreData


extension SET {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SET> {
        return NSFetchRequest<SET>(entityName: "SET")
    }

    @NSManaged public var changed: Date?
    @NSManaged public var comment: String?
    @NSManaged public var created: Date?
    @NSManaged public var name: String?
    @NSManaged public var nr: NSNumber?
    @NSManaged public var type: NSNumber?
    @NSManaged public var author: PERSON?

}

extension SET : Identifiable {

}
