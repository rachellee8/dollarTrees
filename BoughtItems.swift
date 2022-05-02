//
//  BoughtItems.swift
//  finalProject
//
//  Created by Rachel Lee on 4/28/22.
//

import Foundation
import Firebase
import FirebaseAuth

class BoughtItems {
    var itemsArray: [BoughtItem] = []
    var db: Firestore!

    init() {
        db = Firestore.firestore()
    }

//    init(itemsArray: [Item]) {
//        self.itemsArray = itemsArray
//    }

    func loadData(user: BudgetUser, completed: @escaping () -> ()) {
        db.collection("users").document(user.documentID).collection("items").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("😡 ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.itemsArray = [] // clean out existing itemsArray since new data will load
            // there are querySnapshot!.documents.count documents in the snapshot
            for document in querySnapshot!.documents {
                // You'll have to make sure you have a dictionary initializer in the singular class
                let item = BoughtItem(dictionary: document.data())
                item.documentID = document.documentID
                self.itemsArray.append(item)
            }
            completed()
        }
    }
}
