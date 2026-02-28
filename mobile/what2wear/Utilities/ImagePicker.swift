import SwiftUI
import PhotosUI
import UIKit

// MARK: - Photo Library (PHPickerViewController — iOS 14+)

/// Usage: `.sheet(isPresented: $show) { PhotoPicker(image: $viewModel.selfieImage) }`
struct PhotoPicker: UIViewControllerRepresentable {

    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config          = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 1
        config.filter         = .images
        let picker          = PHPickerViewController(configuration: config)
        picker.delegate     = context.coordinator
        return picker
    }

    func updateUIViewController(_ vc: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        init(_ p: PhotoPicker) { parent = p }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()
            guard let result = results.first else { return }
            result.itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                guard let img = object as? UIImage else { return }
                DispatchQueue.main.async { self.parent.image = img }
            }
        }
    }
}

// MARK: - Camera (UIImagePickerController)

/// Usage: `.fullScreenCover(isPresented: $show) { CameraPicker(image: $viewModel.selfieImage).ignoresSafeArea() }`
/// Falls back to photo library on Simulator (no camera hardware).
struct CameraPicker: UIViewControllerRepresentable {

    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker           = UIImagePickerController()
        let hasCamera        = UIImagePickerController.isSourceTypeAvailable(.camera)
        picker.sourceType    = hasCamera ? .camera : .photoLibrary
        if hasCamera { picker.cameraDevice = .front }  // only set on real hardware
        picker.allowsEditing = true
        picker.delegate      = context.coordinator
        return picker
    }

    func updateUIViewController(_ vc: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject,
                             UIImagePickerControllerDelegate,
                             UINavigationControllerDelegate {
        let parent: CameraPicker
        init(_ p: CameraPicker) { parent = p }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            let img = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage
            parent.image = img
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
