//
//  ViewController.swift
//  SeeFood
//
//  Created by Brian MacPherson on 21/5/2018.
//  Copyright © 2018 Brian MacPherson. All rights reserved.
//

import UIKit
import SVProgressHUD
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var navTitle: UINavigationItem!
    
    let imagePicker = UIImagePickerController()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        navTitle.title = "SeeFood"
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could Not Convert to CIImage.")
            }
            SVProgressHUD.show()
            detect(image: ciimage)
        }
        
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model Failed.")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navTitle.title = "Hotdog!"
                } else {
                    self.navTitle.title = "Not Hotdog!"
                }
                SVProgressHUD.dismiss()
                
            }
        }
       
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print("Error performing handler, \(error)")
        }
        
    }
    
    
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    


}

