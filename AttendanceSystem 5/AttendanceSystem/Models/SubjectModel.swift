//
//  SubjectModel.swift
//  AttendanceSystem
//
//  Created by by Student on 16/09/2022.
//

import Foundation
import FirebaseDatabase

struct SubjectModel: Identifiable, Codable {
    var id: String?
    var name: String?
    var semester: Semester?
    var section: Section?
    var timeSlot: String?
    
    // MARK: Initialize with Raw Data
    init(id: String, name: String, semester: Semester, timeSlot: String="", section: Section) {
        self.id = id
        self.name = name
        self.semester = semester
        self.section = section
        self.timeSlot = timeSlot
    }
    
    // MARK: Initialize with Firebase DataSnapshot
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let id = value["id"] as? String,
            let name = value["name"] as? String
        else {
            return nil
        }
        
        self.id = id
        self.name = name
    }
    
}
