//
//  OWNER+CoreDataProperties.swift

import Foundation
import CoreData


extension OWNER {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OWNER> {
        return NSFetchRequest<OWNER>(entityName: "OWNER")
    }

    @NSManaged public var changed: Date?
    @NSManaged public var md: String?
    @NSManaged public var person: PERSON?

}

extension OWNER : Identifiable {

}
