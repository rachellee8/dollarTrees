//
//  DetailViewController.swift
//  finalProject
//
//  Created by Rachel Lee on 4/25/22.
//

import UIKit
import FirebaseAuthUI
import FirebaseGoogleAuthUI

class DetailViewController: UIViewController {
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var budgetTextField: UITextField!
    
    var budget: Budget!
    var plantViewController = PlantViewController()
    var loginViewController = LoginViewController()
    var category: Category!
    var authUI: FUIAuth!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //budget = Budget(subject: "", initialBudget: 0, money: 0, plant: "")
        category = Category()
        
        // hide keyboard if we tap outside of field
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        categoryTextField.text = budget.subject
        budgetTextField.text = formatNumberWithCommas(number: budget.money)
        
        authUI = FUIAuth.defaultAuthUI()
        authUI.delegate = loginViewController
    }
    
    func formatNumberWithCommas(number: Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencySymbol = ""
        guard let formattedNumber = numberFormatter.string(from: NSNumber(value: number)) else {
            return ""
        }
        return "\(formattedNumber)"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        budget.subject = categoryTextField.text!
        budget.money = Double((budgetTextField.text!).replacingOccurrences(of: ",", with: "")) ?? budget.money
        budget.initialBudget = budget.money
        
        guard let currentUser = authUI.auth?.currentUser else {
            print("Couldn't get current user.")
            return
        }
        let budgetUser = BudgetUser(user: currentUser)
        
        category.category = budget.subject
        category.initialBudget = budget.initialBudget
        category.money = budget.money
        category.plant = budget.plant
        category.saveData(user: budgetUser) { success in
            if success {
                print("SUCCESS! SAVED CATEGORY")
            } else {
                print("FAILED TO SAVE CATEGORY")
            }
        }
        
    }

    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        navigationController!.popViewController(animated: true)
    }
    
    @IBAction func plantButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "PlantTree", sender: sender)
        treeIndex = sender.tag
        budget.plant = plantViewController.trees[treeIndex]
    }

}
