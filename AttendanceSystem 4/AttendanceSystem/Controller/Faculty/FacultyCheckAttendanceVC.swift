//
//  FacultyCheckAttendanceVC.swift
//  AttendanceSystem
//
//  Created by Student on 06/09/2022.
//

import UIKit
import FirebaseDatabase

class FacultyCheckAttendanceVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var studentsTableView: UITableView!
    @IBOutlet weak var noRecordFoundLabel: UILabel!
    
    var studentsList = [StudentModel]()
    var filteredStudentsList = [StudentModel]()
    
    var semester:Semester = .Fall
    var section:Section = .A
    var subjectId = ""
    var year = "2022"

    private lazy var databasePath: DatabaseReference? = {
        let ref = Database.database()
            .reference()
            .child("student")
        return ref
    }()
    
    private let decoder = JSONDecoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Faculty"
        
        searchBar.delegate = self

        studentsTableView.delegate = self
        studentsTableView.dataSource = self
        studentsTableView.backgroundColor = .clear
        
        fetchStudents()
        
        noRecordFoundLabel.isHidden = true
    }
    
    func fetchStudents() {
        
        guard let databasePath = databasePath else {
            return
        }
        
        databasePath.getData(completion: {[weak self] error, snapshots in
            if error == nil {
                guard let self = self, let children = snapshots?.children.allObjects as? [DataSnapshot] else {
                    return
                }
                
                let students = children.compactMap { snapshot in
                    return StudentModel(snapshot: snapshot)
                }
                
                self.filteredStudentsList = students.filter({
                    var isValidSubject=false
                    let subjects = $0.subjects ?? [SubjectModel]()
                    if let _ = subjects.first(where: { $0.semester == self.semester && $0.section == self.section && $0.id == self.subjectId }) {
                        isValidSubject = true
                    }
                    return (isValidSubject)
                })
                
                self.studentsList = self.filteredStudentsList
                
                DispatchQueue.main.async {
                    self.studentsTableView.reloadData()
                }
            }
        })
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        noRecordFoundLabel.isHidden = filteredStudentsList.count != 0
        tableView.isHidden = filteredStudentsList.count == 0
        
        return filteredStudentsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "courseCell", for: indexPath) as! CourseTableViewCell
        cell.backgroundColor = .clear
        
        cell.imgView.isHidden = false
        
        cell.courseLbl.text = filteredStudentsList[indexPath.row].name ?? ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "AttendanceChartVC") as! AttendanceChartVC
        VC.studentId = filteredStudentsList[indexPath.row].id ?? ""
        VC.semester = semester
        VC.section = section
        VC.subjectId = subjectId
        self.navigationController!.pushViewController(VC, animated: true)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}

// MARK: UISearchBar Delegate Methods
extension FacultyCheckAttendanceVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.count > 0 {
            self.filteredStudentsList.removeAll()
            self.filteredStudentsList = self.studentsList.filter{
                ($0.name)?.range(of: searchText,
                                     options: .caseInsensitive,
                                     range: nil,
                                     locale: nil) != nil
            }
        } else {
            self.filteredStudentsList = self.studentsList
        }
        self.studentsTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
}
