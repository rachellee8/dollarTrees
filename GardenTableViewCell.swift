//
//  GardenTableViewCell.swift
//  finalProject
//
//  Created by Rachel Lee on 4/26/22.
//

import UIKit

class GardenTableViewCell: UITableViewCell {
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var treeImageView: UIImageView!
    
    let treeAArray = ["Tree_A-1", "Tree_A-2", "Tree_A-3", "Tree_A-4"]
    let treeCArray = ["Tree_C-1", "Tree_C-2", "Tree_C-3", "Tree_C-4"]
    let treeDArray = ["Tree_D-1", "Tree_D-2", "Tree_D-3", "Tree_D-4"]
    let treeEArray = ["Tree_E-1", "Tree_E-2", "Tree_E-3", "Tree_E-4"]
    var treeArray: [String] = []
    
    var gardenStuff: Budget! {
        didSet {
            switch gardenStuff.plant {
            case "Tree_A-1":
                treeArray = treeAArray
            case "Tree_C-1":
                treeArray = treeCArray
            case "Tree_D-1":
                treeArray = treeDArray
            case "Tree_E-1":
                treeArray = treeEArray
            default:
                treeArray = ["", "", "", ""]
            }
            categoryLabel.text = gardenStuff.subject
            print(gardenStuff.money)
            if gardenStuff.money > 0.75 * gardenStuff.initialBudget {
                treeImageView.image = UIImage(named: gardenStuff.plant)
            } else if gardenStuff.money > 0.5 * gardenStuff.initialBudget {
                treeImageView.image = UIImage(named: treeArray[1])
            } else if gardenStuff.money > 0.25 * gardenStuff.initialBudget {
                treeImageView.image = UIImage(named: treeArray[2])
            } else {
                treeImageView.image = UIImage(named: treeArray[3])
            }
        }
    }
}
