//
//  UserSession.swift
//  aatravelapp
//
//  Created by Arteom Avetissian on 4/15/25.
//

import Foundation
import Combine

class UserSession: ObservableObject {
    @Published var userUUID: String? {
        didSet {
            UserDefaults.standard.set(userUUID, forKey: "userUUID")
            isLoggedIn = (userUUID != nil)
        }
    }

    @Published var isLoggedIn: Bool = false

    init() {
        self.userUUID = UserDefaults.standard.string(forKey: "userUUID")
        self.isLoggedIn = (userUUID != nil)
    }

    func logout() {
        userUUID = nil
        isLoggedIn = false
        UserDefaults.standard.removeObject(forKey: "userUUID")
        UserDefaults.standard.removeObject(forKey: "userEmail")
    }
}
