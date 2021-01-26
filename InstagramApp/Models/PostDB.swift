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

protocol LoadOKDelegate {
    
    func loadOK(check: Int)
}

class PostDB {
    
    var dataSets = [DataSet]()
    let db = Firestore.firestore()
    var loadOKDelegate: LoadOKDelegate?
    
    let username: String
    let createdAt: Timestamp
    let contentImageUrl: String
    let contentText: String
    let uid: String
    let profileImageUrl: String
    let postDate: Double
    
    init(dic: [String: Any]) {
        
        self.username = dic["username"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        self.contentImageUrl = dic["contentImageUrl"] as? String ?? ""
        self.contentText = dic["contentText"] as? String ?? ""
        self.uid = dic["uid"] as? String ?? ""
        self.profileImageUrl = dic["profileImageUrl"] as? String ?? ""
        self.postDate = dic["postDate"] as? Double ?? Double()
    }
    
    
    func loadContents() {
        
        db.collection("post").order(by: "postDate").addSnapshotListener { (snapShot, err) in
            
            if let err = err {
                print(err)
                return
                
            }
            
            if let snapShotDoc = snapShot?.documents {
                
                for doc in snapShotDoc {
                    
                    let data = doc.data()
                    let newDataSet = DataSet(dic: data)
                    
                    self.dataSets.append(newDataSet)
                    self.dataSets.reverse()
                    
                }
            }
        }
    }

        
        func loadHashTag(hashTag:String){
            
            db.collection("#\(hashTag)").order(by:"postDate").addSnapshotListener { (snapShot, error) in
                
                self.dataSets = []
                
                if error != nil {
                    print(error.debugDescription)
                    return
                }
                
                if let snapShotDoc = snapShot?.documents{
                    
                    for doc in snapShotDoc{
                        let data = doc.data()
                        
                        //                    if let uid = data["uid"] as? String, let username = data["username"] as? String, let contentText = data["contentText"] as? String, let profileImageUrl = data["profileImageUrl"] as? String, let contentImageUrl = data["contentImageUrl"] as? String, let postDate = data["postDate"] as? Double {
                        
                        let newDataSet = DataSet(dic: data)
                        
                        self.dataSets.append(newDataSet)
                        self.dataSets.reverse()
                        self.loadOKDelegate?.loadOK(check: 1)
                        
                    }
                }
            }
        }
    
}
