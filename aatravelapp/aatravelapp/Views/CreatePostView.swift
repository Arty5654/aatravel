import SwiftUI
import Photos
import UIKit
import CoreLocation // for reverse geocoding

struct CreatePostView: View {
    // Check if user is logged in
    @EnvironmentObject var session: UserSession
    var isLoggedIn: Bool {
        session.isLoggedIn
    }
    var userUUID: String {
        session.userUUID ?? "N/A"
    }
    
    
    @State private var showMultiPicker = false
    @State var caption: String = ""
    // @AppStorage("userUUID") var userUUID: String = "N/A"
    @State var locationString: String = "Unknown Location"
    @State var dateString: String = "Unknown Date"
//    var isLoggedIn: Bool {
//        UUID(uuidString: userUUID) != nil && userUUID != "N/A"
//    }
    
    @State private var selectedImages: [ImageMetadata] = []
    
    // Boolean bc upload happens twice for whatever reason
    @State private var hasUploaded = false
    
    
    // Track Photo Library auth status (for debugging or gating)
    @State private var authStatus: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if !isLoggedIn {
                    VStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.badge.exclamationmark")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.red)
                        
                        Text("Please log in or create an account to post.")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                        
                        NavigationLink(destination: RegisterView(onSuccess: { _ in })) {
                            Text("Go to Login/Register")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.orange)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                    .padding()
                } else {
                    VStack(spacing: 16) {
                        
                        // Select images
                        Button(action: {
                            showMultiPicker = true
                        }) {
                            Text("Select Images")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                        .sheet(isPresented: $showMultiPicker) {
                            MultiImagePicker { images in
                                self.selectedImages = images
                            }
                        }
                        
                        // Caption
                        TextField("Write a caption...", text: $caption)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            .foregroundColor(.black)
                            .padding(.horizontal)

                        // Selected Images Carousel
                        if !selectedImages.isEmpty {
                            VStack(spacing: 8) {
                                Text("Swipe through selected photos")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                TabView {
                                    ForEach(selectedImages) { item in
                                        VStack(spacing: 8) {
                                            Image(uiImage: item.image)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 200)
                                                .cornerRadius(12)
                                            
                                            Text("📍 \(item.location)")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            Text("📅 \(item.dateTaken)")
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                                .frame(height: 300)
                            }
                        }
                        
                        // Upload Button
                        Button(action: {
                            if selectedImages.isEmpty {
                                print("No images selected, cannot upload.")
                                return
                            }

                            for _ in selectedImages {
                                guard !hasUploaded else { return }
                                hasUploaded = true
                                uploadPost(caption: caption, userUUID: userUUID)
                            }
                        }) {
                            Text("Upload Post")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.black)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
    }

    func uploadPost(caption: String, userUUID: String) {
        guard let url = URL(string: "http://127.0.0.1:8000/api/upload-post/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var data = Data()

        // Add caption
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"caption\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(caption)\r\n".data(using: .utf8)!)

        // Add UUID
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"uuid\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(userUUID)\r\n".data(using: .utf8)!)

        // Loop through all selected images
        for (index, imageData) in selectedImages.enumerated() {
            let fieldImage = "image_\(index)"
            let fieldLocation = "location_\(index)"
            let fieldDate = "date_taken_\(index)"

            // Image
            data.append("--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(fieldImage)\"; filename=\"photo\(index).jpg\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            data.append(imageData.image.jpegData(compressionQuality: 0.7)!)
            data.append("\r\n".data(using: .utf8)!)

            // Location
            data.append("--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(fieldLocation)\"\r\n\r\n".data(using: .utf8)!)
            data.append("\(imageData.location)\r\n".data(using: .utf8)!)

            // Date Taken
            data.append("--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(fieldDate)\"\r\n\r\n".data(using: .utf8)!)
            data.append("\(imageData.dateTaken)\r\n".data(using: .utf8)!)
        }

        data.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = data

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Upload failed: \(error.localizedDescription)")
                return
            }
            print("Upload successful")
            hasUploaded = false;
        }.resume()
    }
}
