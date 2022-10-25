//
//  FacultyCoursesVC.swift
//  AttendanceSystem
//
//  Created by Student on 02/09/2022.
//

import UIKit
import FirebaseDatabase

class FacultyCoursesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var coursesTableView: UITableView!
    @IBOutlet weak var noRecordFoundLabel: UILabel!

    var source:Source = .generateQRCode
    
    var userType: UserRole = AppStateManager.shared.userRole

    var subjects = [SubjectModel]()
    var selectedIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = userType == .Faculty ? "Faculty" : "Student"
        
        coursesTableView.delegate = self
        coursesTableView.dataSource = self
        coursesTableView.backgroundColor = .clear
        
        let addBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(onAddButtonClicked(_:)))
        self.navigationItem.rightBarButtonItem  = addBarButtonItem
        addBarButtonItem.tintColor = .black
        
        if self.userType == .Faculty {
            self.getFacultyCourses()
        }
        else {
            self.getStudentCourses()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
        
    }
    
    @objc func onAddButtonClicked(_ sender: Any) {
        
        if userType == .Faculty {
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "FacultyAddCourseVC") as! FacultyAddCourseVC
            VC.subjectSelectionCompletionHandler = {[weak self] in
                guard let self = self else {return}
                self.getFacultyCourses()
            }
            self.navigationController!.pushViewController(VC, animated: true)
        }
        else {
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "StudentAddCourseVC") as! StudentAddCourseVC
            VC.subjectSelectionCompletionHandler = {[weak self] in
                guard let self = self else {return}
                self.getStudentCourses()
            }
            self.navigationController!.pushViewController(VC, animated: true)
        }
        
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    
    func getFacultyCourses() {
        
        self.subjects = AppStateManager.shared.loggedInUser?.faculty?.subjects ?? [SubjectModel]()
        
        if self.subjects.count == 0 {
            Utility.showAlert(title: "Alert", message: "No course added\nYou want to add course?", button1Title: "Cancel", noTapped: {
                self.navigationController?.popViewController(animated: true)
            }, button2Title: "Add Course", yesTapped: {
                self.onAddButtonClicked(UIButton())
            })
        }

        DispatchQueue.main.async {
            self.coursesTableView.reloadData()
        }
    }
    
    func getStudentCourses() {
        
        self.subjects = AppStateManager.shared.loggedInUser?.student?.subjects ?? [SubjectModel]()
        
        if self.subjects.count == 0 {
            Utility.showAlert(title: "Alert", message: "No course added\nYou want to add course?", button1Title: "Cancel", noTapped: {
                self.navigationController?.popViewController(animated: true)
            }, button2Title: "Add Course", yesTapped: {
                self.onAddButtonClicked(UIButton())
            })
        }

        DispatchQueue.main.async {
            self.coursesTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        noRecordFoundLabel.isHidden = subjects.count != 0
        tableView.isHidden = subjects.count == 0
        
        return subjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "courseCell", for: indexPath) as! CourseTableViewCell
        cell.backgroundColor = .clear
        
        cell.stackView.isHidden = false
        
        cell.courseLbl.text = subjects[indexPath.row].name
        cell.sectionLbl.text = "- Section " + (subjects[indexPath.row].section?.rawValue.description ?? "- - -")
        cell.semesterLbl.text = ""
        cell.timeLbl.text = ""

        if userType == .Faculty {
            cell.semesterLbl.text = "- " + (subjects[indexPath.row].semester == .Fall ? "Fall" : "Spring")
            cell.timeLbl.text = "- " + (subjects[indexPath.row].timeSlot ?? "- - -")
        }
        
        cell.imgView.image = UIImage(named: "RadioUnChecked")
        
        if indexPath.row == selectedIndex {
            
            cell.imgView.image = UIImage(named: "RadioChecked")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex = indexPath.row
        tableView.reloadData()
        
        if source == .generateQRCode {
            
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "GenerateQRVC") as! GenerateQRVC
            VC.semester = subjects[selectedIndex].semester ?? .Fall
            VC.year = "2022"
            VC.subject = subjects[selectedIndex]
            VC.section = subjects[selectedIndex].section ?? .A
            self.navigationController!.pushViewController(VC, animated: true)
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        else if source == .scanQRCode {
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "ScanQRViewController") as! ScanQRViewController
            if let subjectId = subjects[indexPath.row].id {
                VC.mySubjectId = subjectId
            }
            VC.mySection = subjects[selectedIndex].section ?? .A
            self.navigationController!.pushViewController(VC, animated: true)
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        else if source == .checkAttendance {
            if userType == .Faculty {
                let VC = self.storyboard?.instantiateViewController(withIdentifier: "FacultyCheckAttendanceVC") as! FacultyCheckAttendanceVC
                VC.semester = subjects[selectedIndex].semester ?? .Fall
                VC.section = subjects[selectedIndex].section ?? .A
                VC.subjectId = subjects[selectedIndex].id ?? ""
                self.navigationController!.pushViewController(VC, animated: true)
                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            }
            else {
                let VC = self.storyboard?.instantiateViewController(withIdentifier: "AttendanceChartVC") as! AttendanceChartVC
                VC.subjectId = subjects[indexPath.row].id ?? ""
                VC.section = subjects[selectedIndex].section ?? .A
                self.navigationController!.pushViewController(VC, animated: true)
                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            }
        }
        
    }
}
