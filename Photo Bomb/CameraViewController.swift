//
//  CameraViewController.swift
//  Photo Bomb
//
//  Created by Jordan Russell Weatherford on 5/30/17.
//  Copyright © 2017 Jordan Weatherford. All rights reserved.
//

import UIKit
import AVFoundation
import AlamoFire


class CameraViewController: UIViewController, UIImagePickerControllerDelegate, AVCapturePhotoCaptureDelegate {
    

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var captureButton: UIButton!
    
    var captureSession : AVCaptureSession?
    var stillImageOutput : AVCapturePhotoOutput?
    var previewLayer : AVCaptureVideoPreviewLayer?
    var image : UIImage?

    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureButton.layer.zPosition = 100
        previewLayer?.frame = cameraView.bounds
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession = AVCaptureSession()
        
        
        captureSession?.sessionPreset = AVCaptureSessionPresetHigh
        
        let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        var backCameraError : Error?
        var input : AVCaptureDeviceInput?
        
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch {
            backCameraError = error
        }
        
        if backCameraError == nil && (captureSession?.canAddInput(input))! {
            captureSession?.addInput(input)
            stillImageOutput = AVCapturePhotoOutput()
            
            if (captureSession?.canAddOutput(stillImageOutput))! {
                captureSession?.addOutput(stillImageOutput)
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer?.videoGravity = AVLayerVideoGravityResizeAspect
                previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.portrait
                cameraView.layer.addSublayer(previewLayer!)
                captureSession?.startRunning()
            }
        }
    }
    
    
    @IBAction func captureButtonPressed(_ sender: UIButton) {
        didPressTakePhoto()
    }
    
    
    func didPressTakePhoto() {
        if let videoConnection = stillImageOutput?.connection(withMediaType: AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.portrait
            let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecJPEG])
            stillImageOutput?.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    
    //AVPhotoCapture Delegate function
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?){

        if let error = error {
            print(error.localizedDescription)
        }
        
        if let sampleBuffer = photoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: nil){
            image = UIImage(data: dataImage)
        } else {
            print("FAILED AT IMAGE PROCESSING")
        }
    }
}

