//
//  ImageTaggingView.swift
//  aatravelapp
//
//  Created by Arteom Avetissian on 4/15/25.
//

import SwiftUI

struct ImageTaggingView: View {
    let image: UIImage
    @Binding var tags: [ImageTag]

    @State private var selectedPosition = CGPoint.zero
    @State private var showTagForm = false
    @State private var tagLabel = ""
    @State private var tagURL = ""
    @State private var tagType: TagType = .custom

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .overlay(
                        Color.clear
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onEnded { value in
                                        selectedPosition = value.location
                                        showTagForm = true
                                    }
                            )
                    )

                ForEach(tags.indices, id: \.self) { index in
                    let tag = tags[index]
                    VStack {
                        Button(action: {
                            if let url = tag.url, let link = URL(string: url) {
                                UIApplication.shared.open(link)
                            }
                        }) {
                            Text("\(tag.type.icon) \(tag.label)")
                                .font(.caption2)
                                .padding(6)
                                .background(Color.black.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(6)
                        }

                        Circle()
                            .fill(Color.orange)
                            .frame(width: 12, height: 12)
                    }
                    .position(tag.position)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newPos = value.location
                                let boundedX = max(0, min(newPos.x, geo.size.width))
                                let boundedY = max(0, min(newPos.y, geo.size.height))
                                tags[index].position = CGPoint(x: boundedX, y: boundedY)
                            }
                    )
                }
            }
            .sheet(isPresented: $showTagForm) {
                VStack(spacing: 16) {
                    Text("Add Tag")
                        .font(.headline)

                    TextField("Label", text: $tagLabel)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    TextField("Optional URL", text: $tagURL)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Picker("Type", selection: $tagType) {
                        ForEach(TagType.allCases) { type in
                            Text(type.icon).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    Button("Add Tag") {
                        tags.append(ImageTag(position: selectedPosition, label: tagLabel, type: tagType, url: tagURL.isEmpty ? nil : tagURL))
                        tagLabel = ""
                        tagURL = ""
                        showTagForm = false
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)

                    Spacer()
                }
                .padding()
            }
        }
    }
}



