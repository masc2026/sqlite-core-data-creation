//
//  IMAGEKEYWORD+CoreDataProperties.swift

import Foundation
import CoreData


extension IMAGEKEYWORD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<IMAGEKEYWORD> {
        return NSFetchRequest<IMAGEKEYWORD>(entityName: "IMAGEKEYWORD")
    }

    @NSManaged public var key: String?
    @NSManaged public var status: NSNumber?
    @NSManaged public var type: NSNumber?
    @NSManaged public var value: String?
    @NSManaged public var image: IMAGE?

}

extension IMAGEKEYWORD : Identifiable {

}
