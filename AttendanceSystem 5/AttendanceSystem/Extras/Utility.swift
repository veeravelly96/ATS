//
//  Utility.swift
//  AttendanceSystem
//
//  Created by by Student on 15/09/2022.
//

import Foundation
import UIKit


class Utility {
            
    static let APP_DELEGATE = UIApplication.shared.connectedScenes.first!.delegate as! SceneDelegate
    
    static func topViewController(base: UIViewController? = (APP_DELEGATE).window?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
    
    
    static func showAlert(title:String?, message:String?, buttonTitle: String? = "Ok") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString(buttonTitle!, comment: ""), style: .default) { _ in
            //Update status bar style
            Utility.topViewController()!.setNeedsStatusBarAppearanceUpdate()
        })
        
        alert.modalPresentationCapturesStatusBarAppearance = true
        Utility.topViewController()!.present(alert, animated: true){}
    }
    
    static func showAlert(title:String?, message:String?, buttonTitle: String? = "Ok", okTapped:@escaping ()->()) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString(buttonTitle!, comment: ""), style: .default) { _ in
            okTapped()
        })
        alert.modalPresentationCapturesStatusBarAppearance = true
        Utility.topViewController()!.present(alert, animated: true){}
    }
    
    static func showAlert(title:String?, message:String?, button1Title: String? = "No", noTapped:@escaping ()->(),  button2Title: String? = "Yes", yesTapped:@escaping ()->()) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString(button1Title!, comment: ""), style: .destructive) { _ in
            noTapped()
        })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString(button2Title!, comment: ""), style: .default) { _ in
            yesTapped()
        })
        
        alert.modalPresentationCapturesStatusBarAppearance = true
        Utility.topViewController()!.present(alert, animated: true){}
    }
    
    static func showAlert(title:String?, message:String?, button1Title: String? = "No", noTapped:@escaping ()->(),  button2Title: String? = "Yes", yesTapped:@escaping ()->(),  button3Title: String? = "Cancel", cancelTapped:@escaping ()->()) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString(button1Title!, comment: ""), style: .default) { _ in
            noTapped()
        })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString(button2Title!, comment: ""), style: .default) { _ in
            yesTapped()
        })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString(button3Title!, comment: ""), style: .default) { _ in
            cancelTapped()
        })
        
        alert.modalPresentationCapturesStatusBarAppearance = true
        Utility.topViewController()!.present(alert, animated: true){}
    }
    
   
    static func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }

}

