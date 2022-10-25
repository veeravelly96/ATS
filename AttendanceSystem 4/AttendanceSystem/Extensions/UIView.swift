//
//  UIView.swift
//  AttendanceSystem
//
//  Created by Student on 02/09/2022.
//

import Foundation
import UIKit

extension UIView {
    
    func RoundCorners(radius: Int) -> Void {
        
        self.layer.cornerRadius = CGFloat(radius)
        self.clipsToBounds = true
    }
}
