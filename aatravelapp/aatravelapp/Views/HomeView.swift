//
//  HomeView.swift
//  aatravelapp
//
//  Created by Allen Chang on 8/4/24.
//

import SwiftUI

struct HomeView: View {
    @State private var searchText = ""

    var body: some View {
        VStack {
            // Search Bar
            SearchBar(text: $searchText)
                .padding(.horizontal)
                .padding(.top, 10)
            
            ScrollView {
                VStack(spacing: 16) {
                    // Gray box elements, 5 at the moment
                    ForEach(0..<5) { _ in
                        GrayBoxView()
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
    }
}

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

struct GrayBoxView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // Top bar with account name
            HStack {
                Text("Account Name")
                    .font(.subheadline)
                Spacer()
                Image(systemName: "ellipsis")
                    .foregroundColor(.gray)
            }
            .padding([.horizontal], 4)

            // Image (Gray Box)
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 400)
            
            // Buttons below the image
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "heart")
                    Image(systemName: "message")
                    Image(systemName: "paperplane")
                }
                Spacer()
            }
            .font(.system(size: 24))
            .padding([])
            
            // Caption
            Text("Creative captions effortlessly capture attention, conveying messages with concise brilliance.")
                .font(.footnote)
            
            // View comments text
            Text("View comments")
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .padding(.bottom)
    }
}

#Preview {
    HomeView()
}
