//
//  AttendanceModel.swift
//  AttendanceSystem
//
//  Created by by Student on 16/09/2022.
//

import FirebaseDatabase

struct AttendanceModel: Identifiable, Codable {
    var id: String?
    var studentId: String?
    var studentName: String?
    var facultyId: String?
    var subjectId: String?
    var semester: Semester?
    var section: Section?
    var date: String?
    var status: AttendanceStatus?
    
    // MARK: Initialize with Raw Data
    init(id: String, studentId: String, studentName: String, facultyId: String, subjectId: String, semester: Semester, section: Section, date: String, status: AttendanceStatus) {
        self.id = id
        self.studentId = studentId
        self.studentName = studentName
        self.facultyId = facultyId
        self.subjectId = subjectId
        self.semester = semester
        self.section = section
        self.date = date
        self.status = status
    }
    
    // MARK: Initialize with Firebase DataSnapshot
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let id = value["id"] as? String,
            let studentId = value["studentId"] as? String,
            let studentName = value["studentName"] as? String,
            let facultyId = value["facultyId"] as? String,
            let subjectId = value["subjectId"] as? String,
            let semester = value["semester"] as? Int,
            let section = value["section"] as? String,
            let date = value["date"] as? String,
            let status = value["status"] as? Int
        else {
            return nil
        }
        
        self.id = id
        self.studentName = studentName
        self.studentId = studentId
        self.facultyId = facultyId
        self.subjectId = subjectId
        self.semester = Semester.init(rawValue: semester)
        self.section = Section.init(rawValue: section)
        self.date = date
        self.status = AttendanceStatus.init(rawValue: status)

    }
    
}


enum AttendanceStatus: Int, Codable {
    case Present = 0
    case Absent = 1
    case Late = 2
}
