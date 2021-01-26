//
//  LoginViewController.swift
//  InstagramApp
//
//  Created by 大谷空 on 2021/01/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import PKHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var loginTopView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var dontHaveAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
            
    }
    
    private func setupViews() {
        
        loginButton.layer.cornerRadius = 12
        loginTopView.layer.borderWidth = 3
        loginTopView.layer.borderColor = UIColor.rgb(red: 220, green: 220, blue: 220).cgColor
        
        dontHaveAccountButton.addTarget(self, action: #selector(tappedDontHaveAccountButton), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(tappedLoginButton), for: .touchUpInside)
        
    }
    
    @objc private func tappedDontHaveAccountButton() {
        
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        let signUpViewController = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        signUpViewController.modalPresentationStyle = .fullScreen
        self.present(signUpViewController, animated: true, completion: nil)
        
    }
    
    @objc private func tappedLoginButton() {
        
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        HUD.show(.progress)
        
        Auth.auth().signIn(withEmail: email, password: password) { (res, err) in
            
            if let err = err {
                print("ログインに失敗しました。\(err)")
                HUD.hide()
                return
                
            }
            
            print("ログインに成功しました。")
            HUD.hide()
            let storyboard = UIStoryboard(name: "BaseTabBar", bundle: nil)
            let baseTabBarViewController = storyboard.instantiateViewController(withIdentifier: "BaseTabBarViewController") as! BaseTabBarViewController
            baseTabBarViewController.modalPresentationStyle = .fullScreen
            self.present(baseTabBarViewController, animated: true, completion: nil)
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
        
    }
}
