//
//  ViewController.swift
//  SeeFood
//
//  Created by Brian MacPherson on 21/5/2018.
//  Copyright © 2018 Brian MacPherson. All rights reserved.
//

import UIKit
import SVProgressHUD
import ChameleonFramework
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var againButton: UIButton!
    @IBOutlet weak var navTitle: UINavigationItem!
    
    let imagePicker = UIImagePickerController()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let navBar = navigationController?.navigationBar {
            navBar.barTintColor = UIColor.flatPurple()
            navBar.tintColor = UIColor.flatWhite()
            navBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.flatWhite()]
            navTitle.title = "SeeFood"
        }
        
        imageView.backgroundColor = UIColor.flatPurple()
        logoView.image = UIImage(named: "hotdog")
        againButton.isHidden = true
        
        
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
                self.imageView.backgroundColor = UIColor.flatBlack()
                self.logoView.isHidden = true
                self.againButton.backgroundColor = UIColor.flatPurple()
                self.againButton.tintColor = UIColor.flatWhite()
                self.againButton.isHidden = false
                
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
    
    
    @IBAction func againButtonPressed(_ sender: UIButton) {
        self.againButton.isHidden = true
        self.imageView.image = nil
        self.imageView.backgroundColor = UIColor.flatPurple()
        self.logoView.isHidden = false
    }
    


}

