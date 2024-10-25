//
//  ContentView.swift
//  aatravelapp
//
//  Created by Arteom Avetissian on 6/30/24.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @State var accounts = [Account]()
    @State private var userEmail: String?  // State for holding the logged-in user's email
    @State private var isLoggedIn = false  // State to track if the user is logged in
    
    var body: some View {
        TabView {
            AccountsView(accounts: $accounts, userEmail: $userEmail, isLoggedIn: $isLoggedIn)
                .tabItem {
                    Label("Accounts", systemImage: "person.3.fill")
                }
            
            CreatePostView(userEmail: userEmail ?? "")
                .tabItem {
                    Label("Create Post", systemImage: "plus.circle.fill")
                }
        }
    }
    
    func loadAccount() {
        guard let url = URL(string: "http://127.0.0.1:8000/api/accounts/") else {
            print("API is down")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let response = try? JSONDecoder().decode([Account].self, from: data) {
                    DispatchQueue.main.async {
                        self.accounts = response
                    }
                    return
                }
            }
        }.resume()
    }
}

// A separate view to display the list of accounts
struct AccountsView: View {
    @Binding var accounts: [Account]
    @Binding var userEmail: String?
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        VStack {
            if let email = userEmail {
                HStack {
                    Spacer()
                    Text("Welcome, \(email)")
                        .padding()
                        .background(Color.gray.opacity(0.2))
                }
                .padding(.top, 10)
            }

            List {
                ForEach(accounts, id: \.self) { item in
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "person").foregroundColor(.blue)
                            Text(item.email)
                        }
                        Text("Created at: \(item.created_at)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .onAppear {
                // Add your function to load accounts here
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isLoggedIn {
                        Text("Signed In")
                            .foregroundColor(.gray)
                    } else {
                        NavigationLink(destination: RegisterView(onSuccess: { email in
                            self.userEmail = email
                            self.isLoggedIn = true
                        })) {
                            Text("Register")
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.blue)
                                .cornerRadius(5)
                        }
                    }
                }
            }
        }
    }
}
