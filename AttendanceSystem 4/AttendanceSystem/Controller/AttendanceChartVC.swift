//
//  AttendanceChartVC.swift
//  AttendanceSystem
//
//  Created by Student on 09/09/2022.
//

import UIKit
import FLCharts
import FirebaseDatabase


class AttendanceChartVC: UIViewController {
    
    @IBOutlet var cardView: FLCard!
    
    var userType = AppStateManager.shared.userRole
            
    var filteredAttendanceData = [AttendanceModel]()
    
    var studentId = ""
    var semester:Semester = AppStateManager.shared.loggedInUser?.student?.semester ?? .Fall
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
        
        if userType == .Student {
            
            self.navigationItem.title = "Student"
        }
        
        fetchAttendance()
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
                    return (self.userType == .Student ? ($0.studentId == AppStateManager.shared.getStudentId()) : ($0.facultyId == AppStateManager.shared.getFacultyId()))
                })
                
                if self.studentId != "" {
                    self.filteredAttendanceData = allAttendance.filter({
                        return ($0.subjectId == self.subjectId && $0.section == self.section && $0.semester == self.semester && $0.studentId == self.studentId)
                    })
                }
                else {
                    self.filteredAttendanceData = allAttendance.filter({
                        return ($0.subjectId == self.subjectId && $0.section == self.section && $0.semester == self.semester)
                    })
                }
                
                let present = self.filteredAttendanceData.filter({
                    return ($0.status == AttendanceStatus.Present)
                })
                
                let absent = self.filteredAttendanceData.filter({
                    return ($0.status == AttendanceStatus.Absent)
                })
                
                let late = self.filteredAttendanceData.filter({
                    return ($0.status == AttendanceStatus.Late)
                })
                
                self.showAttendance(presentCount: CGFloat(present.count), lateCount: CGFloat(late.count), absentCount: CGFloat(absent.count))
            }
        })
        
    }
    
    func showAttendance(presentCount:CGFloat, lateCount:CGFloat, absentCount:CGFloat) -> Void {
        
        let data = [FLPiePlotable(value: presentCount, key: Key(key: "On Time", color: FLColor(hex: "008000"))),
                    FLPiePlotable(value: lateCount, key: Key(key: "Late", color: FLColor(hex: "00FF00"))),
                    FLPiePlotable(value: absentCount, key: Key(key: "Absent", color: FLColor(hex: "800000")))]
//                    ,FLPiePlotable(value: 0.0, key: Key(key: "Leave", color: FLColor(hex: "FFFF00")))]
        
        let pieChart = FLPieChart(title: "Pie Chart",
                                  data: data,
                                  border: .full,
                                  formatter: .percent,
                                  animated: true)
        
        cardView.setup(chart: pieChart, style: .rounded)
        cardView.showAverage = true
        cardView.showLegend = true
        cardView.backgroundColor = .clear
    }
}
