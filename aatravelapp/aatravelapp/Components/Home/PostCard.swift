//
//  PostCard.swift
//  aatravelapp
//
//  Created by Allen Chang on 8/10/24.
//

import SwiftUI

struct PostCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // Top bar with account name
            HStack {
                Text("Account Name")
                    .font(.subheadline)
                Spacer()
                Image(systemName: "circle")
                    .foregroundColor(.gray)
            }
            .padding([.horizontal], 4)

            // Image (Gray Box)
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 400)
            

            
            // Info below the image
            VStack(alignment: .leading, spacing: 4) {
                
                HStack {
                    Text("Location")
                        .font(.headline)
                        .font(.system(size: 16))
                }


                
                // Caption
                Text("Creative captions effortlessly capture attention, conveying messages with concise brilliance.")
                    .font(.caption)
                

            }
            .padding([.horizontal], 4)
            
            
        }
        .padding(.bottom)
    }
}

#Preview {
    HomeView()
}

