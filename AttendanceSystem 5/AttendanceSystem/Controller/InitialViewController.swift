//
//  InitialViewController.swift
//  AttendanceSystem
//
//  Created by Student on 02/09/2022.
//

import UIKit

class InitialViewController: UIViewController {
    
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var studentBtn: UIButton!
    @IBOutlet weak var facultyBtn: UIButton!
    @IBOutlet weak var adminBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logo.RoundCorners(radius: 8)
        studentBtn.RoundCorners(radius: 8)
        facultyBtn.RoundCorners(radius: 8)
        adminBtn.RoundCorners(radius: 8)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func studentBtnClicked(_ sender: Any) {
        
        self.moveToView(type: .Student)
    }
    
    @IBAction func facultyBtnClicked(_ sender: Any) {
        
        self.moveToView(type: .Faculty)
    }
    
    @IBAction func adminBtnClicked(_ sender: Any) {
        
        self.moveToView(type: .SuperAdmin)
    }
    
    func moveToView(type: UserRole) -> Void {
        
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        VC.userType = type
        self.navigationController!.pushViewController(VC, animated: true)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
