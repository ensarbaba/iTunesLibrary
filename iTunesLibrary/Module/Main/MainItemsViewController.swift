//
//  MainItemsViewController.swift
//  iTunesLibrary
//
//  Created by Ensar Baba on 4.07.2020.
//  Copyright © 2020 Ensar Baba. All rights reserved.
//

import UIKit

class MainItemsViewController: UIViewController {
    
    @IBOutlet weak var itemsCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var filterMediaTypeButton: UIBarButtonItem!
    
    private var sectionInsets = UIEdgeInsets(top: 10.0,
                                             left: 10.0,
                                             bottom: 10.0,
                                             right: 10.0)
    private var spacing:CGFloat = 10
//    var rightBarButtonItem: UIBarButtonItem?
    
    lazy var viewModel: MainItemsViewModel = {
        return MainItemsViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        //Initialize and modify items collection view
        initCollectionView()
        
        initViewModel()
    }
    
    private func initUI() {
        self.searchBar.delegate = self
        self.searchBar.placeholder = "Search for an item"
//        rightBarButtonItem = UIBarButtonItem(title: "All", style: .plain, target: self, action: #selector(showMediaTypes))
        
        filterMediaTypeButton?.tintColor = .blue
//        let navitem = UINavigationItem()
//        navitem.title = "Items"
        
//        navitem.rightBarButtonItem = rightBarButtonItem
//        self.navigationController?.navigationBar.setItems([navitem], animated: true)
        
    }
    @objc func showMediaTypes() {
       
        
    }
    func initCollectionView() {
        itemsCollectionView.dataSource = self
        itemsCollectionView.delegate = self
        guard let collectionView = itemsCollectionView, let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        flowLayout.minimumInteritemSpacing = spacing
        flowLayout.minimumLineSpacing = spacing
        flowLayout.sectionInset = sectionInsets
        
    }
    func initViewModel() {
        noDataLabel.alpha = 1.0
        itemsCollectionView.alpha = 0.0
       
        //Data Binding
        viewModel.showAlertClosure = { [weak self] () in
            DispatchQueue.main.async {
                if let message = self?.viewModel.alertMessage {
                    self?.showAlert( message )
                }
            }
        }
        
        viewModel.updateLoadingStatus = { [weak self] isLoading in
            DispatchQueue.main.async {
                let isLoading = self?.viewModel.isLoading ?? false
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.itemsCollectionView.alpha = 0.0
                        self?.noDataLabel.alpha = 0.0
                    })
                }else {
                    self?.activityIndicator.stopAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.itemsCollectionView.alpha = 1.0
                        
                    })
                }
            }
        }
        
        viewModel.reloadTableViewClosure = { [weak self] () in
            DispatchQueue.main.async {
                if self?.viewModel.numberOfItems == 0 {
                    self?.noDataLabel.alpha = 1.0
                    self?.itemsCollectionView.alpha = 0.0
                } else {
                    self?.itemsCollectionView.reloadData()
                }
            }
        }
        
    }
    
    private func showAlert( _ message: String ) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction( UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { context in
            DispatchQueue.main.async {
                self.itemsCollectionView.reloadData()
            }
        })
    }
    @IBAction func filterButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
               let typesVC = storyboard.instantiateViewController(withIdentifier: "typesVC") as! MediaTypeViewController
               typesVC.modalPresentationStyle = .fullScreen
               typesVC.delegate = self
               self.present(typesVC, animated: false)
    }
    
    @objc func searchFor() {
        guard let searchText = searchBar.text else { return }
        viewModel.fetchItemsWith(term: searchText, mediaType: viewModel.selectedMediaType)
    }
    
}

extension MainItemsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCollectionViewCell", for: indexPath) as? ItemCollectionViewCell else { return UICollectionViewCell() }
        cell.itemListCellViewModel = viewModel.getCellViewModel( at: indexPath )
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let numberOfItem: CGFloat = UIApplication.shared.statusBarOrientation.isLandscape ? 2.0 : 1.0
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(numberOfItem - 1))
        
        let size = Int((collectionView.bounds.size.width - totalSpace) / CGFloat(numberOfItem))
        return CGSize(width: size, height: size)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = viewModel.getCellViewModel(at: indexPath)
        do {
            try PersistenceManager.shared.insertItemWith(id: item.id, seen: true, filtered: false)
            viewModel.updateSeenItems()
        } catch {
            print("something went wrong")
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailsVC = storyboard.instantiateViewController(withIdentifier: "detailsVC") as! ItemsDetailViewController
        detailsVC.selectedItem = item
        detailsVC.selectedIndexPath = indexPath
        detailsVC.popDelegate = self
        self.navigationController?.pushViewController(detailsVC, animated: true)
    
    }
    
}

extension MainItemsViewController:UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(searchFor), object: nil)
        self.perform(#selector(searchFor), with: nil, afterDelay: 1.5)
    }
}

extension MainItemsViewController: MediaTypeDelegate, ItemsDetailDelegate {
    
    func itemsDetailDidPop(indexPath: IndexPath) {
            self.itemsCollectionView.performBatchUpdates({
                viewModel.removeCellViewModel(at: indexPath)
                self.itemsCollectionView.deleteItems(at: [indexPath])
           }, completion:nil)
    }
    
    func didMediaTypeSelect(type: String) {
        if type != viewModel.selectedMediaType {
            viewModel.selectedMediaType = type.lowercased()
            filterMediaTypeButton?.title = type
            guard let searchText = searchBar.text else { return }
            viewModel.fetchItemsWith(term: searchText, mediaType: viewModel.selectedMediaType)
        }
    }
}
