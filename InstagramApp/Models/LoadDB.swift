//
//  LoadDB.swift
//  InstagramApp
//
//  Created by 大谷空 on 2021/01/22.
//

import Foundation
import Firebase
import FirebaseFirestore


class LoadDB {
    
    let username: String
    let createdAt: Timestamp
    let contentImageUrl: String
    let contentText: String
    let uid: String
    let profileImageUrl: String
    let postDate: Double
    let hashTag: String
    
    init(dic: [String: Any]) {
        
        self.username = dic["username"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        self.contentImageUrl = dic["contentImageUrl"] as? String ?? ""
        self.contentText = dic["contentText"] as? String ?? ""
        self.uid = dic["uid"] as? String ?? ""
        self.profileImageUrl = dic["profileImageUrl"] as? String ?? ""
        self.postDate = dic["postDate"] as? Double ?? Double()
        self.hashTag = dic["hashTag"] as? String ?? ""
    



    }
}