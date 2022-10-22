//
//  Utils.swift
//  MontVox
//
//  Created by João Victor Ipirajá de Alencar on 22/10/22.
//

import Foundation
import UIKit

func make<T: UIView>(_ uiView: T, _ configure: (T) -> Void) -> T {
    configure(uiView)
    return uiView
}
