//
//  RegisterView.swift
//  Todo Practice
//
//  Created by Allen Chang on 7/9/24.
//

import SwiftUI
import GoogleSignIn

struct RegisterView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    
    var onSuccess: (String) -> Void  // Callback for when registration is successful
    
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
                GoogleSignInButton()
                    .frame(height: 50)
                    .padding(.horizontal, 16)
                    .onTapGesture {
                        handleGoogleSignIn()
                    }
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
                    DispatchQueue.main.async {
                        self.onSuccess(decodedResponse.email)  // Trigger the callback to update the email in ContentView
                    }
                } else {
                    print("Invalid response from server")
                }
            } else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()
    }
    
    func handleGoogleSignIn() {
        let clientID = "159502750934-pbonh3cktif9c1rarfvf01vifd4jo14b.apps.googleusercontent.com";

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)

        GIDSignIn.sharedInstance.signIn(with: config, presenting: getRootViewController()) { user, error in
            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
                return
            }

            guard let authentication = user?.authentication, let idToken = authentication.idToken else { return }

            // Send the token to your Django backend
            sendTokenToBackend(idToken: idToken)
        }
    }

    func sendTokenToBackend(idToken: String) {
        guard let url = URL(string: "http://127.0.0.1:8000/api/google-login/") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = ["token": idToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending token to backend: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received from backend")
                return
            }

            // Handle the response from the backend
            if let decodedResponse = try? JSONDecoder().decode([String: String].self, from: data), let userEmail = decodedResponse["email"] {
                DispatchQueue.main.async {
                    self.onSuccess(userEmail)  // Trigger the callback with the email
                }
            }
        }.resume()
    }

    func getRootViewController() -> UIViewController {
        return UIApplication.shared.windows.first?.rootViewController ?? UIViewController()
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

//struct RegisterView_Previews: PreviewProvider {
//    static var previews: some View {
//        RegisterView()
//    }
//}
