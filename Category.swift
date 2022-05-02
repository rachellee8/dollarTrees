//
//  Category.swift
//  swiftFinalProject
//
//  Created by Rachel Lee on 4/29/22.
//

import Foundation
import Firebase

class Category {
    var category: String
    var initialBudget: Double
    var money: Double
    var plant: String
    var postingUserID: String
    var documentID: String
    var dictionary: [String: Any] {
        return ["category": category, "initialBudget": initialBudget, "money": money, "plant": plant]
    }

    init(category: String, initialBudget: Double, money: Double, plant: String, postingUserID: String, documentID: String) {
        self.category = category
        self.initialBudget = initialBudget
        self.money = money
        self.plant = plant
        self.postingUserID = postingUserID
        self.documentID = documentID
    }

    convenience init() {
        self.init(category: "", initialBudget: 0.0, money: 0.0, plant: "", postingUserID: "", documentID: "")
    }

    convenience init(dictionary: [String: Any]) {
        let category = dictionary["category"] as! String? ?? ""
        let initialBudget = dictionary["initialBudget"] as! Double? ?? 0.0
        let money = dictionary["money"] as! Double? ?? 0.0
        let plant = dictionary["plant"] as! String? ?? ""
        let postingUserID = dictionary["postingUserID"] as! String? ?? ""
        self.init(category: category, initialBudget: initialBudget, money: money, plant: plant, postingUserID: postingUserID, documentID: "")
    }

    func saveData(user: BudgetUser, completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        // Grab the user ID
        guard let postingUserID = Auth.auth().currentUser?.uid else {
            print("😡 ERROR: Could not save data because we don't have a valid postingUserID.")
            return completion(false)
        }
        self.postingUserID = postingUserID
        // Create the dictionary representing data we want to save
        let dataToSave: [String: Any] = self.dictionary
        //if we HAVE saved a record, we'll have an ID, otherwise .addDocument will reate one.
        print(self.documentID)
        if self.documentID == "" { // create a new document via .addDocument
            //var ref: DocumentReference? = nil // Firestore will create a new ID for us
            db.collection("users").document(user.documentID).collection("categories").document(dataToSave["category"] as! String).setData(dataToSave)
//            addDocument(data: dataToSave) { error in
//                guard error == nil else {
//                    print("😡 ERROR: adding document \(error!.localizedDescription)")
//                    return completion(false)
//                }
//                self.documentID = ref!.documentID
//                print("💨 Added document: \(self.documentID)") // It worked!
//                completion(true)
//            }
        } else { // else save to the existing documentID w/ .setData
            let ref = db.collection("users").document(user.documentID).collection("categories").document(self.documentID)
            ref.setData(dataToSave) { error in
                guard error == nil else {
                    print("😡 ERROR: updating document \(error!.localizedDescription)")
                    return completion(false)
                }
                print("💨 Updated document: \(self.documentID)") // It worked!
                completion(true)
            }
        }
    }
    
    func deleteData(user: BudgetUser, category: String, completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        db.collection("users").document(user.documentID).collection("categories").document(category).delete { (error) in
            if let error = error {
                print("😡 ERROR: deleting review documentID \(self.documentID). Error: \(error.localizedDescription)")
                completion(false)
            } else {
                print("👍🏻 Successfully deleted document \(self.documentID)")
                completion(true)
            }
        }
    }
}
