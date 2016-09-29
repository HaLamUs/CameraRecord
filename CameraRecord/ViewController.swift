//
//  ViewController.swift
//  CameraRecord
//
//  Created by Ha Lam on 9/29/16.
//  Copyright © 2016 HTKInc. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class ViewController: UIViewController {
    
    @IBOutlet weak var cameraView: CameraView!
    let session = AVCaptureSession()
    var videoDeviceInput: AVCaptureDeviceInput!
    let sessionQueue = DispatchQueue(label: "CameraRecord")
    var movieFileOutput: AVCaptureMovieFileOutput? = nil
    @IBOutlet weak var recordButton: UIButton!
    
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
    @IBAction func touchUpRecord(_ recordButton: UIButton) {
        guard let movieFileOutput = self.movieFileOutput else {return}

        recordButton.isEnabled = false
        let videoPreviewLayerOrientation = cameraView.videoPreviewLayer.connection.videoOrientation
        
        sessionQueue.async { [weak strongSelf = self] in
            if !movieFileOutput.isRecording {
                let movieFileOutputConnection = self.movieFileOutput?.connection(withMediaType: AVMediaTypeVideo)
                movieFileOutputConnection?.videoOrientation = videoPreviewLayerOrientation
                
                // Start recording to a temporary file.
                let outputFileName = NSUUID().uuidString
                let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mov")!)
                movieFileOutput.startRecording(toOutputFileURL: URL(fileURLWithPath: outputFilePath), recordingDelegate: strongSelf)
            }
            else {
                movieFileOutput.stopRecording()
            }
        }

    }
    
}

extension ViewController{
    func configureSession() {
        session.beginConfiguration()
        //get camera
        var defaultVideoDevice: AVCaptureDevice?
        if let backCameraDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .back) {
            defaultVideoDevice = backCameraDevice
        }
        else if let frontCameraDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front) {
            defaultVideoDevice = frontCameraDevice
        }
        let videoDeviceInput = try? AVCaptureDeviceInput(device: defaultVideoDevice)
        if session.canAddInput(videoDeviceInput) {
            session.addInput(videoDeviceInput)
            self.videoDeviceInput = videoDeviceInput
        }
        else {
            print("Error can not add")
            session.commitConfiguration()
            return
        }
        
        //get audio
        let audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
        let audioDeviceInput = try? AVCaptureDeviceInput(device: audioDevice)
        if session.canAddInput(audioDeviceInput) {
            session.addInput(audioDeviceInput)
        }
        else {
            print("Error can not add")
            session.commitConfiguration()
            return
        }
        //trans to movie
        let movieFileOutput = AVCaptureMovieFileOutput()
        if self.session.canAddOutput(movieFileOutput) {
            self.session.addOutput(movieFileOutput)
            self.session.sessionPreset = AVCaptureSessionPresetHigh
            if let connection = movieFileOutput.connection(withMediaType: AVMediaTypeVideo) {
                if connection.isVideoStabilizationSupported {
                    connection.preferredVideoStabilizationMode = .auto
                }
            }
            self.session.commitConfiguration()
            self.movieFileOutput = movieFileOutput
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print()
    }
}

extension ViewController:AVCaptureFileOutputRecordingDelegate{
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        DispatchQueue.main.async {
            [weak strongSelf = self] in
            strongSelf?.recordButton.isEnabled = true
            strongSelf?.recordButton.setTitle("Stop", for: [])
        }
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        guard error == nil else {
            return
        }
        PHPhotoLibrary.requestAuthorization{
            status in
            if status == .authorized{
                PHPhotoLibrary.shared().performChanges({ 
                    let options = PHAssetResourceCreationOptions()
                    options.shouldMoveFile = true
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    creationRequest.addResource(with: .video, fileURL: outputFileURL, options: options)
                    }, completionHandler: { success, error in
                         print("Error: \(error)")
                })
            }
        }
        DispatchQueue.main.async {
            [weak strongSelf = self] in
            strongSelf?.recordButton.isEnabled = true
            strongSelf?.recordButton.setTitle("Record", for: [])
            self.performSegue(withIdentifier: "recordtoplayer", sender: nil)
        }

    }
}













