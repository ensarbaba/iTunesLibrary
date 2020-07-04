//
//  UserHistory+CoreDataProperties.swift
//  iTunesLibrary
//
//  Created by Ensar Baba on 5.07.2020.
//  Copyright © 2020 Ensar Baba. All rights reserved.
//
//

import Foundation
import CoreData


extension UserHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserHistory> {
        return NSFetchRequest<UserHistory>(entityName: "UserHistory")
    }

    @NSManaged public var filteredOut: Bool
    @NSManaged public var id: Int32
    @NSManaged public var seen: Bool

}
