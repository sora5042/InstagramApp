//
//  ViewController.swift
//  InstagramApp
//
//  Created by 大谷空 on 2021/01/05.
//

import UIKit
import Firebase
import FirebaseFirestore
import Pastel

class HomeViewController: UIViewController {
    
    private let cellId = "cellId"
    private var postDB = [PostDB]()
    private var postdb: PostDB?
    private let db = Firestore.firestore()
    
    @IBOutlet weak var toukouListCollectionView: UICollectionView!
    @IBOutlet weak var homeTopView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        fetchPostInfoFromFirestore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        PastelAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        if Auth.auth().currentUser?.uid == nil {
            
            let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
            let signUpViewController = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
            signUpViewController.modalPresentationStyle = .fullScreen
            self.present(signUpViewController, animated: true, completion: nil)
        }
    }
    
    private func setupViews() {
        
        toukouListCollectionView.delegate = self
        toukouListCollectionView.dataSource = self
        toukouListCollectionView.register(UINib(nibName: "ToukouListCell", bundle: nil), forCellWithReuseIdentifier: cellId)
    }
    
    private func fetchPostInfoFromFirestore() {
        
        Firestore.firestore().collection("post").getDocuments { (snapShots, err) in
            
            if let err = err {
                print("post情報の取得に失敗しました。\(err)")
                return
                
            }
            
            snapShots?.documents.forEach({ (snapShot) in
                
                let dic = snapShot.data()
                let post = PostDB.init(dic: dic)
                
                self.postDB.append(post)
                self.postDB.sort { (e1, e2) -> Bool in
                    let e1Date = e1.createdAt.dateValue()
                    let e2Date = e2.createdAt.dateValue()
                    return e1Date > e2Date
                }
                
                self.toukouListCollectionView.reloadData()
            })
        }
    }
    
    private func PastelAnimation() {
        
        let pastelView = PastelView(frame: view.bounds)
        
        pastelView.startPastelPoint = .bottomLeft
        pastelView.endPastelPoint = .topRight
        
        pastelView.animationDuration = 3.0
        
        pastelView.setColors([UIColor(red: 156/255, green: 39/255, blue: 176/255, alpha: 1.0),
                              UIColor(red: 255/255, green: 64/255, blue: 129/255, alpha: 1.0),
                              UIColor(red: 123/255, green: 31/255, blue: 162/255, alpha: 1.0),
                              UIColor(red: 32/255, green: 76/255, blue: 255/255, alpha: 1.0),
                              UIColor(red: 32/255, green: 158/255, blue: 255/255, alpha: 1.0),
                              UIColor(red: 90/255, green: 120/255, blue: 127/255, alpha: 1.0),
                              UIColor(red: 58/255, green: 255/255, blue: 217/255, alpha: 1.0)])
        
        pastelView.startAnimation()
        view.insertSubview(pastelView, at: 0)
    }
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = self.view.frame.width
        
        return .init(width: width, height: 550)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postDB.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = toukouListCollectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ToukouListCollectionViewCell
        cell.post = postDB[indexPath.row]
        cell.goodButton.tag = indexPath.row
        cell.goodButton.addTarget(self, action: #selector(tappedGoodButton(_:)), for: .touchUpInside)
        
        
        let uid = postDB[indexPath.row].uid
        
        if (self.postDB[indexPath.row].likeFlagDic[uid] != nil) == true {
            
            let flag = self.postDB[indexPath.row].likeFlagDic[uid]
            
            if flag! == true {
                
                cell.goodButton.setImage(UIImage(named: "ハート"), for: .normal)
                
            } else if flag! == false {
                
                cell.goodButton.setImage(UIImage(named: "noハート"), for: .normal)
            }
        }
        
        cell.descriptionLabel.enabledTypes = [.hashtag]
        cell.descriptionLabel.handleHashtagTap { (hashTag) in
            
            let storyboard = UIStoryboard(name: "HashTag", bundle: nil)
            let hashTagViewController = storyboard.instantiateViewController(withIdentifier: "HashTagViewController") as! HashTagViewController
            hashTagViewController.modalTransitionStyle = .crossDissolve
            hashTagViewController.modalPresentationStyle = .fullScreen
            hashTagViewController.hashTag = hashTag
            self.present(hashTagViewController, animated: true, completion: nil)
        }
        
        return cell
    }
    
    @objc func tappedGoodButton(_ sender: UIButton) {
        
        let uid = postDB[sender.tag].uid
        var count = Int()
        let flag = self.postDB[sender.tag].likeFlagDic[uid]
        
        if flag == nil {
            
            count = self.postDB[sender.tag].likeCount + 1
            db.collection("post").document(postDB[sender.tag].postId).setData(["likeFlagDic": [uid: true]], merge: true)
            
        } else {
            
            if flag == true {
                
                count = self.postDB[sender.tag].likeCount - 1
                db.collection("post").document(postDB[sender.tag].postId).setData(["likeFlagDic": [uid: false]], merge: true)
                
            } else {
                
                if flag == false {
                    
                    count = self.postDB[sender.tag].likeCount + 1
                    db.collection("post").document(postDB[sender.tag].postId).setData(["likeFlagDic": [uid: true]], merge: true)
                }
            }
        }
        
        db.collection("post").document(postDB[sender.tag].postId).updateData(["likeCount": count], completion: nil)
        toukouListCollectionView.reloadData()
    }
}
