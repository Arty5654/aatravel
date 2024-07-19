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
                    Spacer()
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
                
                TextField("Password", text: $password)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                
            }
            .padding(.vertical)
            
            Button {
                //atempt login
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
