//
//  ToukouViewController.swift
//  InstagramApp
//
//  Created by 大谷空 on 2021/01/14.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Nuke

class PostViewController: UIViewController {
    
    private let screenSize = UIScreen.main.bounds.size
    private var postDB: PostDB?
    private var users = [User]()
    private let db = Firestore.firestore()
    
    var user: User? {
        didSet {
            
            if let user = user {
                
                usernameLabel.text = user.username
                
                if let url = URL(string: user.profileImageUrl ) {
                    Nuke.loadImage(with: url, into: userImageView)
                    
                }
            }
        }
    }
    
    @IBOutlet weak var editUsernameLabel: UILabel!
    @IBOutlet weak var contentTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var contentImageButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var editTopView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        fetchLoginUserInfo()
    }
    
    
    private func setupViews() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(PostViewController.keyboardWillShow(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PostViewController.keyboardWillHide(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        editTopView.layer.borderWidth = 3
        editTopView.layer.borderColor = UIColor.rgb(red: 220, green: 220, blue: 220).cgColor
        contentImageButton.layer.borderWidth = 2
        contentImageButton.layer.borderColor = UIColor.rgb(red: 240, green: 240, blue: 240).cgColor
        contentImageButton.addTarget(self, action: #selector(tappedContentImageButton), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(tappedSendButton), for: .touchUpInside)
        
        userImageView.layer.cornerRadius = 25
        
    }
    
    @objc func keyboardWillShow(_ notification:NSNotification){
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            } else {
                let suggestionHeight = self.view.frame.origin.y + keyboardSize.height
                self.view.frame.origin.y -= suggestionHeight
            }
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
    
    @objc private func tappedSendButton() {
        
        guard let contentImage = contentImageButton.imageView?.image else { return }
        guard let uploadContentImage = contentImage.jpegData(compressionQuality: 0.3) else { return }
        
        let fileName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("post_image").child(fileName)
        
        storageRef.putData(uploadContentImage, metadata: nil) { (metaData, err) in
            
            if let err = err {
                print("Firestorageへの情報の保存に失敗しました\(err)")
                return
                
            }
            storageRef.downloadURL { (url, err) in
                
                if let err = err {
                    print("Firestorageからのダウンロードに失敗しました。\(err)")
                    return
                    
                }
                
                guard let urlString = url?.absoluteString else { return }
                self.creatPostFromFirestore(contentImageUrl: urlString)
                
                let storyboard = UIStoryboard(name: "BaseTabBar", bundle: nil)
                let baseTabBarViewController = storyboard.instantiateViewController(withIdentifier: "BaseTabBarViewController") as! BaseTabBarViewController
                baseTabBarViewController.modalPresentationStyle = .fullScreen
                
                self.present(baseTabBarViewController, animated: true, completion: nil)
                
            }
        }
    }
    
    private func creatPostFromFirestore(contentImageUrl: String) {
        
        guard let contentText = contentTextField.text else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let profileImageUrl = user?.profileImageUrl  else { return }
        guard let username = user?.username else { return }
        
        searchHashTag()
        
        let postId = randomString(length: 20)
        
        let docData = [
            
            "contentText": contentText,
            "createdAt": Timestamp(),
            "postDate": Date().timeIntervalSince1970,
            "contentImageUrl": contentImageUrl,
            "uid": uid,
            "username": username,
            "profileImageUrl": profileImageUrl,
            "likeCount": 0,
            "likeFlagDic": [uid: Bool()],
            "postId": postId
            
        ] as [String : Any]
        
        db.collection("post").document(postId).setData(docData) { (err) in
            
            if let err = err {
                print("Firestoreへの情報の保存に失敗しました。\(err)")
                return
                
            }
        }
    }
    
    private func fetchLoginUserInfo() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid).getDocument { (snapShot, err) in
            
            if let err = err {
                print("ユーザー情報の取得に失敗しました。\(err)")
                return
            }
            guard let snapShot = snapShot, let dic = snapShot.data() else { return }
            
            let user = User(dic: dic)
            self.user = user
        }
    }
    
    @objc private func tappedContentImageButton() {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func searchHashTag(){
        
        guard let hashTagText = contentTextField.text as NSString? else { return }
        do{
            let regex = try NSRegularExpression(pattern: "#\\S+", options: [])
            for match in regex.matches(in: hashTagText as String, options: [], range: NSRange(location: 0, length: hashTagText.length)) {
                
                self.sendHashTag(hashTag: hashTagText.substring(with: match.range))
            }
        } catch {
            
        }
    }

    private func sendHashTag(hashTag: String) {
        
        guard let contentImage = contentImageButton.imageView?.image else { return }
        guard let uploadContentImage = contentImage.jpegData(compressionQuality: 0.3) else { return }
        let fileName = NSUUID().uuidString
        
        let imageRef = Storage.storage().reference().child(hashTag).child(fileName)
        imageRef.putData(uploadContentImage, metadata: nil, completion: { (metadata, err) in
            
            if let err = err {
                print(err)
                return
            }
            
            
            imageRef.downloadURL(completion: { (url, err) in
                if let err = err {
                    print(err)
                    return
                }
                
                guard let urlString = url?.absoluteString else { return }
                self.creatHashTagFromFirestore(hashTag: hashTag, contentImageUrl: urlString)
                
            })
        })
    }
    
    private func creatHashTagFromFirestore(hashTag:String, contentImageUrl: String) {
        
        guard let contentText = contentTextField.text else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let profileImageUrl = user?.profileImageUrl  else { return }
        guard let username = user?.username else { return }
        
        let postId = randomString(length: 20)
        
        let docData = [
            
            "contentText": contentText,
            "createdAt": Timestamp(),
            "postDate": Date().timeIntervalSince1970,
            "contentImageUrl": contentImageUrl,
            "uid": uid,
            "username": username,
            "profileImageUrl": profileImageUrl,
            "likeCount": 0,
            "likeFlagDic": [uid: Bool()],
            "postId": postId
            
        ] as [String : Any]
        
        db.collection(hashTag).document(postId).setData(docData) { (err) in
            
            if let err = err {
                print("Firestoreへの情報の保存に失敗しました。\(err)")
                return
                
            }
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        contentTextField.resignFirstResponder()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
        
    }
    
    func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
}

extension PostViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editImage = info[.editedImage] as? UIImage {
            contentImageButton.setImage(editImage.withRenderingMode(.alwaysOriginal), for: .normal)
            
        } else if let originalImage = info[.originalImage] as? UIImage {
            contentImageButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        contentImageButton.setTitle("", for: .normal)
        contentImageButton.imageView?.contentMode = .scaleAspectFill
        contentImageButton.contentHorizontalAlignment = .fill
        contentImageButton.contentVerticalAlignment = .fill
        contentImageButton.clipsToBounds = true
        
        dismiss(animated: true, completion: nil)
    }
}