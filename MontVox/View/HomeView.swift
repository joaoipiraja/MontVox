//
//  HomeView.swift
//  MontVox
//
//  Created by João Victor Ipirajá de Alencar on 18/10/22.
//

import Foundation
import UIKit


protocol HomeViewDelegate: AnyObject{
    func loadImage(on cell: CustomCollectionViewCell?, byId id: Int?) -> ()
}
protocol HomeViewDataSource: AnyObject{
    func getArrayCount() -> Int
    func getCurrentObjectString(indexPath: IndexPath) -> String
    func getCurrentObject(indexPath: IndexPath) -> Pictogram
}


final class HomeView: UIView{
    
    weak var delegate: HomeViewDelegate?
    weak var dataSource: HomeViewDataSource?
  
    lazy var titleTextView = make(UITextView()){
        $0.backgroundColor = UIColor.lightGray
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.keyboardType = UIKeyboardType.default
        $0.returnKeyType = UIReturnKeyType.done
        $0.autocorrectionType = UITextAutocorrectionType.no
        $0.sizeToFit()
    }
    
    
    lazy var collectionView =  make( UICollectionView(frame: .zero, collectionViewLayout: .init())) {

        $0.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: CustomCollectionViewCell.identifier)
        
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(
            top: 20, left: 20, bottom: 0, right: 20)
        layout.minimumInteritemSpacing = 1
        
    
        $0.setCollectionViewLayout(layout, animated: true)
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        backgroundColor = .systemBackground
        
        self.addSubViews()
        self.addConstraints()
        
        let width = self.frame.size.width

        if width <= 393{
            self.titleTextView.font = UIFont.systemFont(ofSize: 20)
        }else{
            self.titleTextView.font = UIFont.systemFont(ofSize: 30)
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    
    func addSubViews(){
        self.addSubview(titleTextView)
        self.addSubview(collectionView)
    }
    
    func addConstraints(){
        NSLayoutConstraint.activate([

            titleTextView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            titleTextView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 10),
            titleTextView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -10),


            collectionView.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.85),
            collectionView.topAnchor.constraint(equalTo: titleTextView.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),

        ])
    }
}

extension HomeView: UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView,
      didSelectItemAt indexPath: IndexPath) {
        
        if let textinput = dataSource?.getCurrentObjectString(indexPath: indexPath){
            if let _ = self.titleTextView.text {
                self.titleTextView.text! += " " + textinput
            }else{
                self.titleTextView.text = textinput
            }
        }
        
      }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.getArrayCount() ?? 0
    }
    
}


extension HomeView:  UICollectionViewDelegateFlowLayout, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let object = self.dataSource?.getCurrentObject(indexPath: indexPath)
        
        let cell  = self.collectionView.dequeueReusableCell(withReuseIdentifier: CustomCollectionViewCell.identifier, for: indexPath) as? CustomCollectionViewCell
        
        cell?.customView.labelView.text = object?.keywords.first?.keyword
        
        self.delegate?.loadImage(on: cell, byId: object?.id)
            
        
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        var dimension = 0
        
        let width = self.collectionView.frame.size.width

        if width <= 393{
            dimension = 110
        }else{
            dimension = 140
        }
        
        let size = CGSize(width: dimension, height: dimension)
        return size

    }
}
