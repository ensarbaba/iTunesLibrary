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
}
enum ItemKind: String {
    case song = "song"
    case movie = "feature-movie"
    case podcast = "podcast"
}
class MainItemsViewModel {
    
    private var items: [Results] = [Results]()
    private var filterRules = ["song", "feature-movie", "podcast"]
    
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
    
    var isAllowSegue: Bool = false
    
    var selectedItem: Results?
    var selectedMediaType: String = "all"
    
    var reloadTableViewClosure: (()->())?
    var showAlertClosure: (()->())?
    var updateLoadingStatus: ((_ show: Bool)->())?

    
    func fetchItemsWith(term: String, mediaType: String) {
        self.isLoading = true
        APIClient.shared.search(term: term, mediaType: mediaType) { [weak self] (success, errorMessage, responseData) in
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

    func createCellViewModel(item: Results ) -> ItemListCellViewModel {
        return ItemListCellViewModel(name: item.trackName ?? "", id: item.trackId ?? 0, imageUrl: item.artworkUrl100 ?? "", kind: item.kind ?? "")
    }

    private func processFetchedItem( items: [Results] ) {
        var vms = [ItemListCellViewModel]()
        for item in items where filterRules.contains(item.kind ?? "") {
            vms.append(createCellViewModel(item: item) )
        }
        self.cellViewModels = vms
    }

}

extension MainItemsViewModel {
    func userPressed( at indexPath: IndexPath ){
        self.selectedItem = self.items[indexPath.row]
    }
}
