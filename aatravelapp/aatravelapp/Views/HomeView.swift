//
//  HomeView.swift
//  aatravelapp
//
//  Created by Allen Chang on 8/4/24.
//

import SwiftUI

struct HomeView: View {
    @State private var searchText = ""
    @State private var selectedOption: String = "Explore"

    var body: some View {
        TabView {
            VStack {
                
                // Filter section
                VStack {
                    // Search Bar
                    SearchBar(text: $searchText)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    // Following and Explore Options
                    HStack(spacing: 16) {
                        Spacer()
                        Text("Following")
                            .font(.headline)
                            .foregroundColor(selectedOption == "Following" ? .primary : .gray)
                            .underline(selectedOption == "Following")
                            .onTapGesture {
                                selectedOption = "Following"
                            }
                        Text("Explore")
                            .font(.headline)
                            .foregroundColor(selectedOption == "Explore" ? .primary : .gray)
                            .underline(selectedOption == "Explore")
                            .onTapGesture {
                                selectedOption = "Explore"
                            }
                        Spacer()
                    }
                    .padding(.vertical, 12)
                }
                .background(Color.white)
                .shadow(color: .gray.opacity(0.1), radius: 1, x: 1, y: 2)

                // Feed
                ScrollView {
                    VStack(spacing: 16) {
                        // Gray box elements, 5 at the moment
                        ForEach(0..<5) { _ in
                            PostCardView()
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            
            .tabItem {
                Image(systemName: "house")
                    .renderingMode(.original)
                Text("Explore")
            }
            
            // Add more tabs here
            Text("Wishlists View")
                .tabItem {
                    Image(systemName: "heart")
                    Text("Wishlists")
                }
            
            Text("Trips View")
                .tabItem {
                    Image(systemName: "airplane")
                    Text("Trips")
                }
            
            Text("Messages View")
                .tabItem {
                    Image(systemName: "message")
                    Text("Messages")
                }
            
            Text("Profile View")
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
        }
    } // end var: body
} // end struct HomeView

#Preview {
    HomeView()
}


