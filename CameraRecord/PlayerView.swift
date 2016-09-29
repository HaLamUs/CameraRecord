//
//  PlayerView.swift
//  CameraRecord
//
//  Created by Ha Lam on 9/30/16.
//  Copyright © 2016 HTKInc. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerView: UIView {
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }


}
