//
//  PlayerViewController.swift
//  CameraRecord
//
//  Created by Ha Lam on 9/30/16.
//  Copyright © 2016 HTKInc. All rights reserved.
//

import UIKit

class PlayerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func touchUpCloseButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
