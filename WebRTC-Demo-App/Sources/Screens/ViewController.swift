//
//  ViewController.swift
//  WebRTC-Demo
//
//  Created by Anirudha Mahale on 01/07/21.
//  Copyright © 2021 Stas Seldin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	@IBAction func didTapGo(_ sender: UIButton) {
		let vc = MainViewController()
		self.navigationController?.pushViewController(vc, animated: true)
	}
	
}
