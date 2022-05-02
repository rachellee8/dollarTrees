//
//  PlantViewController.swift
//  finalProject
//
//  Created by Rachel Lee on 4/28/22.
//

import UIKit

class PlantViewController: UIViewController {
    @IBOutlet weak var treeImageView: UIImageView!
    
    var trees = ["Tree_A-1", "Tree_E-1", "Tree_C-1", "Tree_D-1"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let original = treeImageView.frame.origin.y + 22
        let start = treeImageView.frame.height
        
        UIImageView.animate(withDuration: 0.75, animations: {self.treeImageView.frame.origin.y = start}) { _ in
            self.treeImageView.frame.origin.y = original
        }
        
        treeImageView.image = UIImage(named: trees[treeIndex])
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        navigationController!.popViewController(animated: true)
    }
    

}
