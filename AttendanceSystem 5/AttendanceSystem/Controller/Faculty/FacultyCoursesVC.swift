//
//  FacultyCoursesVC.swift
//  AttendanceSystem
//
//  Created by Student on 02/09/2022.
//

import UIKit
import FirebaseDatabase

class FacultyCoursesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var coursesTableView: UITableView!
    @IBOutlet weak var noRecordFoundLabel: UILabel!

    var source:Source = .generateQRCode
    
    var userType: UserRole = AppStateManager.shared.userRole

    var subjects = [SubjectModel]()
    var selectedIndex = -1
    
    var titleString = ""

    var studentId = ""
    var studentSemester:Semester = .Fall
    
    var facultyId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        coursesTableView.delegate = self
        coursesTableView.dataSource = self
        coursesTableView.backgroundColor = .clear
        
        if self.userType == .Faculty {
            self.navigationItem.title = "Faculty"
            self.getFacultyCourses()
        }
        else if self.userType == .Student {
            self.navigationItem.title = "Student"
            self.getStudentCourses()
        }
        else {
            
            self.navigationItem.title = titleString
            
            titleLabel.text = "Selected Cuorses:"
            
            let addBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(onAddButtonClicked(_:)))
            self.navigationItem.rightBarButtonItem  = addBarButtonItem
            addBarButtonItem.tintColor = .black
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
        
    }
    
    @objc func onAddButtonClicked(_ sender: Any) {
        
        if facultyId != "" {
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "FacultyAddCourseVC") as! FacultyAddCourseVC
            VC.facultyId = facultyId
            VC.subjects = subjects
            VC.subjectSelectionCompletionHandler = {[weak self] subjects in
                guard let self = self else {return}
                self.subjects = subjects
                self.coursesTableView.reloadData()
            }
            self.navigationController!.pushViewController(VC, animated: true)
        }
        else if studentId != "" {
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "StudentAddCourseVC") as! StudentAddCourseVC
            VC.studentId = studentId
            VC.studentSemester = studentSemester
            VC.subjects = subjects
            VC.subjectSelectionCompletionHandler = {[weak self] subjects in
                guard let self = self else {return}
                self.subjects = subjects
                self.coursesTableView.reloadData()
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

        if userType == .Faculty || facultyId != "" {
            cell.semesterLbl.text = "- " + (subjects[indexPath.row].semester == .Fall ? "Fall" : "Spring")
            cell.timeLbl.text = "- " + (subjects[indexPath.row].timeSlot ?? "- - -")
        }
        
        
        cell.imgView.image = UIImage(named: "RadioUnChecked")
        
        if indexPath.row == selectedIndex || userType == .SuperAdmin {
            
            cell.imgView.image = UIImage(named: "RadioChecked")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if userType != .SuperAdmin {
            
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
                    choosAttendanceOption()
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
    
    func choosAttendanceOption() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect =  CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY / 2.5, width: 0, height: 0)
        }
        let GalleryAction: UIAlertAction = UIAlertAction(title: "Check Attendance By Student", style: .default) { action -> Void in
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "FacultyCheckAttendanceVC") as! FacultyCheckAttendanceVC
            VC.semester = self.subjects[self.selectedIndex].semester ?? .Fall
            VC.section = self.subjects[self.selectedIndex].section ?? .A
            VC.subjectId = self.subjects[self.selectedIndex].id ?? ""
            self.navigationController!.pushViewController(VC, animated: true)
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        let CameraAction: UIAlertAction = UIAlertAction(title: "Check Attendance By Date", style: .default ) { action -> Void in
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "AttendanceChartVC") as! AttendanceChartVC
            VC.subjectId = self.subjects[self.selectedIndex].id ?? ""
            VC.section = self.subjects[self.selectedIndex].section ?? .A
            VC.checkAttendanceByDate = true
            self.navigationController!.pushViewController(VC, animated: true)
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        let CancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel ) { action -> Void in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(GalleryAction)
        alert.addAction(CameraAction)
        alert.addAction(CancelAction)
        
        alert.modalPresentationCapturesStatusBarAppearance = true

        self.present(alert, animated: true, completion: nil)
    }
}
