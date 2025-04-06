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

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account Info")) {
                    HStack {
                        Text("Email:")
                        Spacer()
                        Text(userEmail).foregroundColor(.gray)
                    }

                }

                Section(header: Text("Change Password")) {
                    SecureField("New Password", text: $newPassword)
                    SecureField("Confirm Password", text: $confirmPassword)

                    Button(action: changePassword) {
                        Text("Update Password")
                            .frame(maxWidth: .infinity)
                    }
                }

                if let message = statusMessage {
                    Section {
                        Text(message).foregroundColor(.blue)
                    }
                }

                Section {
                    Button(role: .destructive) {
                        logout()
                    } label: {
                        Text("Log Out")
                    }
                }
            }
            .navigationTitle("My Profile")
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

        // 🔒 Integrate with backend
        statusMessage = "Password updated successfully!"
        newPassword = ""
        confirmPassword = ""
    }

    func logout() {
        userEmail = ""
        userUUID = ""
        statusMessage = "Logged out."
    }
}


#Preview {
    ProfileView()
}
