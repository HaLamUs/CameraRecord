//
//  ViewController.swift
//  CameraRecord
//
//  Created by Ha Lam on 9/29/16.
//  Copyright © 2016 HTKInc. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var cameraView: CameraView!
    let session = AVCaptureSession()
    var videoDeviceInput: AVCaptureDeviceInput!
    let sessionQueue = DispatchQueue(label: "CameraRecord")

    override func viewDidLoad() {
        super.viewDidLoad()
        cameraView.session = session
        
        switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) {
        case .authorized:
            break
        case.notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo){
                [weak strongSelf = self] granted in
                strongSelf?.sessionQueue.resume()
            }
        default:
            print()
        }
        sessionQueue.async { [weak strongSelf = self] in
            strongSelf?.configureSession()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sessionQueue.async { [weak strongSelf = self] in
            strongSelf?.session.startRunning()
        }
    }

}

extension ViewController{
     func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSessionPresetPhoto
        // Add video input.
        do {
            var defaultVideoDevice: AVCaptureDevice?
            
            // Choose the back dual camera if available, otherwise default to a wide angle camera.
            if let dualCameraDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInDuoCamera, mediaType: AVMediaTypeVideo, position: .back) {
                defaultVideoDevice = dualCameraDevice
            }
            else if let backCameraDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .back) {
                // If the back dual camera is not available, default to the back wide angle camera.
                defaultVideoDevice = backCameraDevice
            }
            else if let frontCameraDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front) {
                // In some cases where users break their phones, the back wide angle camera is not available. In this case, we should default to the front wide angle camera.
                defaultVideoDevice = frontCameraDevice
            }
            
            let videoDeviceInput = try AVCaptureDeviceInput(device: defaultVideoDevice)
            
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
            }
            else {
                print("Could not add video device input to the session")
                session.commitConfiguration()
                return
            }
        }
        catch {
            print("Could not create video device input: \(error)")
            session.commitConfiguration()
            return
        }
        
        // Add audio input.
        do {
            let audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
            let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
            
            if session.canAddInput(audioDeviceInput) {
                session.addInput(audioDeviceInput)
            }
            else {
                print("Could not add audio device input to the session")
            }
        }
        catch {
            print("Could not create audio device input: \(error)")
        }
        
//        // Add photo output.
//        if session.canAddOutput(photoOutput)
//        {
//            session.addOutput(photoOutput)
//            
//            photoOutput.isHighResolutionCaptureEnabled = true
//            photoOutput.isLivePhotoCaptureEnabled = photoOutput.isLivePhotoCaptureSupported
//            livePhotoMode = photoOutput.isLivePhotoCaptureSupported ? .on : .off
//        }
//        else {
//            print("Could not add photo output to the session")
//            setupResult = .configurationFailed
//            session.commitConfiguration()
//            return
//        }
        
        session.commitConfiguration()
    }

}

