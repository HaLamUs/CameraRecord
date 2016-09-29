//
//  PlayerViewController.swift
//  CameraRecord
//
//  Created by Ha Lam on 9/30/16.
//  Copyright © 2016 HTKInc. All rights reserved.
//

import UIKit
import AVFoundation
import GoogleAPIClient
import GTMOAuth2

class PlayerViewController: UIViewController {

    @IBOutlet weak var playerView: PlayerView!
    let player = AVPlayer()
    var asset: AVURLAsset? {
        didSet {
            guard let newAsset = asset else { return }
            asynchronouslyLoadURLAsset(newAsset)
        }
    }
    var playerItem: AVPlayerItem? = nil {
        didSet {
            player.replaceCurrentItem(with: self.playerItem)
        }
    }
    private var playerLayer: AVPlayerLayer? {
        return playerView.playerLayer
    }
    let keyChainName = "CameraRecord"
    let clientID = "449392154913-obh7qiq70kdqhuobkh6oh0l7kjh77sik.apps.googleusercontent.com"
    lazy var services:GTLServiceDrive = {
        if let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychain(forName: self.keyChainName, clientID: self.clientID, clientSecret: nil) {
            $0.authorizer = auth
        }
        return $0
    }(GTLServiceDrive())


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
   
    @IBAction func touchUpUpLoadButton(_ uploadButton: UIButton) {
        uploadButton.isEnabled = false
        uploadRecord()
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
    
    func uploadRecord(){
        _ = GTLUploadParameters(fileURL: urlFile!, mimeType: "mov")
    }

}











