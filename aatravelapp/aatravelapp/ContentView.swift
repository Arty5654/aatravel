//
//  ContentView.swift
//  aatravelapp
//
//  Created by Arteom Avetissian on 6/30/24.
//

import SwiftUI

struct ContentView: View {
    @State var accounts = [Account]()
    
    var body: some View {
        NavigationView {
            VStack {
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
                
                NavigationLink(destination: RegisterView()) {
                    Text("Register")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Accounts")
            .onAppear(perform: loadAccount)
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

#Preview {
    ContentView()
}
