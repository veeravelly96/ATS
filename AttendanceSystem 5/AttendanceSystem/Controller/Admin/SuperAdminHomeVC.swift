//
//  SuperAdminHomeVC.swift
//  AttendanceSystem
//
//  Created by Student on 21/10/2022.
//

import UIKit

class SuperAdminHomeVC: UIViewController {
    
    @IBOutlet var facultyBtn: UIButton!
    @IBOutlet var studentsBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Super Admin"
        facultyBtn.RoundCorners(radius: 8)
        studentsBtn.RoundCorners(radius: 8)
    }
    
    
    @IBAction func facultyBtnTapped(_ sender: Any) {
        
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "ListViewController") as! ListViewController
        VC.userType = .Faculty
        self.navigationController!.pushViewController(VC, animated: true)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    @IBAction func studentsBtnTapped(_ sender: Any) {
        
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "ListViewController") as! ListViewController
        VC.userType = .Student
        self.navigationController!.pushViewController(VC, animated: true)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    @IBAction func logoutBtnTapped(_ sender: Any) {
        
        let alert = UIAlertController(title: "", message: "Are you sure you want to logout?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "No", style: .default, handler: { action in
            
        })
        alert.addAction(ok)
        let cancel = UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.logout()
            
        })
        alert.addAction(cancel)
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
    }
    
    func logout() {
        
        AppStateManager.shared.markUserLogout()

        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "InitialViewController") as? InitialViewController
        let window = UIApplication.shared.windows.first

        // Embed loginVC in Navigation Controller and assign the Navigation Controller as windows root
        let nav = UINavigationController(rootViewController: loginVC!)
        window?.rootViewController = nav
    }
    
}


