//
//  ViewController.swift
//  InstagramApp
//
//  Created by 大谷空 on 2021/01/05.
//

import UIKit

class HomeViewController: UIViewController {
    
    private let cellId = "cellId"
    
    @IBOutlet weak var toukouListCollectionView: UICollectionView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    private func setupViews() {
        
        toukouListCollectionView.delegate = self
        toukouListCollectionView.dataSource = self
        toukouListCollectionView.register(UINib(nibName: "ToukouListCell", bundle: nil), forCellWithReuseIdentifier: cellId)
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = self.view.frame.width
        
        return .init(width: width, height: width)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = toukouListCollectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ToukouListCollectionViewCell
        
        return cell
        
        
    }
}

