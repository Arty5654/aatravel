//
//  GoogleSignIn.swift
//  aatravelapp
//
//  Created by Arteom Avetissian on 7/22/24.
//

import SwiftUI
import GoogleSignIn

struct GoogleSignInButton: UIViewRepresentable {
    func makeUIView(context: Context) -> GIDSignInButton {
        let button = GIDSignInButton()
        button.style = .wide
        return button
    }

    func updateUIView(_ uiView: GIDSignInButton, context: Context) {}
}
