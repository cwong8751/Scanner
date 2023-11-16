//
//  PhotoCaptureView.swift
//  Scanner
//
//  Created by carl on 15/3/2022.
//

import SwiftUI

struct PhotoCaptureView: View {

    @Binding var showImagePicker: Bool
    @Binding var image: UIImage?

    var body: some View {
        ImagePicker(isShown: $showImagePicker, image: $image)
    }
}

#if DEBUG
struct PhotoCaptureView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoCaptureView(showImagePicker: .constant(false), image: .constant(UIImage(contentsOfFile: "")))
    }
}
#endif
