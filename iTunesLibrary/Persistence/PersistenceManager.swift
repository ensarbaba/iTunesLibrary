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
    var appDelegate: AppDelegate?
    private init() {}
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "UserHistory")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
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
        request.predicate = NSPredicate(format: "id == %d", id)
        
        let users = try self.context.fetch(request)
        return users
    }
    func fetchSeen() throws -> [Int32] {
        let request = NSFetchRequest<UserHistory>(entityName: "UserHistory")
        request.predicate = NSPredicate(format: "seen == %@", NSNumber(value: 1))
        let users = try self.context.fetch(request)
        let seenItems = users.compactMap({$0.id})
        return seenItems
    }
    func fetchFiltered() throws -> [Int32] {
        let request = NSFetchRequest<UserHistory>(entityName: "UserHistory")
        request.predicate = NSPredicate(format: "filteredOut == %@", NSNumber(value: 1))
        
        let users = try self.context.fetch(request)
        let filteredOutItems = users.compactMap({$0.id})
        return filteredOutItems
    }
    //    func filterItem(itemID: Int) throws {
    //        let items = try fetchItems(withID: itemID)
    //        for item in items {
    //            item.filteredOut = true
    //        }
    //        try self.context.save()
    //    }
    
}
