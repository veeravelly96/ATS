//
//  LoginViewController.swift
//  AttendanceSystem
//
//  Created by Student on 02/09/2022.
//

import UIKit
import FirebaseDatabase

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    @IBOutlet weak var loginBtn: UIButton!
    
    var userType: UserRole = .Student
    
    private lazy var databasePath: DatabaseReference? = {
        let ref = Database.database()
            .reference()
            .child(userType == .Student ? "student" : userType == .Faculty ? "faculty" : "admin")
        return ref
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Super Admin"
        
        if userType == .Student {
            
            self.navigationItem.title = "Student"
        }
        else if userType == .Faculty {
            
            self.navigationItem.title = "Faculty"
        }
        
        self.navigationController?.navigationBar.isHidden = false

        emailTF.setTextField()
        passwordTF.setTextField()
        loginBtn.RoundCorners(radius: 8)
    }
    
    
    @IBAction func loginBtnClicked(_ sender: Any) {
        
        validateData()
    }
    
    func validateData() {
        
        var shouldProceed = true
        var message = ""
        
        if (emailTF.text?.isEmpty)! {
            shouldProceed = false
            message = "Please enter your email address"
        }else if !Utility.isValidEmail(testStr: emailTF.text!){
            shouldProceed = false
            message = "Please provide valid email address"
        }else if !isValid(emailTF.text!) {
            shouldProceed = false
            message = "Please provide valid email address"
        }else if (passwordTF.text?.isEmpty)! {
            shouldProceed = false
            message = "Please enter your password"
        }
        
        if shouldProceed {
            
            if userType == .Student {
                authenticateStudent()
            }
            else if userType == .Faculty {
                authenticateFaculty()
            }
            else {
                authenticateSuperAdmin()
            }
        }
        else {
            Utility.showAlert(title: "Error", message: message)
        }
    }
    
    func isValid(_ email: String) -> Bool {
        
        if userType == .Student {
            
            let emailPattern = #"s\S+@nwmissouri.edu"#
            let result = email.lowercased().range(
                of: emailPattern,
                options: .regularExpression
            )

            let validEmail = (result != nil)
            return validEmail
            
        }else{
            
            let emailPattern = #"@nwmissouri.edu"#
            let result = email.lowercased().range(
                of: emailPattern,
                options: .regularExpression
            )

            let validEmail = (result != nil)
            return validEmail
        }
    }
    
    func authenticateStudent() {
        
        guard let databasePath = databasePath else {
            return
        }
        
        databasePath.getData(completion: { [weak self] error, snapshots in
            if error == nil {
                guard let self = self, let children = snapshots?.children.allObjects as? [DataSnapshot] else {
                    return
                }
                
                let students = children.compactMap { snapshot in
                    return StudentModel(snapshot: snapshot)
                }
                
                if students.contains(where: { $0.email == self.emailTF.text!}) {
                    if let student = students.first(where: { $0.email == self.emailTF.text! && $0.password == self.passwordTF.text!}) {
                        
                        let loggedInUser = UserModel.init(student: student)
                        AppStateManager.shared.isUserLoggedIn = true
                        AppStateManager.shared.loggedInUser = loggedInUser
                        AppStateManager.shared.userRole = .Student
                        
                        let VC = self.storyboard?.instantiateViewController(withIdentifier: "StudentHomeVC") as! StudentHomeVC
                        
                        let window = UIApplication.shared.windows.first
                        
                        // Embed loginVC in Navigation Controller and assign the Navigation Controller as windows root
                        let nav = UINavigationController(rootViewController: VC)
                        window?.rootViewController = nav
                        
                    }
                    else {
                        Utility.showAlert(title: "Error", message: "Email or passwrd not correct")
                    }
                } else {
                    Utility.showAlert(title: "Error", message: "User not exist")
                }
            }
        })
        
    }
    
    
    func authenticateFaculty() {
        
        guard let databasePath = databasePath else {
            return
        }
        
        databasePath.getData(completion: {[weak self] error, snapshots in
            if error == nil {
                guard let self = self, let children = snapshots?.children.allObjects as? [DataSnapshot] else {
                    return
                }
                
                let facultyList = children.compactMap { snapshot in
                    return FacultyModel(snapshot: snapshot)
                }
                
                if facultyList.contains(where: { $0.email == self.emailTF.text!}) {
                    if let faculty = facultyList.first(where: { $0.email == self.emailTF.text! && $0.password == self.passwordTF.text!}) {
                        
                        let loggedInUser = UserModel.init(faculty: faculty)
                        AppStateManager.shared.isUserLoggedIn = true
                        AppStateManager.shared.loggedInUser = loggedInUser
                        AppStateManager.shared.userRole = .Faculty
                        
                        let VC = self.storyboard?.instantiateViewController(withIdentifier: "FacultyHomeVC") as! FacultyHomeVC
                        
                        let window = UIApplication.shared.windows.first
                        
                        // Embed loginVC in Navigation Controller and assign the Navigation Controller as windows root
                        let nav = UINavigationController(rootViewController: VC)
                        window?.rootViewController = nav
                    }
                    else {
                        Utility.showAlert(title: "Error", message: "Email or passwrd not correct")
                    }
                } else {
                    Utility.showAlert(title: "Error", message: "User not exist")
                }
            }
        })
    }
    
    func authenticateSuperAdmin() {
        
        guard let databasePath = databasePath else {
            return
        }
        
        databasePath.getData(completion: {[weak self] error, snapshots in
            if error == nil {
                guard let self = self, let children = snapshots?.children.allObjects as? [DataSnapshot] else {
                    return
                }
                
                let adminList = children.compactMap { snapshot in
                    return SuperAdmin(snapshot: snapshot)
                }
                
                if adminList.contains(where: { $0.email == self.emailTF.text!}) {
                    if let superAdmin = adminList.first(where: { $0.email == self.emailTF.text! && $0.password == self.passwordTF.text!}) {
                        
                        let loggedInUser = UserModel.init(superAdmin: superAdmin)
                        AppStateManager.shared.isUserLoggedIn = true
                        AppStateManager.shared.loggedInUser = loggedInUser
                        AppStateManager.shared.userRole = .SuperAdmin
                        
                        let VC = self.storyboard?.instantiateViewController(withIdentifier: "SuperAdminHomeVC") as! SuperAdminHomeVC
                        
                        let window = UIApplication.shared.windows.first
                        
                        // Embed loginVC in Navigation Controller and assign the Navigation Controller as windows root
                        let nav = UINavigationController(rootViewController: VC)
                        window?.rootViewController = nav
                    }
                    else {
                        Utility.showAlert(title: "Error", message: "Email or passwrd not correct")
                    }
                } else {
                    Utility.showAlert(title: "Error", message: "User not exist")
                }
            }
        })
    }
    
}
