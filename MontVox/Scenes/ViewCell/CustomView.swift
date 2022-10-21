//
//  CustomView.swift
//  MontVox
//
//  Created by João Victor Ipirajá de Alencar on 13/10/22.
//

import Foundation
import UIKit


protocol ViewCodeProtocol {
    func addConstraint( ) -> ()
    func addSubviews() -> ()
}


class CustomView: UIStackView, ViewCodeProtocol {
    
    
    lazy var imageView =  make(UIImageView(frame: .zero)){
        $0.contentMode = .scaleAspectFit
        $0.translatesAutoresizingMaskIntoConstraints = false
     }
    
    lazy var labelView =  make(UILabel(frame: .zero)){
        $0.adjustsFontSizeToFitWidth = true
        $0.font = .systemFont(ofSize: 20, weight: .bold)
        $0.textAlignment = .center
        $0.lineBreakMode = .byWordWrapping
        $0.numberOfLines = 0
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    
    init() {
        
        super.init(frame: .zero)
        
        self.axis = .vertical
        self.alignment = .center
        self.distribution = .fill
        
        addSubviews()

    }
    

    
    func addConstraint() {
   
        
    }
    
    func addSubviews() {
        self.addArrangedSubview(imageView)
        self.addArrangedSubview(labelView)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
