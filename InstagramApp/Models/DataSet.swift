//
//  DataSet.swift
//  InstagramApp
//
//  Created by 大谷空 on 2021/01/20.
//

import Foundation
import Firebase
import FirebaseFirestore

struct DataSet {
    
    let username: String
    let profileImageUrl: String
    let createdAt: Timestamp
    let contentImageUrl: String
    let contentText: String
    let uid: String
    
}
