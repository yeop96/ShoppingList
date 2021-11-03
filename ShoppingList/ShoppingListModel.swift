//
//  ShoppingListModel.swift
//  ShoppingList
//
//  Created by yeop on 2021/11/04.
//

import Foundation
import RealmSwift // 10.18.0 exact version


//https://docs.mongodb.com/realm/sdk/ios/quick-start 문서

class ShoppingList: Object {
    @Persisted var shoppingContent: String
    @Persisted var confirmed: Bool
    @Persisted var favorite: Bool
    @Persisted var regDate = Date()
    @Persisted(primaryKey: true) var _pk: ObjectId
    
    convenience init(shoppingContent: String, confirmed: Bool, favorite: Bool, regDate: Date) {
        self.init()
        
        self.shoppingContent = shoppingContent
        self.confirmed = confirmed
        self.favorite = favorite
        self.regDate = regDate
    }
}
