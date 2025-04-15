import SwiftUI
import Foundation

struct HomeView: View {
    // Check if user is logged in
    @EnvironmentObject var session: UserSession
    var isLoggedIn: Bool {
        session.isLoggedIn
    }
    var userUUID: String {
        session.userUUID ?? "N/A"
    }
    
    @State private var searchText = ""
    @State private var selectedOption: String = "Explore"
    @State private var userEmail: String = "user@example.com"
    //@AppStorage("userUUID") var userUUID: String = "N/A"
    
    // Boolean to check if the user is logged in
    //@State private var isLoggedIn: Bool = false  // Set to false initially

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
            NavigationStack {
                    CreatePostView()
                }
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
                        session.logout()
                    })
                    .tabItem {
                        Image(systemName: "person")
                        Text("Profile")
                    }
            } else {
                RegisterView(onSuccess: { email in
                    // This gets called after successful registration/login
                    session.userUUID = UserDefaults.standard.string(forKey: "userUUID")
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
