//
//  PlayerViewController.swift
//  CameraRecord
//
//  Created by Ha Lam on 9/30/16.
//  Copyright © 2016 HTKInc. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {

    @IBOutlet weak var playerView: PlayerView!
    let player = AVPlayer()
    var asset: AVURLAsset? {
        didSet {
            guard let newAsset = asset else { return }
            asynchronouslyLoadURLAsset(newAsset)
        }
    }
//    var asset: AVURLAsset?
    var playerItem: AVPlayerItem? = nil {
        didSet {
            player.replaceCurrentItem(with: self.playerItem)
        }
    }
    private var playerLayer: AVPlayerLayer? {
        return playerView.playerLayer
    }

    var urlFile:URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        asset = AVURLAsset(url: urlFile!, options: nil)
        playerView.playerLayer.player = player // should be this other
    }

    @IBAction func touchUpCloseButton(_ sender: UIButton) {
        player.pause()
        self.dismiss(animated: true)
    }
    
    @IBAction func touchUpPlayButton(_ playerButton: UIButton) {
        playerButton.isEnabled = false
        player.play()
    }
   
    
}

extension PlayerViewController{
    func asynchronouslyLoadURLAsset(_ newAsset: AVURLAsset) {
        newAsset.loadValuesAsynchronously(forKeys: []) {
            DispatchQueue.main.async {
                guard newAsset == self.asset else {
                    return
                }
                self.playerItem = AVPlayerItem(asset: newAsset)
            }
        }
    }

}











