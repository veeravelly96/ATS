//
//  FacultyModel.swift
//  AttendanceSystem
//
//  Created by by Student on 16/09/2022.
//

import FirebaseDatabase

struct FacultyModel: Identifiable, Codable {
    var id: String?
    var name: String?
    var email: String?
    var password: String?
    var subjects: [SubjectModel]?
    
    // MARK: Initialize with Raw Data
    init(id: String, name: String, email: String, password: String) {
        self.id = id
        self.name = name
        self.email = email
        self.password = password
    }
    
    // MARK: Initialize with Firebase DataSnapshot
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let id = value["id"] as? String,
            let name = value["name"] as? String,
            let email = value["email"] as? String,
            let password = value["password"] as? String
        else {
            return nil
        }
        
        self.id = id
        self.name = name
        self.email = email
        self.password = password
        
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
