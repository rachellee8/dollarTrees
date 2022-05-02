//
//  DetailViewController.swift
//  finalProject
//
//  Created by Rachel Lee on 4/20/22.
//

import UIKit
import FirebaseAuthUI
import FirebaseGoogleAuthUI

private let dateFormatter: DateFormatter = {
    print("📅 I JUST CREATED A DATE FORMATTER!")
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy"
    return dateFormatter
}()

class NewItemDetailViewController: UIViewController {
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var itemTextField: UITextField!
    @IBOutlet weak var moneyTextField: UITextField!
    @IBOutlet weak var flowerImageView: UIImageView!
    @IBOutlet weak var compactDatePicker: UIDatePicker!
    
    var categories: Categories!
    var itemBought: Item!
    var itemsBoughtArray: [Item] = []
    var flowerImageIndex = Int.random(in: 0...4)
    var boughtItem: BoughtItem!
    
    let viewController = ViewController()
    var loginViewController = LoginViewController()
    
    var authUI: FUIAuth!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categories = Categories()
        
        if boughtItem == nil {
            boughtItem = BoughtItem()
        }
        
        // hide keyboard if we tap outside of field
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        itemTextField.text = ""
        moneyTextField.text = ""
        categoryTextField.text = ""
        
        let presentDate = dateFormatter.string(from: Date())
        let sublist = presentDate.split(separator: "/")
        var stringList: [String] = []
        for element in sublist {
            stringList.append(String(element))
        }
        
        if itemBought == nil {
            itemBought = Item(category: "", itemName: "", price: 0.0, date: stringList)
        }
        
        categoryTextField.text = itemBought.category
        itemTextField.text = itemBought.itemName
        moneyTextField.text = formatCurrencyWithoutSymbol(number: itemBought.price)
        
        flowerImageView.image = UIImage(named: "flower\(flowerImageIndex)")
        flowerImageIndex = Int.random(in: 0...4)
        
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
    }
    
    func formatCurrencyWithoutSymbol(number: Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencySymbol = ""
        guard let formattedNumber = numberFormatter.string(from: NSNumber(value: number)) else {
            return ""
        }
        return "\(formattedNumber)"
    }
    
    func formatCurrencyWithSymbol(number: Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        guard let formattedNumber = numberFormatter.string(from: NSNumber(value: number)) else {
            return ""
        }
        return "\(formattedNumber)"
    }
    
    func showInsufficientFundsAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let addFundsAction = UIAlertAction(title: "Add Funds", style: .default) { (_) in
            let isPresentingInAddMode = self.presentingViewController is UINavigationController
            if isPresentingInAddMode { // present modally segue, coming from plus
                self.dismiss(animated: true, completion: nil)
            } else { // show segue
                self.navigationController!.popViewController(animated: true)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(addFundsAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func categoryAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okAction)
//        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        var subjectList: [String] = []
        for budget in categories.categoriesArray {
            subjectList.append(budget.category)
        }
        
        if subjectList.contains(categoryTextField.text!) {
            for budget in categories.categoriesArray {
                if budget.category == categoryTextField.text {
                    if Double(moneyTextField.text!) ?? 0.0 > budget.money {
                        showInsufficientFundsAlert(title: "Insufficient Funds", message: "You spent more than your budget!")
                    } else {
                        itemBought.itemName = itemTextField.text!
                        itemBought.price = Double(moneyTextField.text!) ?? 0.0
                        itemBought.category = categoryTextField.text!
                        
                        guard let currentUser = authUI.auth?.currentUser else {
                            print("Couldn't get current user.")
                            return
                        }
                        let budgetUser = BudgetUser(user: currentUser)
                        boughtItem.category = itemBought.category
                        boughtItem.itemName = itemBought.itemName
                        boughtItem.price = itemBought.price
                        boughtItem.date = itemBought.date
                        boughtItem.saveData(user: budgetUser) { success in
                            if success {
                                self.performSegue(withIdentifier: "UnwindSegue", sender: sender)
                            } else {
                                self.oneButtonAlert(title: "Save Failed", message: "For some reason, the data would not save to the cloud.")
                            }
                        }
                    }
                }
            }
        } else {
            categoryAlert(title: "Category Error", message: "No such category exists in your budgets!")
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode { // present modally segue, coming from plus
            dismiss(animated: true, completion: nil)
        } else { // show segue
            navigationController!.popViewController(animated: true)
        }
    }
    
    @IBAction func datePickerChanged(_ sender: Any) {
        self.view.endEditing(true)
        let date = dateFormatter.string(from: (sender as AnyObject).date)
        let sublist = date.split(separator: "/")
        var stringList: [String] = []
        for element in sublist {
            stringList.append(String(element))
        }
        itemBought.date = stringList
    }
}
