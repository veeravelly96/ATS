//
//  SplashViewController.swift
//  AttendanceSystem
//
//  Created by Student on 02/09/2022.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        perform(#selector(moveToView), with: nil, afterDelay: 3.0)
    }
    
    @objc func moveToView() -> Void {
        
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "InitialViewController") as! InitialViewController
        self.navigationController!.pushViewController(VC, animated: true)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}


extension UITextField {
    
    func setTextField() {
        let attributeString = [
            NSAttributedString.Key.foregroundColor: UIColor.darkGray,
            NSAttributedString.Key.font: self.font!
            ] as [NSAttributedString.Key : Any]
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder!, attributes: attributeString)
        self.textColor = UIColor.black
    }
    
}
