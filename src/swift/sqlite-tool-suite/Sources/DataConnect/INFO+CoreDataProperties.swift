//
//  INFO+CoreDataProperties.swift

import Foundation
import CoreData


extension INFO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<INFO> {
        return NSFetchRequest<INFO>(entityName: "INFO")
    }

    @NSManaged public var bindata: Data?
    @NSManaged public var ctype: Int16
    @NSManaged public var data: String?
    @NSManaged public var datatype: NSNumber?
    @NSManaged public var date: Date?
    @NSManaged public var md: String?
    @NSManaged public var name: String?
    @NSManaged public var notes: String?
    @NSManaged public var section: String?
    @NSManaged public var sectionnr: NSNumber?
    @NSManaged public var type: NSNumber?
    @NSManaged public var author: PERSON?
    @NSManaged public var spec: SPECDETAIL?

}

extension INFO : Identifiable {

}
