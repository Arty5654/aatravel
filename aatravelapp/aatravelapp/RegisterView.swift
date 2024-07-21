//
//  RegisterView.swift
//  Todo Practice
//
//  Created by Allen Chang on 7/9/24.
//

import SwiftUI

struct RegisterView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack {
            Text("Sign up")
                .font(.headline)
                .padding(.top, 50)
            
            VStack(alignment: .leading) {
 
                HStack {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    Spacer()
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
                
                SecureField("Password", text: $password)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                
            }
            .padding(.vertical)
            
            Button {
                createAccount()
            } label: {
                Text("Continue")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding(.top, 10)
            
            Text("or")
                .padding(.top, 10)
            
            VStack {
                ContinueWithButton(text: "Continue with Apple", imageName: "applelogo")
                ContinueWithButton(text: "Continue with Google", imageName: "globe")
                ContinueWithButton(text: "Continue with Facebook", imageName: "f.square.fill")
            }
            .padding(.top, 10)
            
            Spacer()
        }
        .padding()
    }
    
    func createAccount() {
            guard let url = URL(string: "http://127.0.0.1:8000/api/register/") else {
                print("Invalid URL")
                return
            }
            
            let newAccount = Account(email: email, password: password, created_at: "")
            
            guard let encoded = try? JSONEncoder().encode(newAccount) else {
                print("Failed to encode account")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = encoded
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    if let decodedResponse = try? JSONDecoder().decode(Account.self, from: data) {
                        print("Account created: \(decodedResponse)")
                    } else {
                        print("Invalid response from server")
                    }
                } else {
                    print("Error: \(error?.localizedDescription ?? "Unknown error")")
                }
            }.resume()
        }
    }

struct ContinueWithButton: View {
    var text: String
    var imageName: String
    
    var body: some View {
        Button(action: {}) {
            HStack {
                Image(systemName: imageName)
                Text(text)
                    .font(.subheadline)
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .padding(.top, 5)
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
