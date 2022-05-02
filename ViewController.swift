//
//  ViewController.swift
//  finalProject
//
//  Created by Rachel Lee on 4/20/22.
//

import UIKit
import SwiftUI
import FirebaseAuthUI
import FirebaseGoogleAuthUI

//var budgets: [Budget] = []

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    @IBOutlet weak var addCategoryBarButton: UIBarButtonItem!
    @IBOutlet weak var addItemBarButton: UIBarButtonItem!
    @IBOutlet weak var gardenBarButton: UIBarButtonItem!
    @IBOutlet weak var summaryBarButton: UIBarButtonItem!
    
    var categories: Categories!
    var categoryName: String!
    var category: Category!
    var authUI: FUIAuth!
    var loginViewController = LoginViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        budgets.append(Budget(subject: "Clothes", initialBudget: 100000.00, money: 100000.00, plant: "Tree_A-1"))
//        budgets.append(Budget(subject: "Food", initialBudget: 300000.00, money: 300000.00, plant: "Tree_D-1"))
        
        categories = Categories()
        tableView.delegate = self
        tableView.dataSource = self
        
        authUI = FUIAuth.defaultAuthUI()
        authUI.delegate = loginViewController
        
        guard let currentUser = self.authUI.auth?.currentUser else {
            print("Couldn't get current user.")
            return
        }
        let budgetUser = BudgetUser(user: currentUser)
        
        categories.loadData(user: budgetUser) {
            if self.categories.categoriesArray.count == 0 {
                self.addItemBarButton.isEnabled = false
            } else {
                self.addItemBarButton.isEnabled = true
                var cats: [String] = []
                var removeCatsIndex: [Int] = []
                print(self.categories.categoriesArray.count)
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
            }
            self.tableView.reloadData()
        }
        
        if category == nil {
            category = Category()
        }
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.setToolbarHidden(false, animated: true)
        
        guard let currentUser = self.authUI.auth?.currentUser else {
            print("Couldn't get current user.")
            return
        }
        let budgetUser = BudgetUser(user: currentUser)

        categories.loadData(user: budgetUser) {
            if self.categories.categoriesArray.count == 0 {
                self.addItemBarButton.isEnabled = false
            } else {
                self.addItemBarButton.isEnabled = true
                var cats: [String] = []
                var removeCatsIndex: [Int] = []
                print(self.categories.categoriesArray.count)
                let arrayCount = self.categories.categoriesArray.count
                for i in 0..<arrayCount {
                    if cats.contains(self.categories.categoriesArray[i].category) {
//                        self.categories.categoriesArray.remove(at: i)
                        removeCatsIndex.append(i)
                    } else {
                        cats.append(self.categories.categoriesArray[i].category)
                    }
                }
                print(removeCatsIndex)
                self.categories.categoriesArray.remove(atOffsets: IndexSet(removeCatsIndex))
            }
            self.tableView.reloadData()
        }
    }
    
    func formatCurrencyWithSymbol(number: Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        guard let formattedNumber = numberFormatter.string(from: NSNumber(value: number)) else {
            return ""
        }
        return "\(formattedNumber)"
    }
    
    func formatCurrencyWithoutSymbol(number: Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencySymbol = .none
        guard let formattedNumber = numberFormatter.string(from: NSNumber(value: number)) else {
            return ""
        }
        return "\(formattedNumber)"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let destination = segue.destination as! DetailViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            print(self.categories.categoriesArray[selectedIndexPath.row].category)
            destination.budget = Budget(subject: self.categories.categoriesArray[selectedIndexPath.row].category, initialBudget: 0, money: self.categories.categoriesArray[selectedIndexPath.row].money, plant: "")
//            destination.budget.subject =
//            destination.budget.money = self.categories.categoriesArray[selectedIndexPath.row].money
            
//            destination.budget.subject = categories.categoriesArray[selectedIndexPath.row].category
//            destination.budget.initialBudget = categories.categoriesArray[selectedIndexPath.row].initialBudget
//            destination.budget.money = categories.categoriesArray[selectedIndexPath.row].money
//            destination.budget.plant = categories.categoriesArray[selectedIndexPath.row].plant
        } else {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedIndexPath, animated: true)
            }
        }
    }
    
    @IBAction func unwindFromDetailViewController(segue: UIStoryboardSegue) {
        let source = segue.source as! DetailViewController
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
//            categories.categoriesArray[selectedIndexPath.row] = source.budget
            
            guard let currentUser = self.authUI.auth?.currentUser else {
                print("Couldn't get current user.")
                return
            }
            let budgetUser = BudgetUser(user: currentUser)
            
            categories.loadData(user: budgetUser) {
                var cats: [String] = []
                var removeCatsIndex: [Int] = []
                print(self.categories.categoriesArray.count)
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
                
                self.tableView.reloadData()
                
                self.categories.categoriesArray[selectedIndexPath.row].category = source.budget.subject
                self.categories.categoriesArray[selectedIndexPath.row].initialBudget = source.budget.initialBudget
                self.categories.categoriesArray[selectedIndexPath.row].money = source.budget.money
                self.categories.categoriesArray[selectedIndexPath.row].plant = source.budget.plant
            }
            tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
        }
    }
    
    @IBAction func unwindFromNewItemDetailViewController(segue: UIStoryboardSegue) {
        let source = segue.source as! NewItemDetailViewController
        let cells = self.tableView.visibleCells
        for cell in cells {
            if cell.textLabel!.text == source.itemBought.category {
                let budgetMoney = Double((cell.detailTextLabel!.text?.replacingOccurrences(of: "$", with: "").replacingOccurrences(of: ",", with: ""))!)!
                cell.detailTextLabel!.text = formatCurrencyWithSymbol(number: budgetMoney - source.itemBought.price)
                var indexAll = 0
                var indexBudget = 0
                for budget in self.categories.categoriesArray {
                    if budget.category == source.itemBought.category {
                        self.categories.categoriesArray.insert((Category(category: source.itemBought.category, initialBudget: budget.initialBudget, money: budgetMoney - source.itemBought.price, plant: budget.plant, postingUserID: self.category.postingUserID, documentID: "")), at: indexAll)
                        indexBudget = indexAll + 1
                        
                        guard let currentUser = self.authUI.auth?.currentUser else {
                            print("Couldn't get current user.")
                            return
                        }
                        let budgetUser = BudgetUser(user: currentUser)
                        
                        self.category.category = budget.category
                        self.category.initialBudget = budget.initialBudget
                        self.category.money = budgetMoney - source.itemBought.price
                        self.category.plant = budget.plant
                        self.category.saveData(user: budgetUser) { success in
                            if success {
                                print("SUCCESS! SAVED CATEGORY")
                            } else {
                                print("FAILED TO SAVE CATEGORY")
                            }
                        }
                    }
                    indexAll += 1
                }
                self.categories.categoriesArray.remove(at: indexBudget)
                
                guard let currentUser = self.authUI.auth?.currentUser else {
                    print("Couldn't get current user.")
                    return
                }
                let budgetUser = BudgetUser(user: currentUser)
                
                categories.loadData(user: budgetUser) {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func unwindFromNewCategoryDetailViewController(segue: UIStoryboardSegue) {
        let source = segue.source as! NewCategoryDetailViewController
        let newIndexPath = IndexPath(row: categories.categoriesArray.count, section: 0)
        categories.categoriesArray.append(Category(category: source.budget.subject, initialBudget: source.budget.initialBudget, money: source.budget.money, plant: source.budget.plant, postingUserID: category.postingUserID, documentID: ""))
        print(categories.categoriesArray)
        tableView.insertRows(at: [newIndexPath], with: .bottom)
        tableView.scrollToRow(at: newIndexPath, at: .bottom, animated: true)
        addItemBarButton.isEnabled = true
        
        guard let currentUser = authUI.auth?.currentUser else {
            print("Couldn't get current user.")
            return
        }
        let budgetUser = BudgetUser(user: currentUser)
        
        category.category = source.budget.subject
        category.initialBudget = source.budget.initialBudget
        category.money = source.budget.money
        category.plant = source.budget.plant
        category.saveData(user: budgetUser) { success in
            if success {
                print("SUCCESS! SAVED CATEGORY")
            } else {
                print("FAILED TO SAVE CATEGORY")
            }
        }
    }
    
    @IBAction func editBarButtonPressed(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            editBarButton.title = "Edit"
            addCategoryBarButton.isEnabled = true
        } else {
            tableView.setEditing(true, animated: true)
            editBarButton.title = "Done"
            addCategoryBarButton.isEnabled = false
        }
        
        if categories.categoriesArray.count == 0 {
            addItemBarButton.isEnabled = false
        } else {
            addItemBarButton.isEnabled = true
        }
    }
    
    @IBAction func gardenButtonPressed(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "ShowGarden", sender: sender)
    }
    
    @IBAction func summaryButtonPressed(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "ShowSummary", sender: sender)
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(categories.categoriesArray.count)
        return categories.categoriesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = categories.categoriesArray[indexPath.row].category
        cell.detailTextLabel?.text = formatCurrencyWithSymbol(number: categories.categoriesArray[indexPath.row].money)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            guard let currentUser = authUI.auth?.currentUser else {
                print("Couldn't get current user.")
                return
            }
            let budgetUser = BudgetUser(user: currentUser)
            
            category.deleteData(user: budgetUser, category: self.categories.categoriesArray[indexPath.row].category) { success in
                if success {
//                    self.categories.categoriesArray.remove(at: indexPath.row)
//                    tableView.deleteRows(at: [indexPath], with: .fade)
                } else {
                    print("😡 Delete unsuccessful")
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = categories.categoriesArray[sourceIndexPath.row]
        categories.categoriesArray.remove(at: sourceIndexPath.row)
        categories.categoriesArray.insert(itemToMove, at: destinationIndexPath.row)
    }
}
