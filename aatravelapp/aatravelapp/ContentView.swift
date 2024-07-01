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
            List {
                ForEach(accounts, id: \.self) { item in
                    HStack {
                        Image(systemName: "banknote").foregroundColor(.green)
                        Text(item.name)
                        Spacer()
                        Text("\(item.balance)")
                    }
                }
            }
            .navigationTitle("Accounts")
            .onAppear(perform: loadAccount)
        }
    }
    
    func loadAccount() {
        guard let url = URL(string: "http://127.0.0.1:8000/api/account/") else {
            print("API is down")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Basic YXJ0ZW9tYXZldGlzc2lhbjpMb2xhaXMxMCE=", forHTTPHeaderField: "Authorization")
        
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

