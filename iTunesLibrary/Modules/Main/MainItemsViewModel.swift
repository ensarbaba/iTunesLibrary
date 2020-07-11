//
//  MainItemsViewModel.swift
//  iTunesLibrary
//
//  Created by Ensar Baba on 4.07.2020.
//  Copyright © 2020 Ensar Baba. All rights reserved.
//

import Foundation

struct ItemListCellViewModel {
    let name: String
    let id: Int
    let imageUrl: String
    let kind: String
    var seen: Bool
}
enum ItemKind: String {
    case song = "song"
    case movie = "feature-movie"
    case podcast = "podcast"
}
class MainItemsViewModel {
    
    private var resultItems = [ItemListCellViewModel]()
    private var filterRules = ["song", "feature-movie", "podcast"]
    private var filteredItems = [Int32]()
    private var seenItems = [Int32]()
   
    var apiService: APIClientProtocol?

    init(apiService: APIClientProtocol = APIClient()) {
           self.apiService = apiService
    }
    
    private var cellViewModels: [ItemListCellViewModel] = [ItemListCellViewModel]() {
        didSet {
            self.reloadTableViewClosure?()
        }
    }
    
    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatus?(isLoading)
        }
    }
    
    var alertMessage: String? {
        didSet {
            self.showAlertClosure?()
        }
    }
    
    var numberOfItems: Int {
        return cellViewModels.count
    }

    var selectedItem: Results?
    var selectedMediaType: String = "all"
    
    var reloadTableViewClosure: (()->())?
    var showAlertClosure: (()->())?
    var updateLoadingStatus: ((_ show: Bool)->())?
    
    func fetchItemsWith(term: String, mediaType: String) {
        self.isLoading = true
        guard let api = self.apiService else {self.alertMessage = "API is nil"; return}
        api.search(term: term, mediaType: mediaType) { [weak self] (success, errorMessage, responseData) in
            self?.isLoading = false
            if let message = errorMessage {
                self?.alertMessage = message
            } else {
                self?.processFetchedItem(items: responseData?.results ?? [Results]())
            }
        }
    }
    
    func getCellViewModel( at indexPath: IndexPath ) -> ItemListCellViewModel {
        return cellViewModels[indexPath.row]
    }
    func removeCellViewModel( at indexPath: IndexPath ) {
        cellViewModels.remove(at: indexPath.row)
    }
    func createCellViewModel(item: Results ) -> ItemListCellViewModel {
        return ItemListCellViewModel(name: item.trackName ?? "", id: item.trackId ?? 0, imageUrl: item.artworkUrl100 ?? "", kind: item.kind ?? "", seen: seenItems.contains(Int32(item.trackId ?? 0)))
    }
    
    private func processFetchedItem( items: [Results] ) {
        
        resultItems = [ItemListCellViewModel]()
        do {
            filteredItems = try PersistenceManager.shared.fetchFiltered()
            seenItems = try PersistenceManager.shared.fetchSeen()
        } catch {
            print("error while fetching")
        }
        //Only Song, Movie, Podcast Kinds And
        //Not Filtered Items Should Be Fetched
        for item in items where filterRules.contains(item.kind ?? "") && !filteredItems.contains(Int32(item.trackId ?? 0)) {
            resultItems.append(createCellViewModel(item: item) )
        }
      
        self.cellViewModels = resultItems
    }
    func updateSeenItems() {
        do {
            seenItems = try PersistenceManager.shared.fetchSeen()
        } catch {
            print("error while fetching")
        }
        for index in 0 ..< resultItems.count where seenItems.contains(Int32(resultItems[index].id)) {
            resultItems[index].seen = true
        }
        self.cellViewModels = resultItems

    }
    
}
