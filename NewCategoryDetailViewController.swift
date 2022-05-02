//
//  NewDetailViewController.swift
//  finalProject
//
//  Created by Rachel Lee on 4/20/22.
//

import UIKit
//import FirebaseAuthUI
//import FirebaseGoogleAuthUI

var treeIndex = 0

class NewCategoryDetailViewController: UIViewController {
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var budgetTextField: UITextField!
    
    var budget: Budget!
    var plantViewController = PlantViewController()
//    var loginViewController = LoginViewController()
//    var category: Category!
//    var authUI: FUIAuth!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hide keyboard if we tap outside of field
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        categoryTextField.text = ""
        budgetTextField.text = formatNumberWithCommas(number: 0.0)
        
        if budget == nil {
            budget = Budget(subject: "", initialBudget: 0.0, money: 0.0, plant: "")
        }
        
//        authUI = FUIAuth.defaultAuthUI()
//        authUI.delegate = loginViewController
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        budget.subject = categoryTextField.text!
        budget.initialBudget = Double(budgetTextField.text!) ?? 0.0
        budget.money = budget.initialBudget
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
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func plantButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "PlantTree", sender: sender)
        treeIndex = sender.tag
        budget.plant = plantViewController.trees[treeIndex]
    }
}
