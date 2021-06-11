//
//  ViewController.swift
//  Project13
//
//  Created by Azat Kaiumov on 09.06.2021.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var intensity: UISlider!
    @IBOutlet var radius: UISlider!
    @IBOutlet var changeFilterButton: UIButton!
    
    private var context: CIContext!
    private var currentFilterName: String! {
        didSet {
            setFilter(name: currentFilterName)
        }
    }
    
    private var currentFilter: CIFilter!
    private var currentImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        context = CIContext()
        currentFilterName = "CISepiaTone"
    }
    
    private func setFilter(name: String) {
        currentFilter = CIFilter(name: name)
        changeFilterButton.setTitle(name, for: .normal)
        
        let inputKeys = currentFilter.inputKeys
        radius.isHidden = !inputKeys.contains(kCIInputRadiusKey)
        
        guard currentImage != nil else {
            return
        }
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyProcessing()
    }
    
    @IBAction func intensityChanged(_ sender: UISlider) {
        applyProcessing()
    }
    
    @IBAction func radiusChanged(_ sender: UISlider) {
        applyProcessing()
    }
    
    @IBAction func save(_ sender: UIButton) {
        guard let image = imageView.image else {
            let alert = UIAlertController(
                title: "Error",
                message: "The image is required!",
                preferredStyle: .alert
            )
            
            alert.addAction(.init(title: "Ok", style: .default))
            present(alert, animated: true)
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(
            image,
            self,
            #selector(image(_:didFinishSavingWithError:contextInfo:)),
            nil
        )
    }
    
    @IBAction func changeFilter(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Choose effect",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        alert.addAction(.init(title: "Cancel", style: .cancel))
        
        let effects = [
            "CIBumpDistortion",
            "CIGaussianBlur",
            "CIPixellate",
            "CISepiaTone",
            "CITwirlDistortion",
            "CIUnsharpMask",
            "CIVignette"
        ]
        
        for effect in effects {
            let action = UIAlertAction(
                title: effect,
                style: .default,
                handler: {
                    [weak self] action in
                    guard let title = action.title else {
                        return
                    }
                    
                    self?.currentFilterName = title
                }
            )
            
            alert.addAction(action)
        }
        
        present(alert, animated: true)
    }
    
    @IBAction func importPicture(_ sender: UIBarButtonItem) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        
        present(picker, animated: true)
    }
    
    func applyProcessing() {
        guard let image = currentFilter.outputImage else {
            return
        }
        
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
        }
        
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(radius.value * 200, forKey: kCIInputRadiusKey)
        }
        
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey)
        }
        
        if inputKeys.contains(kCIInputCenterKey) {
            currentFilter.setValue(
                CIVector(
                    x: currentImage.size.width / 2,
                    y: currentImage.size.height / 2
                ),
                forKey: kCIInputCenterKey
            )
        }
        
        guard let cgImage = context.createCGImage(image, from: image.extent) else {
            return
        }
        
        imageView.image = UIImage(cgImage: cgImage)
    }
}

// MARK: - Photolibrary Methods
extension ViewController {
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        let title: String
        let message: String
        
        if let error = error {
            title = "Save error"
            message = error.localizedDescription
        } else {
            title = "Saved!"
            message = "Your altered image has been saved to your photos."
        }
        
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        
        picker.dismiss(animated: true)
        currentImage = image
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyProcessing()
    }
}
