//
//  ItemsDetailViewController.swift
//  iTunesLibrary
//
//  Created by Ensar Baba on 4.07.2020.
//  Copyright © 2020 Ensar Baba. All rights reserved.
//

import UIKit

protocol ItemsDetailDelegate: class {
    func itemsDetailDidPop(indexPath: IndexPath)
}

class ItemsDetailViewController: UIViewController {
    
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var detailLabel: UILabel!
    
    var selectedItem: ItemListCellViewModel?
    var selectedIndexPath: IndexPath?
    
    weak var popDelegate: ItemsDetailDelegate?
    private var rightBarButtonItem: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailImageView.downloaded(from: selectedItem?.imageUrl ?? "")
        detailLabel.text = selectedItem?.name
    }
    
    @IBAction func deleteTapped(_ sender: Any) {
        print("delete tapped")
        let alert = UIAlertController(title: "Delete?", message: "Selected item will be deleted for good",         preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { _ in
            //Cancel Action
        }))
        alert.addAction(UIAlertAction(title: "Delete",
                                      style: UIAlertAction.Style.default,
                                      handler: {(_: UIAlertAction!) in
                                        do {
                                            try PersistenceManager.shared.insertItemWith(id: self.selectedItem?.id ?? 0, seen: true, filtered: true)
                                            self.navigationController?.popViewController(animated: true, completion: {
                                                guard let indexPath = self.selectedIndexPath else {return}
                                                self.popDelegate?.itemsDetailDidPop(indexPath: indexPath)
                                            })
                                            
                                        } catch {
                                            print("something went wrong")
                                        }
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
}
extension UINavigationController {
    
    func popViewController(animated: Bool = true, completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        popViewController(animated: animated)
        CATransaction.commit()
    }
    
    func pushViewController(_ viewController: UIViewController, animated: Bool = true, completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
}
