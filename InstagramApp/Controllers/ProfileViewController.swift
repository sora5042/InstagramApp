//
//  ProfileViewController.swift
//  InstagramApp
//
//  Created by 大谷空 on 2021/01/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import Nuke

class ProfileViewController: UIViewController {
    
    var user: User? {
        didSet {

            if let user = user {

                usernameLabel.text = user.username

                if let url = URL(string: user.profileImageUrl ) {
                    Nuke.loadImage(with: url, into: profileImageView)

                }
            }
        }
    }

    @IBOutlet weak var profileTopView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        fetchLoginUserInfo()

    }
    
    private func setupViews() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileViewController.keyboardWillShow(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileViewController.keyboardWillHide(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        profileTopView.layer.borderWidth = 3
        profileTopView.layer.borderColor = UIColor.rgb(red: 220, green: 220, blue: 220).cgColor
        
        profileImageView.layer.cornerRadius = 75
        
        logoutButton.layer.cornerRadius = 12
        logoutButton.addTarget(self, action: #selector(tappedLogoutButton), for: .touchUpInside)
        
    }
    
    @objc func keyboardWillShow(_ notification:NSNotification){
        
        if self.view.frame.origin.y == 0 {
            
            self.view.frame.origin.y -= 200
            
        } else {
            
            return
            
        }
    }
    
    @objc func keyboardWillHide(_ notification:NSNotification){
        
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
        
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else{ return }
        
        UIView.animate(withDuration: duration) {
            let transform = CGAffineTransform(translationX: 0, y: 0)
            self.view.transform = transform
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
        
    }
    
    @objc private func tappedLogoutButton() {
        
        do {
            
            try Auth.auth().signOut()
            let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
            let signUpViewController = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
            signUpViewController.modalPresentationStyle = .fullScreen
            self.present(signUpViewController, animated: true, completion: nil)
            
        } catch  {
            
            print("ログアウトに失敗しました。\(error)")
            
        }
    }
    
    private func fetchLoginUserInfo() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(uid).getDocument { (snapShot, err) in
            
            if let err = err {
                print("ユーザー情報の取得に失敗しました。\(err)")
                return
            }
            
            guard let snapShot = snapShot, let dic = snapShot.data() else { return }
            let user = User(dic: dic)
            self.user = user
            
        }
    }
}
