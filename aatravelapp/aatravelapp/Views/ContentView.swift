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
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var userEmail: String?  // State for holding the logged-in user's email
    @State private var isLoggedIn = false // State to track if the user is logged in
    
    var body: some View {
        NavigationView {
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
                .navigationTitle("Accounts")
                .onAppear(perform: loadAccount)
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
                
                Spacer()
                
                // Add the "Upload Photo" button here
                Button(action: {
                    showImagePicker = true
                }) {
                    Text("Upload Photo")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
                
                // Display selected image
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .padding()
                }
            }
        }
        // Image Picker sheet
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }
    
    // Function to load accounts from API
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


// ImagePicker to pick photos from photo library
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        // Handle selected image
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = uiImage
                uploadImage(image: uiImage)  // Upload image after picking
            }
            picker.dismiss(animated: true)
        }
        
        // Function to upload image
        func uploadImage(image: UIImage) {
            guard let url = URL(string: "http://127.0.0.1:8000/api/upload/") else { return }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let boundary = UUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            var data = Data()
            data.append("--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            data.append(image.jpegData(compressionQuality: 0.5)!)
            data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
            
            request.httpBody = data
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Upload failed: \(error)")
                    return
                }
                if let error = error {
                    print("Upload failed Debug: \(error.localizedDescription)")
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("Status code: \(httpResponse.statusCode)")
                }

                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Response from server: \(responseString)")
                }
                print("Upload successful")
            }.resume()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
