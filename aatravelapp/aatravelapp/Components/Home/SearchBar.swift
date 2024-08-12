//
//  Searchbar.swift
//  aatravelapp
//
//  Created by Allen Chang on 8/10/24.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String

        var body: some View {
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Explore Destinations!", text: $text)
                        .padding(7)
                        .padding(.leading, -5)  // Adjust padding to move text closer to the icon
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
        }
}


#Preview {
    HomeView()
}
