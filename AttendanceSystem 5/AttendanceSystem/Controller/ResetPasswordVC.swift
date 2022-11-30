//
//  ResetPasswordVC.swift
//  AttendanceSystem
//
//  Created by Student on 22/10/2022.
//

import UIKit
import FirebaseDatabase

class ResetPasswordVC: UIViewController {
    
    
    @IBOutlet weak var currentPasswordTF: UITextField!
    @IBOutlet weak var newPasswordTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    
    @IBOutlet weak var resetBtn: UIButton!
    
    var userType: UserRole = AppStateManager.shared.userRole
    
    private let ref = Database.database().reference()
    private let dbPath = AppStateManager.shared.userRole == .Student ? "student" : AppStateManager.shared.userRole == .Faculty ? "faculty" : "admin"
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        if userType == .Student {
            
            self.navigationItem.title = "Student"
        }
        else if userType == .Faculty {
            
            self.navigationItem.title = "Faculty"
        }
        
        self.navigationController?.navigationBar.isHidden = false
        
        currentPasswordTF.setTextField()
        newPasswordTF.setTextField()
        confirmPasswordTF.setTextField()
        
        resetBtn.RoundCorners(radius: 8)
    }
    
    
    @IBAction func resetBtnClicked(_ sender: Any) {
        
        validateData()
    }
    
    func validateData() {
        
        var shouldProceed = true
        var message = ""
        
        if (currentPasswordTF.text?.isEmpty)! {
            shouldProceed = false
            message = "Please enter your current password"
        }else if (newPasswordTF.text?.isEmpty)! {
            shouldProceed = false
            message = "Please enter your new password"
        }else if (confirmPasswordTF.text?.isEmpty)! {
            shouldProceed = false
            message = "Please re-enter your new password"
        }else if (newPasswordTF.text != confirmPasswordTF.text) {
            shouldProceed = false
            message = "Password not matched"
        }else {
            
            if userType == .Faculty, currentPasswordTF.text != AppStateManager.shared.loggedInUser?.faculty?.password {
                shouldProceed = false
                message = "Current password not correct"
            }
            else if userType == .Student, currentPasswordTF.text != AppStateManager.shared.loggedInUser?.student?.password {
                shouldProceed = false
                message = "Current password not correct"
            }
        }
        
        
        if shouldProceed {
            
            if userType == .Student {
                resetStudentPassword()
            }
            else if userType == .Faculty {
                resetFacultyPassword()
            }
        }
        else {
            Utility.showAlert(title: "Error", message: message)
        }
    }
    
    func resetStudentPassword() {
        
        var student = AppStateManager.shared.loggedInUser?.student
        
        student?.password = newPasswordTF.text!
        
        AppStateManager.shared.loggedInUser?.student = student
        
        ref.child("\(dbPath)/\(AppStateManager.shared.getStudentId())").updateChildValues(["password": newPasswordTF.text!])
        
        Utility.showAlert(title: "Alert", message: "Password reset successfully", okTapped: {
            self.navigationController?.popViewController(animated: true)
        })
        
    }
    
    
    func resetFacultyPassword() {
        
        var faculty = AppStateManager.shared.loggedInUser?.faculty
        
        faculty?.password = newPasswordTF.text!
        
        AppStateManager.shared.loggedInUser?.faculty = faculty
        
        ref.child("\(dbPath)/\(AppStateManager.shared.getFacultyId())").updateChildValues(["password": newPasswordTF.text!])
        
        Utility.showAlert(title: "Alert", message: "Password reset successfully", okTapped: {
            self.navigationController?.popViewController(animated: true)
        })
        
    }
    
}

