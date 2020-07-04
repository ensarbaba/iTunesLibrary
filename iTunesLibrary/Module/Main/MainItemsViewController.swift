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
    
    private var sectionInsets = UIEdgeInsets(top: 10.0,
                                             left: 10.0,
                                             bottom: 10.0,
                                             right: 10.0)
    private var spacing:CGFloat = 10
    
    lazy var viewModel: MainItemsViewModel = {
        return MainItemsViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        //Initialize and modify items collection view
        initCollectionView()
        
        //Data Binding
        initVM()
    }
    private func initUI() {
        self.navigationItem.title = "Items"
        self.searchBar.delegate = self
        self.searchBar.placeholder = "Search for an item"
    }
    func initCollectionView() {
        itemsCollectionView.dataSource = self
        itemsCollectionView.delegate = self
        guard let collectionView = itemsCollectionView, let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        flowLayout.minimumInteritemSpacing = spacing
        flowLayout.minimumLineSpacing = spacing
        flowLayout.sectionInset = sectionInsets
        
    }
    func initVM() {
        noDataLabel.alpha = 1.0
        itemsCollectionView.alpha = 0.0

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
    @objc func searchFor() {
        guard let searchText = searchBar.text else { return }
        viewModel.fetchItemsWith(term: searchText, and: viewModel.selectedMediaType)
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

}

extension MainItemsViewController:UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(searchFor), object: nil)
        self.perform(#selector(searchFor), with: nil, afterDelay: 1.5)
    }
}
