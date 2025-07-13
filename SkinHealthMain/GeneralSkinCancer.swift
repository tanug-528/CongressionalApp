import SwiftUI
import PhotosUI
import Vision

struct GeneralSkinCancer: View {
    @State private var image: UIImage?
    @State private var classification: String = "No image yet"
    @State private var showingPicker = false
    @State private var useCamera = false

    var body: some View {
        ZStack {
            Text("General Skin Cancer Test")
            // Gradient background (matches the palette)
            LinearGradient(
                gradient: Gradient(colors: [color1, color2, color3, color4]),
                startPoint: .top,
                endPoint: .bottom
            ).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 50) {
                // "Card" for image and result
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.white.opacity(0.85))
                    .shadow(radius: 8, y: 4)
                    .overlay(
                        VStack(spacing: 16) {
                            // Image Preview
                            if let img = image {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 18))
                                    .padding(.top, 12)
                            } else {
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(color3.opacity(0.6))
                                    //.frame(width: 300, height: 300)
                                    .overlay(Text("No Image Selected").foregroundColor(color1))
                                    
                            }
                            
                            // Classification Result
                            Text(classification)
                                .font(.title2.bold())
                                .foregroundColor(color1)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .padding(.bottom, 6)
                        }
                    )
                    .padding(.horizontal)
                
                // Buttons
                HStack(spacing: 18) {
                    Button(action: {
                        useCamera = true
                        showingPicker = true
                    }) {
                        HStack {
                            Image(systemName: "camera")
                            Text("Take Photo")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(color2)
                        .foregroundColor(.white)
                        .font(.title3.bold())
                        .cornerRadius(18)
                        .shadow(radius: 2)
                    }
                    .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))

                    Button(action: {
                        useCamera = false
                        showingPicker = true
                    }) {
                        HStack {
                            Image(systemName: "photo")
                            Text("Upload Photo")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(color3)
                        .foregroundColor(.white)
                        .font(.title3.bold())
                        .cornerRadius(18)
                        .shadow(radius: 2)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 80)
            .sheet(isPresented: $showingPicker) {
                if useCamera {
                    CameraPicker(image: $image, onImagePicked: classify)
                } else {
                    PhotoPicker(image: $image, onImagePicked: classify)
                }
            }
        }
    }

    func classify(_ uiImage: UIImage) {
        guard let ciImage = CIImage(image: uiImage) else { return }
        classification = "Classifying…"

        guard let model = try? VNCoreMLModel(for: GeneralSkinCancer_1().model) else {
            classification = "Failed to load model."
            return
        }

        let request = VNCoreMLRequest(model: model) { request, _ in
            if let result = request.results?.first as? VNClassificationObservation {
                DispatchQueue.main.async {
                    self.classification = "\(result.identifier) (\(String(format: "%.1f", result.confidence * 100))%)"
                }
            } else {
                DispatchQueue.main.async {
                    self.classification = "No Skin Cancer Detected"
                }
            }
        }
        request.imageCropAndScaleOption = .centerCrop

        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }

    // Custom palette
    let color1 = Color(red: 103/255, green: 138/255, blue: 134/255)
    let color2 = Color(red: 139/255, green: 173/255, blue: 155/255)
    let color3 = Color(red: 182/255, green: 213/255, blue: 176/255)
    let color4 = Color(red: 246/255, green: 247/255, blue: 195/255)
}



// MARK: - Photo Library
struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var onImagePicked: (UIImage) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_: PHPickerViewController, context _: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        init(_ parent: PhotoPicker) { self.parent = parent }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let item = results.first?.itemProvider,
                  item.canLoadObject(ofClass: UIImage.self)
            else { return }

            item.loadObject(ofClass: UIImage.self) { img, _ in
                if let uiImage = img as? UIImage {
                    DispatchQueue.main.async {
                        self.parent.image = uiImage
                        self.parent.onImagePicked(uiImage)
                    }
                }
            }
        }
    }
}

// MARK: - Camera
struct CameraPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var onImagePicked: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_: UIImagePickerController, context _: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraPicker
        init(_ parent: CameraPicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true)
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
                parent.onImagePicked(uiImage)
            }
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSkinCancer()
    }
}
