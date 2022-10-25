//
//  StudentHomeVC.swift
//  AttendanceSystem
//
//  Created by Student on 12/09/2022.
//

import UIKit

class StudentHomeVC: UIViewController {
    
    
    @IBOutlet var markBtn: UIButton!
    @IBOutlet var checkBtn: UIButton!
    @IBOutlet var resetPasswordBtn: UIButton!

    var selecetdSubject: SubjectModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Student"
        markBtn.RoundCorners(radius: 8)
        checkBtn.RoundCorners(radius: 8)
        resetPasswordBtn.RoundCorners(radius: 8)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func markAttendanceBtnTapped(_ sender: Any) {
        
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "FacultyCoursesVC") as! FacultyCoursesVC
        VC.source = .scanQRCode
        self.navigationController!.pushViewController(VC, animated: true)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    @IBAction func checkAttendanceBtnTapped(_ sender: Any) {
        
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
