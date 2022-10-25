//
//  FacultyCheckAttendanceVC.swift
//  AttendanceSystem
//
//  Created by Student on 06/09/2022.
//

import UIKit
import FirebaseDatabase

class FacultyCheckAttendanceVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var studentsTableView: UITableView!
    @IBOutlet weak var noRecordFoundLabel: UILabel!
    
    var filteredAttendanceData = [AttendanceModel]()
    
    var semester:Semester = .Fall
    var section:Section = .A
    var subjectId = ""
    var year = "2022"

    private lazy var databasePath: DatabaseReference? = {
        let ref = Database.database()
            .reference()
            .child("attendance")
        return ref
    }()
    
    private let decoder = JSONDecoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Faculty"
        
        studentsTableView.delegate = self
        studentsTableView.dataSource = self
        studentsTableView.backgroundColor = .clear
        
        fetchAttendance()
        
        noRecordFoundLabel.isHidden = true
    }
    
    func fetchAttendance() {
        
        guard let databasePath = databasePath else {
            return
        }
        
        databasePath.getData(completion: {[weak self] error, snapshots in
            if error == nil {
                guard let self = self, let children = snapshots?.children.allObjects as? [DataSnapshot] else {
                    return
                }
                
                var allAttendance = children.compactMap { snapshot in
                    return AttendanceModel(snapshot: snapshot)
                }
                
                allAttendance = allAttendance.filter({
                    return ($0.facultyId == AppStateManager.shared.getFacultyId())
                })
                
                self.filteredAttendanceData = allAttendance.filter({
                    return ($0.subjectId == self.subjectId && $0.section == self.section && $0.semester == self.semester)
                })
                
                DispatchQueue.main.async {
                    self.studentsTableView.reloadData()
                }
            }
        })
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        noRecordFoundLabel.isHidden = filteredAttendanceData.count != 0
        tableView.isHidden = filteredAttendanceData.count == 0
        
        return filteredAttendanceData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "courseCell", for: indexPath) as! CourseTableViewCell
        cell.backgroundColor = .clear
        
        cell.imgView.isHidden = false
        
        cell.courseLbl.text = filteredAttendanceData[indexPath.row].studentName ?? ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "AttendanceChartVC") as! AttendanceChartVC
        VC.studentId = filteredAttendanceData[indexPath.row].studentId ?? ""
        VC.semester = semester
        VC.section = section
        VC.subjectId = filteredAttendanceData[indexPath.row].subjectId ?? ""
        self.navigationController!.pushViewController(VC, animated: true)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
