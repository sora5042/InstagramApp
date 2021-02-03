//
//  DetailViewController.swift
//  InstagramApp
//
//  Created by 大谷空 on 2021/01/22.
//

import UIKit
import Nuke

class DetailViewController: UIViewController {
    
    var username = String()
    var profileImageUrl = String()
    var contentImageUrl = String()
    var contentText = String()
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
    }
    
    private func setupView() {
        
        userImageView.layer.cornerRadius = 50
        usernameLabel.text = username
        descriptionLabel.text = contentText
        
        if let url = URL(string: profileImageUrl) {
            Nuke.loadImage(with: url, into: userImageView)
            
        }
        
        if let url = URL(string: contentImageUrl) {
            Nuke.loadImage(with: url, into: contentImageView)
            
        }
    }
}
