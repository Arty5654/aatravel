//
//  RegisterView.swift
//  Todo Practice
//
//  Created by Allen Chang on 7/9/24.
//
import SwiftUI
import GoogleSignIn

struct RegisterView: View {
    @State private var uuid: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLogin = false // State to toggle between login and sign-up modes
    @State private var errorMessage: String? // State for showing error messages
    
    var onSuccess: (String) -> Void  // Callback for when registration/login is successful
    
    var body: some View {
        VStack {
            Text(isLogin ? "Log in" : "Sign up") // Toggle text based on login/signup mode
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
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.bottom)
            }
            
            Button {
                isLogin ? loginAccount() : createAccount() // Toggle between login and signup
            } label: {
                Text(isLogin ? "Log in" : "Continue")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding(.top, 10)
            
            Button(action: { isLogin.toggle() }) {
                Text(isLogin ? "Don't have an account? Sign up" : "Already have an account? Log in")
                    .padding(.top, 10)
            }
            
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

        let newAccount = ["email": email, "password": password]

        guard let encoded = try? JSONSerialization.data(withJSONObject: newAccount) else {
            print("Failed to encode account")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = encoded

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decoded = try? JSONDecoder().decode(Account.self, from: data) {
                    DispatchQueue.main.async {
                        UserDefaults.standard.set(decoded.uuid, forKey: "userUUID")
                        UserDefaults.standard.set(decoded.email, forKey: "userEmail")
                        self.onSuccess(decoded.email)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Account already exists or invalid data"
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Error: \(error?.localizedDescription ?? "Unknown error")"
                }
            }
        }.resume()
    }
    
    // Struct for login response since we only need email not the entire account data
    struct LoginResponse: Codable {
        let email: String
    }
    
    func loginAccount() {
        guard let url = URL(string: "http://127.0.0.1:8000/api/login/") else {
            print("Invalid URL")
            return
        }

        let loginCredentials = ["email": email, "password": password]

        guard let encoded = try? JSONSerialization.data(withJSONObject: loginCredentials) else {
            print("Failed to encode login credentials")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = encoded

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decoded = try? JSONDecoder().decode(Account.self, from: data) {
                    DispatchQueue.main.async {
                        UserDefaults.standard.set(decoded.uuid, forKey: "userUUID")
                        UserDefaults.standard.set(decoded.email, forKey: "userEmail")
                        self.onSuccess(decoded.email)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Invalid email or password"
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Error: \(error?.localizedDescription ?? "Unknown error")"
                }
            }
        }.resume()
    }
    
    func handleGoogleSignIn() {
        //let clientID = "159502750934-pbonh3cktif9c1rarfvf01vifd4jo14b.apps.googleusercontent.com";
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           let googleServiceInfo = NSDictionary(contentsOfFile: path),
           let clientID = googleServiceInfo["CLIENT_ID"] as? String {
            //print("Client ID:", clientID)
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
        } else {
            print("Failed to load Client ID")
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
                    self.onSuccess(userEmail)
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
