//
//  ListViewController.swift
//  AttendanceSystem
//
//  Created by Student on 21/10/2022.
//

import UIKit
import FirebaseDatabase

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noRecordFoundLabel: UILabel!
    
    var userType: UserRole = .Student

    var studentsList = [StudentModel]()
    var filteredStudentsList = [StudentModel]()
    
    var faculyList = [FacultyModel]()
    var filteredFacultyList = [FacultyModel]()

    private lazy var databasePath: DatabaseReference? = {
        let ref = Database.database()
            .reference()
            .child(userType == .Student ? "student" : "faculty")
        return ref
    }()
    
    private let decoder = JSONDecoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Faculty List"
        if userType == .Student {
            
            self.navigationItem.title = "Students List"
        }
        
        self.navigationController?.navigationBar.isHidden = false
        
        searchBar.delegate = self

        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        
        noRecordFoundLabel.isHidden = true
        
        let addBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(onAddButtonClicked(_:)))
        self.navigationItem.rightBarButtonItem  = addBarButtonItem
        addBarButtonItem.tintColor = .black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if userType == .Student {
            fetchStudents()
        }
        else {
            fetchFaculty()
        }
    }
    
    @objc func onAddButtonClicked(_ sender: Any) {
        
        if userType == .Faculty {
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "FacultyRegisterVC") as! FacultyRegisterVC
//            VC.subjectSelectionCompletionHandler = {[weak self] in
//                guard let self = self else {return}
//                self.fetchFaculty()
//            }
            self.navigationController!.pushViewController(VC, animated: true)
        }
        else {
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "StudentRegisterVC") as! StudentRegisterVC
//            VC.subjectSelectionCompletionHandler = {[weak self] in
//                guard let self = self else {return}
//                self.fetchStudents()
//            }
            self.navigationController!.pushViewController(VC, animated: true)
        }
        
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
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
                
                self.filteredStudentsList = students
                self.studentsList = students
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    func fetchFaculty() {
        
        guard let databasePath = databasePath else {
            return
        }
        
        databasePath.getData(completion: {[weak self] error, snapshots in
            if error == nil {
                guard let self = self, let children = snapshots?.children.allObjects as? [DataSnapshot] else {
                    return
                }
                
                let faculty = children.compactMap { snapshot in
                    return FacultyModel(snapshot: snapshot)
                }
                
                self.filteredFacultyList = faculty
                self.faculyList = faculty
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if userType == .Student {
            noRecordFoundLabel.isHidden = filteredStudentsList.count != 0
            tableView.isHidden = filteredStudentsList.count == 0
            
            return filteredStudentsList.count
        }
        
        noRecordFoundLabel.isHidden = filteredFacultyList.count != 0
        tableView.isHidden = filteredFacultyList.count == 0
        
        return filteredFacultyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "courseCell", for: indexPath) as! CourseTableViewCell
        cell.backgroundColor = .clear
        
        cell.imgView.isHidden = false
        
        cell.courseLbl.text = userType == .Student ? filteredStudentsList[indexPath.row].name ?? "" : filteredFacultyList[indexPath.row].name ?? ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "FacultyCoursesVC") as! FacultyCoursesVC
        
        if userType == .Student {
            VC.studentId = filteredStudentsList[indexPath.row].id ?? ""
            VC.studentSemester = filteredStudentsList[indexPath.row].semester ?? .Fall
            VC.subjects = filteredStudentsList[indexPath.row].subjects ?? [SubjectModel]()
        }
        else if userType == .Faculty {
            VC.facultyId = filteredFacultyList[indexPath.row].id ?? ""
            VC.subjects = filteredFacultyList[indexPath.row].subjects ?? [SubjectModel]()
        }
        
        VC.titleString = userType == .Student ? filteredStudentsList[indexPath.row].name ?? "" : filteredFacultyList[indexPath.row].name ?? ""

        self.navigationController!.pushViewController(VC, animated: true)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            guard let databasePath = databasePath else {
                return
            }
            
            if userType == .Student {
                // Remove the student from the DB
                databasePath.child(filteredStudentsList[indexPath.row].id ?? "").removeValue { error, arg  in
                    if error != nil {
                        print("error \(String(describing: error))")
                    }
                    else {
                        self.filteredStudentsList.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                  }
            }
            else if userType == .Faculty {
                // Remove the faculty from the DB
                databasePath.child(filteredFacultyList[indexPath.row].id ?? "").removeValue { error, arg  in
                    if error != nil {
                        print("error \(String(describing: error))")
                    }
                    else {
                        self.filteredFacultyList.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                  }
            }
        }
    }
}

// MARK: UISearchBar Delegate Methods
extension ListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if userType == .Student {
            
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
        }
        else {
            
            if searchText.count > 0 {
                self.filteredFacultyList.removeAll()
                self.filteredFacultyList = self.faculyList.filter{
                    ($0.name)?.range(of: searchText,
                                     options: .caseInsensitive,
                                     range: nil,
                                     locale: nil) != nil
                }
            } else {
                self.filteredFacultyList = self.faculyList
            }
        }
        
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
}

