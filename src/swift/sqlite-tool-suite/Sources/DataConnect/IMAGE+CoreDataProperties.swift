//
//  IMAGE+CoreDataProperties.swift

import Foundation
import CoreData


extension IMAGE {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<IMAGE> {
        return NSFetchRequest<IMAGE>(entityName: "IMAGE")
    }

    @NSManaged public var ctype: Int16
    @NSManaged public var height: NSNumber?
    @NSManaged public var image: Data?
    @NSManaged public var imagelink: String?
    @NSManaged public var index: NSNumber?
    @NSManaged public var info: String?
    @NSManaged public var md: String?
    @NSManaged public var section: String?
    @NSManaged public var sectionnr: NSNumber?
    @NSManaged public var speckey: String?
    @NSManaged public var status: NSNumber?
    @NSManaged public var thumb: Data?
    @NSManaged public var title: String?
    @NSManaged public var type: NSNumber?
    @NSManaged public var width: NSNumber?
    @NSManaged public var author: PERSON?
    @NSManaged public var keywords: NSSet?
    @NSManaged public var observation: OBSERVATION?
    @NSManaged public var spec: SPECDETAIL?

}

// MARK: Generated accessors for keywords
extension IMAGE {

    @objc(addKeywordsObject:)
    @NSManaged public func addToKeywords(_ value: IMAGEKEYWORD)

    @objc(removeKeywordsObject:)
    @NSManaged public func removeFromKeywords(_ value: IMAGEKEYWORD)

    @objc(addKeywords:)
    @NSManaged public func addToKeywords(_ values: NSSet)

    @objc(removeKeywords:)
    @NSManaged public func removeFromKeywords(_ values: NSSet)

}

extension IMAGE : Identifiable {

}
