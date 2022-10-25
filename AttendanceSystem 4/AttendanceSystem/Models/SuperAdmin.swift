//
//  SuperAdmin.swift
//  AttendanceSystem
//
//  Created by Student on 21/10/2022.
//

import Foundation
import FirebaseDatabase

struct SuperAdmin: Codable {
    
    var email: String?
    var password: String?
    
    // MARK: Initialize with Raw Data
    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
    
    // MARK: Initialize with Firebase DataSnapshot
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let email = value["email"] as? String,
            let password = value["password"] as? String
        else {
            return nil
        }
        
        self.email = email
        self.password = password
        
    }
    
}
