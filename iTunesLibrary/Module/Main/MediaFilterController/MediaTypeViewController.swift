//
//  MediaTypeViewController.swift
//  iTunesLibrary
//
//  Created by Ensar Baba on 5.07.2020.
//  Copyright © 2020 Ensar Baba. All rights reserved.
//

import UIKit
protocol MediaTypeDelegate: class {
    func didMediaTypeSelect(type: String)
}
class MediaTypeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
        
    @IBOutlet weak var typesTableView: UITableView!

    var types = ["Movie", "Podcast", "Music", "All"]
    weak var delegate: MediaTypeDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        typesTableView.separatorStyle = .none
        typesTableView.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
            guard let location = touch?.location(in: self.view) else { return }
            if !typesTableView.frame.contains(location) {
                self.dismiss(animated: false, completion: nil)
                print("Tapped outside the view")
            } else {
                
                print("Tapped inside the view")
            }
    }
    // MARK: - Table view data source
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return types.count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "typeCell", for: indexPath)
        cell.textLabel?.text = types[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        let label = UILabel(frame: CGRect(x: 20, y: 0, width: tableView.frame.width, height: 20))
        label.text = "Pick a media type"
        view.addSubview(label)
        return view
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didMediaTypeSelect(type: types[indexPath.row])
        self.dismiss(animated: false, completion: nil)
    }
    
}
