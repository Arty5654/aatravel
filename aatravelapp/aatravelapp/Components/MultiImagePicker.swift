//
//  MultiImagePicker.swift
//  aatravelapp
//
//  Created by Arteom Avetissian on 4/15/25.
//

import SwiftUI
import PhotosUI
import CoreLocation

struct MultiImagePicker: UIViewControllerRepresentable {
    var onImagesPicked: ([ImageMetadata]) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 0
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: MultiImagePicker

        init(_ parent: MultiImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            var imageMetadataList: [ImageMetadata] = []
            let group = DispatchGroup()

            for result in results {
                guard let assetId = result.assetIdentifier else { continue }
                let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil)

                guard let asset = fetchResult.firstObject else { continue }

                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                    if let image = object as? UIImage {
                        let location = asset.location
                        let date = asset.creationDate

                        var locationString = "Unknown Location"
                        var dateString = "Unknown Date"

                        if let date = date {
                            let formatter = DateFormatter()
                            formatter.dateFormat = "MM/dd/yy"
                            dateString = formatter.string(from: date)
                        }

                        if let loc = location {
                            let geocoder = CLGeocoder()
                            geocoder.reverseGeocodeLocation(loc) { placemarks, _ in
                                if let placemark = placemarks?.first {
                                    let parts = [placemark.name, placemark.locality, placemark.administrativeArea, placemark.country].compactMap { $0 }
                                    locationString = parts.joined(separator: ", ")
                                }

                                imageMetadataList.append(ImageMetadata(image: image, location: locationString, dateTaken: dateString))
                                group.leave()
                            }
                        } else {
                            imageMetadataList.append(ImageMetadata(image: image, location: locationString, dateTaken: dateString))
                            group.leave()
                        }
                    } else {
                        group.leave()
                    }
                }
            }

            group.notify(queue: .main) {
                self.parent.onImagesPicked(imageMetadataList)
            }
        }
    }
}
