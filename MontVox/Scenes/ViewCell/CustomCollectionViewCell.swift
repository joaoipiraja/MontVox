//
//  CustomCollectionViewCell.swift
//  MontVox
//
//  Created by João Victor Ipirajá de Alencar on 11/10/22.
//

import Foundation
import UIKit

class CustomCollectionViewCell: UICollectionViewCell, ViewCodeProtocol{
    
    
    static let identifier: String = "CustomCollectionViewCell"
    
    func addConstraint() {
        NSLayoutConstraint.activate([
      
            
            self.customView.topAnchor.constraint(equalTo: self.topAnchor),
            self.customView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.customView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.customView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
        ])
    }
    
    func addSubviews() {
        self.addSubview(customView)
    }
    

    
    let customView: CustomView = {
        let view = CustomView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect){
        
        super.init(frame: frame)
        
        self.backgroundColor = .white
        self.layer.cornerRadius = 10
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 2
        
        self.addSubviews()
        self.addConstraint()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
}
