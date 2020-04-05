//
//  MeView.swift
//  HotProspects
//
//  Created by dominator on 03/04/20.
//  Copyright © 2020 dominator. All rights reserved.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct MeView: View {
    @State private var name = "Anonymous"
    @State private var emailAddress = ""
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    var body: some View {
        NavigationView {
            VStack{
                TextField("Name", text: $name)
                    .textContentType(.name)
                    .font(.title)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(UIColor.secondarySystemBackground))
                        .shadow(radius: 5)
                    )
                    .padding()

                TextField("Email address", text: $emailAddress)
                    .textContentType(.emailAddress)
                    .font(.title)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(UIColor.secondarySystemBackground))
                        .shadow(radius: 5)
                    )
                    .padding(.horizontal)
                    .padding(.bottom)
                
                Image(uiImage: genrateQrCode(from: "\(name)\n\(emailAddress)"))
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(UIColor.tertiarySystemGroupedBackground))
                        .shadow(radius: 5)
                )
                    .padding(.bottom)
                
                Button("Save to gallery"){
                    ImageSaver().saveImageToLibrary(self.genrateQrCode(from: "\(self.name)\n\(self.emailAddress)"))
                }
                .foregroundColor(.white)
                .padding()
                .background(Capsule().fill(Color.accentColor))
                
                Spacer()
            }
            .navigationBarTitle("Your Code")
        }
    }
    
    func genrateQrCode(from string: String) -> UIImage{
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")
        
        if let outputImage = filter.outputImage{
            if let cgImage =  context.createCGImage(outputImage, from: outputImage.extent){
                return UIImage(cgImage: cgImage)
            }
        }
        
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

struct MeView_Previews: PreviewProvider {
    static var previews: some View {
        MeView()
    }
}
