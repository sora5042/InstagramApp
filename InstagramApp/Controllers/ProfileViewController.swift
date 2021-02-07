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
import Pastel

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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        PastelAnimation()
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
