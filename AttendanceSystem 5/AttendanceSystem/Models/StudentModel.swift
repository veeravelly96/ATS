//
//  StudentModel.swift
//  AttendanceSystem
//
//  Created by by Student on 16/09/2022.
//

import Foundation
import FirebaseDatabase

struct StudentModel: Identifiable, Codable {
    var id: String?
    var name: String?
    var rollNumber:String?
    var email: String?
    var password: String?
    var semester: Semester?
    var year: String?
    var subjects: [SubjectModel]?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case rollNumber = "919Number"
        case email = "email"
        case semester = "semester"
        case subjects = "subjects"
        case password = "password"
        case year = "year"
    }
    
    // MARK: Initialize with Raw Data
    init(id: String, name: String, rollNumber: String, email: String, password: String, semester: Semester, year: String) {
        self.id = id
        self.name = name
        self.rollNumber = rollNumber
        self.email = email
        self.semester = semester
        self.password = password
        self.year = year
    }
    
    // MARK: Initialize with Firebase DataSnapshot
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let id = value["id"] as? String,
            let name = value["name"] as? String,
            let rollNumber = value["919Number"] as? String,
            let email = value["email"] as? String,
            let semester = value["semester"] as? Int,
            let password = value["password"] as? String,
            let year = value["year"] as? String
        else {
            return nil
        }
        
        self.id = id
        self.name = name
        self.rollNumber = rollNumber
        self.email = email
        self.semester = Semester.init(rawValue: semester)
        self.password = password
        self.year = year

        if let subjects = value["subjects"] as? [[String:Any]] {
            do {
                let subjectsData = try JSONSerialization.data(withJSONObject: subjects)
                self.subjects = try JSONDecoder().decode([SubjectModel].self, from: subjectsData)
            } catch {
                print("an error occurred", error)
            }
        }
    }
    
}

enum Semester:Int, Codable {
    case Fall = 0
    case Spring = 1
}

enum Section:String, Codable {
    case A = "A"
    case B = "B"
    case C = "C"
}
