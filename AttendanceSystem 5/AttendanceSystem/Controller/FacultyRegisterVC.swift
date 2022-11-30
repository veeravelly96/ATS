//
//  FacultyRegisterVC.swift
//  AttendanceSystem
//
//  Created by Student on 02/09/2022.
//

import UIKit
import FirebaseDatabase

class FacultyRegisterVC: UIViewController {
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    @IBOutlet weak var registerBtn: UIButton!
    
    private let ref = Database.database().reference()
    private let dbPath = "faculty"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTF.setTextField()
        emailTF.setTextField()
        passwordTF.setTextField()
        
        self.navigationItem.title = "Faculty"
        registerBtn.RoundCorners(radius: 8)
    }
    
    @IBAction func registerBtnClicked(_ sender: Any) {
        validateData()
    }
    
    func validateData() {
        
        var shouldProceed = true
        var message = ""
        
        if (nameTF.text?.isEmpty)! {
            shouldProceed = false
            message = "Please enter your name"
        }else if (emailTF.text?.isEmpty)! {
            shouldProceed = false
            message = "Please enter your email"
        }else if !isValidFacultyEmail(emailTF.text ?? "") {
            shouldProceed = false
            message = "Please provide valid email address"
        }else if !Utility.isValidEmail(testStr: emailTF.text!){
            shouldProceed = false
            message = "Please provide valid email address"
        }else if (passwordTF.text?.isEmpty)! {
            shouldProceed = false
            message = "Please enter your password"
        }
        
        if shouldProceed {
            registerFaculty()
        }
        else {
            Utility.showAlert(title: "Error", message: message)
        }
    }
    
    func isValidFacultyEmail(_ email: String) -> Bool {
        let emailPattern = #"@nwmissouri.edu"#
        let result = email.lowercased().range(
            of: emailPattern,
            options: .regularExpression
        )

        let validEmail = (result != nil)
        return validEmail
    }
    
    func registerFaculty() {
        guard let autoId = ref.child(dbPath).childByAutoId().key else {
            return
        }
        
        let faculty = FacultyModel.init(id: autoId, name: nameTF.text!, email: emailTF.text!, password: passwordTF.text!)
        
        do {
            let data = try JSONEncoder().encode(faculty)
            
            let json = try JSONSerialization.jsonObject(with: data)
            
            ref.child("\(dbPath)/\(autoId)")
                .setValue(json)
            
            Utility.showAlert(title: "Alerty", message: "Faculty registered successfully", okTapped: {
//                let loggedInUser = UserModel.init(student: nil, faculty: faculty)
//                AppStateManager.shared.isUserLoggedIn = true
//                AppStateManager.shared.loggedInUser = loggedInUser
//                AppStateManager.shared.userRole = .Faculty
//
//                let VC = self.storyboard?.instantiateViewController(withIdentifier: "FacultyHomeVC") as! FacultyHomeVC
//
//                let window = UIApplication.shared.windows.first
//
//                // Embed loginVC in Navigation Controller and assign the Navigation Controller as windows root
//                let nav = UINavigationController(rootViewController: VC)
//                window?.rootViewController = nav
                self.navigationController?.popViewController(animated: true)
            })
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
