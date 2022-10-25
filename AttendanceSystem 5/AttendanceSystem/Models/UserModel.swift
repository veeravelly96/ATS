//
//  UserModel.swift
//  AttendanceSystem
//
//  Created by Student on 16/09/2022.
//

import Foundation

enum UserRole:Int {
    case Student = 0
    case Faculty = 1
}

struct UserModel: Codable {
    var student: StudentModel?
    var faculty: FacultyModel?
}
