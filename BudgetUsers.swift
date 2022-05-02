//
//  Users.swift
//  finalProject
//
//  Created by Rachel Lee on 4/29/22.
//

import Foundation
import Firebase

class BudgetUsers {
    var userArray: [BudgetUser] = []
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping () -> ()) {
        db.collection("users").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("😡 ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.userArray = [] // clean out existing userArray since new data will load
            // there are querySnapshot!.documents.count documents in the snapshot
            for document in querySnapshot!.documents {
                // You'll have to make sure you have a dictionary initializer in the singular class
                let user = BudgetUser(dictionary: document.data())
                user.documentID = document.documentID
                self.userArray.append(user)
            }
            completed()
        }
    }
}
