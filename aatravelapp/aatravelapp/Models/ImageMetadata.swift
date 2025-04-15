//
//  ImageMetadata.swift
//  aatravelapp
//
//  Created by Arteom Avetissian on 4/15/25.
//

import SwiftUI
import Foundation

struct ImageMetadata: Identifiable {
    let id = UUID()
    var image: UIImage
    var location: String
    var dateTaken: String
}
