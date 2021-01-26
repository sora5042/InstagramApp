//
//  Edit.swift
//  InstagramApp
//
//  Created by 大谷空 on 2021/01/18.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseFirestore

class PostDB {
    
    let username: String
    let createdAt: Timestamp
    let contentImageUrl: String
    let contentText: String
    var uid: String
    var postId: String
    let profileImageUrl: String
    let postDate: Double
    let likeCount: Int
    let likeFlagDic: Dictionary<String, Bool>
    
    init(dic: [String: Any]) {
        
        self.username = dic["username"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        self.contentImageUrl = dic["contentImageUrl"] as? String ?? ""
        self.contentText = dic["contentText"] as? String ?? ""
        self.uid = dic["uid"] as? String ?? ""
        self.postId = dic["postId"] as? String ?? ""
        self.profileImageUrl = dic["profileImageUrl"] as? String ?? ""
        self.postDate = dic["postDate"] as? Double ?? Double()
        self.likeCount = dic["likeCount"] as? Int ?? Int()
        self.likeFlagDic = dic["likeFlagDic"] as? Dictionary ?? Dictionary()
    }
    
}
