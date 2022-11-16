//
//  FacultyHomeVC.swift
//  AttendanceSystem
//
//  Created by Student on 12/09/2022.
//

import UIKit

class FacultyHomeVC: UIViewController {
    
    @IBOutlet var qrCodeBtn: UIButton!
    @IBOutlet var attendanceBtn: UIButton!
    @IBOutlet var resetPasswordBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Faculty"
        qrCodeBtn.RoundCorners(radius: 8)
        attendanceBtn.RoundCorners(radius: 8)
        resetPasswordBtn.RoundCorners(radius: 8)

    }
    
    
    @IBAction func qrCodeBtnTapped(_ sender: Any) {
        
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "FacultyCoursesVC") as! FacultyCoursesVC
        VC.source = .generateQRCode
        self.navigationController!.pushViewController(VC, animated: true)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    @IBAction func attendanceBtnTapped(_ sender: Any) {
        
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "FacultyCoursesVC") as! FacultyCoursesVC
        VC.source = .checkAttendance
        self.navigationController!.pushViewController(VC, animated: true)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    @IBAction func resetPasswordBtnTapped(_ sender: Any) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "ResetPasswordVC") as! ResetPasswordVC
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
