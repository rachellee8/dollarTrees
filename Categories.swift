//
//  Categories.swift
//  swiftFinalProject
//
//  Created by Rachel Lee on 4/29/22.
//

import Foundation
import Firebase
import FirebaseAuth

class Categories {
    var categoriesArray: [Category] = []
    var db: Firestore!

    init() {
        db = Firestore.firestore()
    }

//    init(itemsArray: [Item]) {
//        self.categoriesArray = []
//    }

    func loadData(user: BudgetUser, completed: @escaping () -> ()) {
        db.collection("users").document(user.documentID).collection("categories").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("😡 ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.categoriesArray = [] // clean out existing itemsArray since new data will load
            // there are querySnapshot!.documents.count documents in the snapshot
//            var cats = [""]
//            for i in 0..<querySnapshot!.documents.count {
//                let categoryCheck = Category(dictionary: querySnapshot!.documents[i].data())
//                if cats.contains(categoryCheck.category) {
//                    //querySnapshot!.documents[cats.firstIndex(of: categoryCheck.category)!] = Category(dictionary: document.data())
//                }
//                cats.append(categoryCheck.category)
//            }
            for document in querySnapshot!.documents {
                // You'll have to make sure you have a dictionary initializer in the singular class
                let category = Category(dictionary: document.data())
                category.documentID = document.documentID
                self.categoriesArray.append(category)
            }
            completed()
        }
    }
}
