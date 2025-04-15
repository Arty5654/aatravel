//
//  Account.swift
//  aatravelapp
//
//  Created by Arteom Avetissian on 6/30/24.
//

import Foundation

struct Account: Codable, Hashable {
    var uuid: String
    var email: String
    var username: String
    //var password: String
    var created_at: String
    let profile_picture_url: String?
}
