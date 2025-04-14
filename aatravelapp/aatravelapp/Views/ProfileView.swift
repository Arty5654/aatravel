//
//  ProfileView.swift
//  aatravelapp
//
//  Created by Allen Chang on 10/25/24.
//

import SwiftUI

struct ProfileView: View {
    @AppStorage("userEmail") var userEmail: String = "unknown@example.com"
    @AppStorage("userUUID") var userUUID: String = "N/A"
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var statusMessage: String?
    var onLogout: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)

                    Text("My Profile")
                        .font(.largeTitle)
                        .bold()
                }
                .padding(.top)

                // User Info
                VStack(alignment: .leading, spacing: 10) {
                    Text("Account Info")
                        .font(.headline)

                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.1))
                        .overlay(
                            HStack {
                                Text("Email:")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text(userEmail)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.trailing)
                            }
                            .padding()
                        )
                        .frame(height: 50)
                }
                .padding(.horizontal)

                // Change Password
                VStack(alignment: .leading, spacing: 10) {
                    Text("Change Password")
                        .font(.headline)

                    SecureField("New Password", text: $newPassword)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)

                    SecureField("Confirm Password", text: $confirmPassword)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)

                    Button(action: changePassword) {
                        Text("Update Password")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    if let message = statusMessage {
                        Text(message)
                            .font(.footnote)
                            .foregroundColor(.blue)
                            .padding(.top, 4)
                    }
                }
                .padding(.horizontal)

                // Log out
                Button(role: .destructive) {
                    logout()
                } label: {
                    Text("Log Out")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
    }

    func changePassword() {
        guard !newPassword.isEmpty else {
            statusMessage = "Password cannot be empty"
            return
        }

        guard newPassword == confirmPassword else {
            statusMessage = "Passwords do not match"
            return
        }

        guard let url = URL(string: "http://127.0.0.1:8000/api/change-password/") else {
            statusMessage = "Invalid backend URL"
            return
        }
        
        print("uuid: " + userUUID)

        let payload: [String: String] = [
            "uuid": userUUID,
            "new_password": newPassword
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            statusMessage = "Failed to encode request"
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    statusMessage = "Network error: \(error.localizedDescription)"
                    return
                }

                guard let data = data,
                      let responseDict = try? JSONSerialization.jsonObject(with: data) as? [String: String] else {
                    statusMessage = "Unexpected response from server"
                    return
                }

                if let message = responseDict["message"] {
                    statusMessage = message
                    newPassword = ""
                    confirmPassword = ""
                } else {
                    statusMessage = responseDict["error"] ?? "Unknown error occurred"
                }
            }
        }.resume()
    }


    func logout() {
        guard let url = URL(string: "http://127.0.0.1:8000/api/logout/") else {
            statusMessage = "Invalid logout URL"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.statusMessage = "Logout error: \(error.localizedDescription)"
                    return
                }
                UserDefaults.standard.removeObject(forKey: "userEmail")
                UserDefaults.standard.removeObject(forKey: "userUUID")
                self.statusMessage = "Logged out successfully."
                self.onLogout()
            }
        }.resume()
    }

}

//#Preview {
//    ProfileView()
//}
