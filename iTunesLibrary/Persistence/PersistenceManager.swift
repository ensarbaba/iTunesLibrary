//
//  PersistenceManager.swift
//  iTunesLibrary
//
//  Created by Ensar Baba on 5.07.2020.
//  Copyright © 2020 Ensar Baba. All rights reserved.
//

import UIKit
import CoreData
 
class PersistenceManager {
    static let shared = PersistenceManager()
    private init() {}
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    var context: NSManagedObjectContext {
        return appDelegate.persistentContainer.viewContext
    }

    func insertItemWith(id: Int, seen: Bool, filtered: Bool) throws {
        let item = UserHistory(context: self.context)
        item.filteredOut = filtered
        item.id = Int32(id)
        item.seen = seen
     
        self.context.insert(item)
        try self.context.save()
    }
    func fetchItems() throws -> [UserHistory] {
        let users = try self.context.fetch(UserHistory.fetchRequest() as NSFetchRequest<UserHistory>)
        return users
    }

    func fetchItems(withID id: Int) throws -> [UserHistory] {
        let request = NSFetchRequest<UserHistory>(entityName: "UserHistory")
        request.predicate = NSPredicate(format: "id == %@", id)
        
        let users = try self.context.fetch(request)
        return users
    }
    func filterItem(itemID: Int) throws {
        let items = try fetchItems(withID: itemID)
        for item in items {
            item.filteredOut = true
        }
        try self.context.save()
    }
}
