//
//  BoughtItem.swift
//  finalProject
//
//  Created by Rachel Lee on 4/28/22.
//

import Foundation
import Firebase

class BoughtItem {
    var category: String
    var itemName: String
    var price: Double
    var date: [String]
    var postingUserID: String
    var documentID: String
    var dictionary: [String: Any] {
        return ["category": category, "itemName": itemName, "price": price, "date": date]
    }

    init(category: String, itemName: String, price: Double, date: [String], postingUserID: String, documentID: String) {
        self.category = category
        self.itemName = itemName
        self.price = price
        self.date = date
        self.postingUserID = postingUserID
        self.documentID = documentID
    }

    convenience init() {
        self.init(category: "", itemName: "", price: 0.0, date: [], postingUserID: "", documentID: "")
    }

    convenience init(dictionary: [String: Any]) {
        let category = dictionary["category"] as! String? ?? ""
        let itemName = dictionary["itemName"] as! String? ?? ""
        let price = dictionary["price"] as! Double? ?? 0.0
        let date = dictionary["date"] as! [String]? ?? []
        let postingUserID = dictionary["postingUserID"] as! String? ?? ""
        self.init(category: category, itemName: itemName, price: price, date: date, postingUserID: postingUserID, documentID: "")
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
        if self.documentID == "" { // create a new document via .addDocument
            var ref: DocumentReference? = nil // Firestore will create a new ID for us
            ref = db.collection("users").document(user.documentID).collection("items").addDocument(data: dataToSave) { error in
                guard error == nil else {
                    print("😡 ERROR: adding document \(error!.localizedDescription)")
                    return completion(false)
                }
                self.documentID = ref!.documentID
                print("💨 Added document: \(self.documentID)") // It worked!
                completion(true)
            }
        } else { // else save to the existing documentID w/ .setData
            let ref = db.collection("users").document(user.documentID).collection("items").document(self.documentID)
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
}
