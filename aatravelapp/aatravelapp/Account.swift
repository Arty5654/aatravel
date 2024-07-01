//
//  Account.swift
//  aatravelapp
//
//  Created by Arteom Avetissian on 6/30/24.
//

import Foundation

struct Account: Codable, Hashable {
    var name: String
    var category: String
    var description: String
    var wealth_type: String
    var balance: Int
    var created_at: String
}
