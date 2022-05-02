//
//  GardenViewController.swift
//  finalProject
//
//  Created by Rachel Lee on 4/25/22.
//

import UIKit
import FirebaseAuthUI
import FirebaseGoogleAuthUI

class GardenViewController: UIViewController {
    @IBOutlet weak var gardenTableView: UITableView!
    
    var categories: Categories!
    var loginViewController = LoginViewController()
    var authUI: FUIAuth!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categories = Categories()
        
        gardenTableView.delegate = self
        gardenTableView.dataSource = self
        
        authUI = FUIAuth.defaultAuthUI()
        authUI.delegate = loginViewController
        
        guard let currentUser = self.authUI.auth?.currentUser else {
            print("Couldn't get current user.")
            return
        }
        let budgetUser = BudgetUser(user: currentUser)
        
        categories.loadData(user: budgetUser) {
            var cats: [String] = []
            var removeCatsIndex: [Int] = []
            let arrayCount = self.categories.categoriesArray.count
            for i in 0..<arrayCount {
                if cats.contains(self.categories.categoriesArray[i].category) {
//                        self.categories.categoriesArray.remove(at: i)
                    removeCatsIndex.append(i)
                } else {
                    cats.append(self.categories.categoriesArray[i].category)
                }
            }
            self.categories.categoriesArray.remove(atOffsets: IndexSet(removeCatsIndex))
            print(self.categories.categoriesArray.count)
        }
        self.gardenTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let currentUser = self.authUI.auth?.currentUser else {
            print("Couldn't get current user.")
            return
        }
        let budgetUser = BudgetUser(user: currentUser)

        categories.loadData(user: budgetUser) {
            var cats: [String] = []
            var removeCatsIndex: [Int] = []
            let arrayCount = self.categories.categoriesArray.count
            for i in 0..<arrayCount {
                if cats.contains(self.categories.categoriesArray[i].category) {
//                        self.categories.categoriesArray.remove(at: i)
                    removeCatsIndex.append(i)
                } else {
                    cats.append(self.categories.categoriesArray[i].category)
                }
            }
            self.categories.categoriesArray.remove(atOffsets: IndexSet(removeCatsIndex))
            self.gardenTableView.reloadData()
        }
    }
}

extension GardenViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        categories.loadData {
//            var cats: [String] = []
//            var removeCatsIndex: [Int] = []
//            let arrayCount = self.categories.categoriesArray.count
//            for i in 0..<arrayCount {
//                if cats.contains(self.categories.categoriesArray[i].category) {
////                        self.categories.categoriesArray.remove(at: i)
//                    removeCatsIndex.append(i)
//                } else {
//                    cats.append(self.categories.categoriesArray[i].category)
//                }
//            }
//            self.categories.categoriesArray.remove(atOffsets: IndexSet(removeCatsIndex))
//            self.categoryCount = self.categories.categoriesArray.count
//        }
//        print(categoryCount)
//        return categoryCount
        return categories.categoriesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = gardenTableView.dequeueReusableCell(withIdentifier: "TreeCell", for: indexPath) as! GardenTableViewCell
        print(categories.categoriesArray[indexPath.row].plant)
        cell.gardenStuff = Budget(subject: categories.categoriesArray[indexPath.row].category, initialBudget: categories.categoriesArray[indexPath.row].initialBudget, money: self.categories.categoriesArray[indexPath.row].money, plant: categories.categoriesArray[indexPath.row].plant)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 238
    }
}
