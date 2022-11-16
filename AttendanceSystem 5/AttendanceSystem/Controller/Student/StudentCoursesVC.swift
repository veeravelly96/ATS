//
//  StudentCoursesVC.swift
//  AttendanceSystem
//
//  Created by Student on 02/09/2022.
//

import UIKit
import FirebaseDatabase
import CoreMedia

enum Source {
    case addCourse
    case checkAttendance
    case generateQRCode
    case scanQRCode
    case other
}

class StudentCoursesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var coursesTableView: UITableView!
    
    var subjects = [SubjectModel]()
    
    var selectedIndex = -1
        
    private lazy var databasePath: DatabaseReference? = {
        //      // 1
        //      guard let uid = Auth.auth().currentUser?.uid else {
        //        return nil
        //      }
        
        // 2
        let ref = Database.database()
            .reference()
            .child("subject")
        return ref
    }()
    
    // 3
    private let decoder = JSONDecoder()
        
    var source: Source = .checkAttendance

    var userType: UserRole = AppStateManager.shared.userRole

    var subjectSelectionCompletionHandler: ((SubjectModel) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Student"
        coursesTableView.delegate = self
        coursesTableView.dataSource = self
        coursesTableView.backgroundColor = .clear
        
        self.navigationItem.hidesBackButton = source != .checkAttendance
        
        if source == .addCourse {
            let window = UIApplication.shared.windows.first
            window?.endEditing(true)
        }
        
        if userType == .Faculty {
            self.navigationItem.title = "Faculty"
        }
        
        if self.source == .addCourse {
            let doneBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(onDoneButtonClicked(_:)))
            self.navigationItem.rightBarButtonItem  = doneBarButtonItem
            doneBarButtonItem.tintColor = .black
        }
        
        fetchAllCourses()
    }
    
    func fetchAllCourses() {
        
        guard let databasePath = databasePath else {
            return
        }
        
        databasePath.getData(completion: {[weak self] error, snapshots in
            if error == nil {
                guard let self = self, let children = snapshots?.children.allObjects as? [DataSnapshot] else {
                    return
                }
                
                let subjects = children.compactMap { snapshot in
                    return SubjectModel(snapshot: snapshot)
                }
                
                self.subjects = subjects
                
                DispatchQueue.main.async {
                    self.coursesTableView.reloadData()
                }
            }
        })
        
    }
    
    @objc func onDoneButtonClicked(_ sender: Any){
        self.navigationController?.popViewController(animated: true)
        
        if selectedIndex != -1 {
            subjectSelectionCompletionHandler?(subjects[selectedIndex])
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return subjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "courseCell", for: indexPath) as! CourseTableViewCell
        cell.backgroundColor = .clear
        
        cell.courseLbl.text = subjects[indexPath.row].name
        cell.imgView.image = UIImage(named: "RadioUnChecked")
        
        if selectedIndex == indexPath.row {
            cell.imgView.image = UIImage(named: "RadioChecked")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if source == .addCourse {
            selectedIndex = indexPath.row
            tableView.reloadData()
        }
        
    }
}
