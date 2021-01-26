//
//  ToukouListCollectionViewCell.swift
//  InstagramApp
//
//  Created by 大谷空 on 2021/01/13.
//

import UIKit
import Nuke
import ActiveLabel
import FirebaseFirestore

class ToukouListCollectionViewCell: UICollectionViewCell {
    
    private var postDB = [PostDB]()
    private let db = Firestore.firestore()
    
    var post: PostDB? {
        didSet {
            
            if let edit = post {
                
                descriptionLabel.text = edit.contentText
                userNameLabel.text = edit.username
                userNameLabel2.text = edit.username
                dateLabel.text = dateFormatterForDateLabel(date: edit.createdAt.dateValue() ?? Date())
                countLabel.text = String(post?.likeCount ?? 0) + "いいね"
                
                if let url = URL(string: edit.contentImageUrl) {
                    Nuke.loadImage(with: url, into: toukouImageView)
                    
                    
                }
                
                if let url = URL(string: edit.profileImageUrl) {
                    Nuke.loadImage(with: url, into: userImageView)
                    
                }
            }
        }
    }
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userNameLabel2: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var toukouImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: ActiveLabel!
    @IBOutlet weak var goodButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .white
        userImageView.layer.cornerRadius = 12.5
    
    }
    
    private func dateFormatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}
