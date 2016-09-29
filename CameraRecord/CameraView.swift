//
//  CameraView.swift
//  CameraRecord
//
//  Created by Ha Lam on 9/29/16.
//  Copyright © 2016 HTKInc. All rights reserved.
//

import UIKit
import AVFoundation

class CameraView: UIView {
    var videoPreviewLayer: AVCaptureVideoPreviewLayer{
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    var session : AVCaptureSession?{
        get {
            return videoPreviewLayer.session
        }
        set {
            videoPreviewLayer.session = newValue
        }
    }
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}
