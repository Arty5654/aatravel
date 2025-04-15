import SwiftUI
import Photos
import UIKit
import CoreLocation // for reverse geocoding

struct CreatePostView: View {
    // Your original states
    @State var selectedImage: UIImage?
    @State var showLegacyPicker = false
    @State var caption: String = ""
    //@State var userEmail: String
    @AppStorage("userUUID") var userUUID: String = "N/A"
    @State var locationString: String = "Unknown Location"
    @State var dateString: String = "Unknown Date"
    var isLoggedIn: Bool {
        UUID(uuidString: userUUID) != nil && userUUID != "N/A"
    }

    
    // Track Photo Library auth status (for debugging or gating)
    @State private var authStatus: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)

    var body: some View {
        VStack {
            if !isLoggedIn {
                VStack(spacing: 16) {
                    Image(systemName: "person.crop.circle.badge.exclamationmark")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.red)
                    
                    Text("Please log in or create an account to post.")
                        .multilineTextAlignment(.center)
                        .font(.headline)
                    
                    NavigationLink(destination: RegisterView(onSuccess: { _ in })) {
                        Text("Go to Login/Register")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
            } else {
                
                VStack(spacing: 16) {
                    Text("Current Auth Status: \(authStatus.rawValue)")
                    
                    // Show selected image
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                    }
                    
                    // Button to pick an image
                    Button("Select Image") {
                        // If you want to request permission first if .notDetermined:
                        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
                        if status == .notDetermined {
                            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                                DispatchQueue.main.async {
                                    authStatus = newStatus
                                    if newStatus == .authorized || newStatus == .limited {
                                        showLegacyPicker = true
                                    } else {
                                        print("User denied Photo Library access.")
                                    }
                                }
                            }
                        }
                        else if status == .authorized || status == .limited {
                            // Already have permission, just show the picker
                            showLegacyPicker = true
                        } else {
                            print("No photo library access. Prompt user to enable in Settings.")
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    // Editable caption
                    TextField("Add a caption...", text: $caption)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    // Display or edit the auto‐filled metadata
                    VStack(alignment: .leading) {
                        Text("Image Metadata")
                            .font(.headline)
                        TextField("Location", text: $locationString)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        TextField("Date Taken", text: $dateString)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Upload button
                    Button(action: {
                        guard let image = selectedImage else {
                            print("No image selected, cannot upload.")
                            return
                        }
                        uploadPost(
                            image: image,
                            caption: caption,
                            userUUID: userUUID,
                            location: locationString,
                            dateTaken: dateString
                        )
                    }) {
                        Text("Upload Post")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
                // Present the legacy UIImagePickerController as a sheet
                .sheet(isPresented: $showLegacyPicker) {
                    LegacyImagePicker(
                        selectedImage: $selectedImage,
                        location: $locationString,
                        dateTaken: $dateString
                    )
                }
            }
        }
    }
    
    // Your original upload function
    func uploadPost(image: UIImage, caption: String, userUUID: String,
                    location: String, dateTaken: String) {
        guard let url = URL(string: "http://127.0.0.1:8000/api/upload-post/") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var data = Data()

        // Add the image
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        data.append(image.jpegData(compressionQuality: 0.5)!)
        data.append("\r\n".data(using: .utf8)!)

        // Add the caption
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"caption\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(caption)\r\n".data(using: .utf8)!)

        // Add the location
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"location\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(location)\r\n".data(using: .utf8)!)

        // Add the date taken
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"date_taken\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(dateTaken)\r\n".data(using: .utf8)!)

        // User UUID
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"uuid\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(userUUID)\r\n".data(using: .utf8)!)


        // End boundary
        data.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = data

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Upload failed: \(error.localizedDescription)")
                return
            }
            print("Upload successful")
        }.resume()
    }
}

// MARK: - UIImagePickerController Wrapper
struct LegacyImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var location: String
    @Binding var dateTaken: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // no-op
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate {
        let parent: LegacyImagePicker
        
        init(_ parent: LegacyImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            picker.dismiss(animated: true)
            
            // 1) Extract the UIImage
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = uiImage
            } else {
                print("No UIImage found in picker info")
            }
            
            // 2) Extract the PHAsset
            guard let asset = info[.phAsset] as? PHAsset else {
                // Possibly iCloud-only or older iOS
                print("No PHAsset in picker info keys = \(info.keys)")
                parent.location = "Unknown Location"
                parent.dateTaken = "Unknown Date"
                return
            }
            
            // Debug logs
            print("Got PHAsset: \(asset)")
            print("PHAsset location: \(String(describing: asset.location))")
            print("PHAsset creationDate: \(String(describing: asset.creationDate))")
            
            // 3) Reverse geocode the asset's location if available
            if let assetLocation = asset.location {
                let geocoder = CLGeocoder()
                
                geocoder.reverseGeocodeLocation(assetLocation) { placemarks, error in
                    if let error = error {
                        print("Reverse geocode failed: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            self.parent.location = "Unknown Location"
                        }
                        return
                    }
                    guard let placemark = placemarks?.first else {
                        DispatchQueue.main.async {
                            self.parent.location = "Unknown Location"
                        }
                        return
                    }
                    
                    // Build a place string: e.g. "Some Venue, City, State, Country"
                    let name = placemark.name ?? ""
                    let city = placemark.locality ?? ""
                    let state = placemark.administrativeArea ?? ""
                    let country = placemark.country ?? ""
                    
                    let placeComponents = [name, city, state, country]
                        .filter { !$0.isEmpty }
                    let placeString = placeComponents.joined(separator: ", ")
                    
                    DispatchQueue.main.async {
                        self.parent.location = placeString.isEmpty ? "Unknown Location" : placeString
                    }
                }
            } else {
                parent.location = "Unknown Location"
            }
            
            // 4) Format the date as MM/dd/yy
            if let creationDate = asset.creationDate {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yy" // e.g. "03/12/23"
                let formatted = dateFormatter.string(from: creationDate)
                parent.dateTaken = formatted
            } else {
                parent.dateTaken = "Unknown Date"
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
            print("User canceled image picking")
        }
    }
}
