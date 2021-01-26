//
//  LoginViewController.swift
//  InstagramApp
//
//  Created by 大谷空 on 2021/01/14.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import PKHUD

class SignUpViewController: UIViewController {
    

    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var alreadyHaveAccountButton: UIButton!
    @IBOutlet weak var signUpTopView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()

    }
    
   private func setupViews() {
    
    NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillShow(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillHide(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    profileImageButton.layer.cornerRadius = 100
    profileImageButton.layer.borderWidth = 1
    profileImageButton.layer.borderColor = UIColor.rgb(red: 240, green: 240, blue: 240).cgColor
    
    registerButton.layer.cornerRadius = 12
    
    profileImageButton.addTarget(self, action: #selector(tappedProfileImageButton), for: .touchUpInside)
    registerButton.addTarget(self, action: #selector(tappedRegisterButton), for: .touchUpInside)
    alreadyHaveAccountButton.addTarget(self, action: #selector(tappedAlreadyHaveAccountButton), for: .touchUpInside)
    
    emailTextField.delegate = self
    passwordTextField.delegate = self
    userNameTextField.delegate = self
    
    registerButton.isEnabled = false
    registerButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
    
    signUpTopView.layer.borderWidth = 3
    signUpTopView.layer.borderColor = UIColor.rgb(red: 220, green: 220, blue: 220).cgColor
        
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
    
    @objc private func tappedAlreadyHaveAccountButton() {
        
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        loginViewController.modalPresentationStyle = .fullScreen
        self.present(loginViewController, animated: true, completion: nil)

    }
    
    @objc private func tappedProfileImageButton() {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc private func tappedRegisterButton() {
        
        guard let image = profileImageButton.imageView?.image else { return }
        guard let uploadImage = image.jpegData(compressionQuality: 0.3) else { return }
        
        HUD.show(.progress)
        
        let fileName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_image").child(fileName)
        
        storageRef.putData(uploadImage, metadata: nil) { (matadata, err) in
            
            if let err = err {
                
                print("Firestorageへの情報の保存に失敗しました。\(err)")
                HUD.hide()
                return
            }
            
            print("Firestorageへの情報の保存に成功しました。")
            storageRef.downloadURL { (url, err) in
                
                if let err = err {
                    
                    print("Firestorageからのダウンロードに失敗しました。\(err)")
                    HUD.hide()
                    return
                    
                }
                
                guard let urlString = url?.absoluteString else { return }
                self.creatUserToFirebase(profileImageUrl: urlString)
                
            }
        }
    }
    
    private func creatUserToFirebase(profileImageUrl: String) {
        
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
            
            if let err = err {
                print("認証情報の保存に失敗しました。\(err)")
                HUD.hide()
                return
            }
            
            print("認証情報の保存に成功しました。")
            
            guard let uid = res?.user.uid else { return }
            guard let username = self.userNameTextField.text else { return }
            let docData = [
                "email": email,
                "username": username,
                "createdAt": Timestamp(),
                "profileImageUrl": profileImageUrl
            ] as [String : Any]
            
            Firestore.firestore().collection("users").document(uid).setData(docData) { (err) in
                if let err = err {
                    print("Firestoreへの保存に失敗しました。\(err)")
                    HUD.hide()
                    return
                    
                }
                print("Firestoreへの保存に成功しました。")
                HUD.hide()
                
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
        
    }
}

extension SignUpViewController: UITextFieldDelegate {
    
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        let emailIsEmpty = emailTextField.text?.isEmpty ?? false
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? false
        let usernameIsEmpty = userNameTextField.text?.isEmpty ?? false
        
        if emailIsEmpty || passwordIsEmpty || usernameIsEmpty {
            registerButton.isEnabled = false
            registerButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
            
        } else {
            registerButton.isEnabled = true
            registerButton.backgroundColor = .rgb(red: 103, green: 219, blue: 88)
            
        }
    }
}

extension SignUpViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editImage = info[.editedImage] as? UIImage {
            profileImageButton.setImage(editImage.withRenderingMode(.alwaysOriginal), for: .normal)
            
        }else if let originalImage = info[.originalImage] as? UIImage {
            profileImageButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        profileImageButton.setTitle("", for: .normal)
        profileImageButton.imageView?.contentMode = .scaleAspectFill
        profileImageButton.contentHorizontalAlignment = .fill
        profileImageButton.contentVerticalAlignment = .fill
        profileImageButton.clipsToBounds = true
        
        dismiss(animated: true, completion: nil)
        
    }
}
