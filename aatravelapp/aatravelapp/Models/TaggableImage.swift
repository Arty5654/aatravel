//
//  TaggableImage.swift
//  aatravelapp
//
//  Created by Arteom Avetissian on 4/15/25.
//

import SwiftUI

enum TagType: String, CaseIterable, Identifiable {
    case hotel, museum, house, custom
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .hotel: return "🏨"
        case .museum: return "🏛"
        case .house: return "🏠"
        case .custom: return "🟠"
        }
    }
}

struct ImageTag: Identifiable {
    let id = UUID()
    var position: CGPoint
    var label: String
    var type: TagType
    var url: String?
}

