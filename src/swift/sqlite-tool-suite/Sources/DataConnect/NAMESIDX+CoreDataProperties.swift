//
//  NAMESIDX+CoreDataProperties.swift

import Foundation
import CoreData


extension NAMESIDX {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NAMESIDX> {
        return NSFetchRequest<NAMESIDX>(entityName: "NAMESIDX")
    }

    @NSManaged public var pattern: String?
    @NSManaged public var specnr: String?
    @NSManaged public var type: Int16

}

extension NAMESIDX : Identifiable {

}
