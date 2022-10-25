//
//  AppStateManager.swift
//  AttendanceSystem
//
//  Created by by Student on 16/09/2022.
//

import Foundation

class AppStateManager: NSObject {
    
    let defaults = UserDefaults.standard
    
    static let shared = AppStateManager()
            
    private override init() {
        
        super.init()
    }
    
    var loggedInUser: UserModel?{
        
        set{
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                defaults.set(encoded, forKey: "SavedUser")
                defaults.synchronize()
            }
        }
        
        get{
            if let savedUser = defaults.object(forKey: "SavedUser") as? Data {
                let decoder = JSONDecoder()
                if let loadedUser = try? decoder.decode(UserModel.self, from: savedUser) {
                    return loadedUser
                }
            }
            return nil
        }
    }
    
    var userRole: UserRole {
        set {
            defaults.set(newValue.rawValue, forKey: "UserRole")
            defaults.synchronize()
        }
        
        get {
            if let role = defaults.value(forKey: "UserRole") as? UserRole.RawValue {
                return UserRole(rawValue: role) ?? UserRole.Student
            }
            return UserRole.Student
        }
    }
    
    
    var isUserLoggedIn:Bool{
        
        set{
            defaults.set(newValue, forKey: "isSignIn")
            defaults.synchronize()
        }
        
        get{
            return defaults.bool(forKey: "isSignIn")
        }
    }
    
    func getStudentId()-> String {
        if let id = loggedInUser?.student?.id {
            return id
        }
        return "-1"
    }
    
    func getFacultyId()-> String {
        if let id = loggedInUser?.faculty?.id {
            return id
        }
        return "-1"
    }
    
    
    func markUserLogout(){
        defaults.set(false, forKey: "isSignIn")
        defaults.removeObject(forKey: "SavedUser")
        defaults.removeObject(forKey: "UserRole")
        defaults.synchronize()
    }
    
}


