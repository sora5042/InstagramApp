//
//  HashTagViewController.swift
//  InstagramApp
//
//  Created by 大谷空 on 2021/01/22.
//

import UIKit
import Firebase
import FirebaseFirestore
import Nuke

class HashTagViewController: UIViewController {
    
    private let cellId = "cellId"
    private var hashTagDB = [HashTagDB]()
    var hashTag = String()
    private let db = Firestore.firestore()

    @IBOutlet weak var hashTagLabel: UILabel!
    @IBOutlet weak var hashTagTopView: UIView!
    @IBOutlet weak var hashTagCollectionView: UICollectionView!
    @IBOutlet weak var hashTagTopImageView: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var countLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        loadHashTag(hashTag: hashTag)


    }
    
    private func setupViews() {
        
        hashTagCollectionView.delegate = self
        hashTagCollectionView.dataSource = self
                
        hashTagTopView.layer.borderWidth = 3
        hashTagTopView.layer.borderColor = UIColor.rgb(red: 220, green: 220, blue: 220).cgColor
        
        hashTagTopImageView.layer.cornerRadius = 40
        
        backButton.addTarget(self, action: #selector(tappedBackButton), for: .touchUpInside)
        
        hashTagLabel.text = "#\(hashTag)"
        
    }

    private func loadHashTag(hashTag:String){
        
        db.collection("#\(hashTag)").order(by:"postDate").addSnapshotListener { (snapShot, err) in
            
            if let err = err {
                print("Firestoreからの情報の取得に失敗しました。\(err)")
                return
            }
            
            if let snapShotDoc = snapShot?.documents {
                
                for doc in snapShotDoc{
                    let dic = doc.data()
                    
                    let newHashTagDB = HashTagDB(dic: dic)
                    
                    self.hashTagDB.append(newHashTagDB)
                    self.hashTagDB.reverse()
                    self.hashTagCollectionView.reloadData()
                    
                }
            }
        }
    }
    
    @objc private func tappedBackButton() {
        
        dismiss(animated: true, completion: nil)
        
    }
}


extension HashTagViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        countLabel.text = String(hashTagDB.count)

        return hashTagDB.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = hashTagCollectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
        
        let contentImageView = cell.contentView.viewWithTag(1) as! UIImageView
        if let url = URL(string: hashTagDB[indexPath.row].contentImageUrl) {
            Nuke.loadImage(with: url, into: contentImageView)
        }
        
        if let url = URL(string: hashTagDB[0].contentImageUrl) {
            Nuke.loadImage(with: url, into: hashTagTopImageView)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Detail", bundle: nil)
        let detailViewController = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        
        detailViewController.username = hashTagDB[indexPath.row].username
        detailViewController.profileImageUrl = hashTagDB[indexPath.row].profileImageUrl
        detailViewController.contentImageUrl = hashTagDB[indexPath.row].contentImageUrl
        detailViewController.contentText = hashTagDB[indexPath.row].contentText
        
        self.present(detailViewController, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
           let width = collectionView.bounds.width/3.0
           let height = width

           return CGSize(width: width, height: height)
       }
       
       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
           return UIEdgeInsets.zero
       }

       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
           return 0
       }

       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
           return 0
       }
}
