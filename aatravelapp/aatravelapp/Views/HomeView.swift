import SwiftUI

struct HomeView: View {
    @State private var searchText = ""
    @State private var selectedOption: String = "Explore"
    @State private var userEmail: String = "user@example.com"
    
    // Boolean to check if the user is logged in
    @State private var isLoggedIn: Bool = false  // Set to false initially

    var body: some View {
        TabView {
            // Explore Tab
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
            
            // Wishlists Tab
            Text("Wishlists View")
                .tabItem {
                    Image(systemName: "heart")
                    Text("Wishlists")
                }
            
            // Create Post Tab
            CreatePostView(userEmail: userEmail)
                .tabItem {
                    Image(systemName: "plus")
                    Text("Create")
                }
            
            // Messages Tab
            Text("Messages View")
                .tabItem {
                    Image(systemName: "message")
                    Text("Messages")
                }
            
            // Profile/Registration Tab
            if isLoggedIn {
                ProfileView(onLogout: {
                    self.isLoggedIn = false
                    self.userEmail = ""
                })
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
            } else {
                RegisterView(onSuccess: { email in
                    self.isLoggedIn = true
                    self.userEmail = email
                })
                .tabItem {
                    Image(systemName: "person")
                    Text("Register")
                }
            }
        }
    }
}



#Preview {
    HomeView()
}
