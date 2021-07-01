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
		let webRTCClient = WebRTCClient(iceServers: Config.default.webRTCIceServers)
		let signalClient = self.buildSignalingClient()
		let vc = MainViewController(signalClient: signalClient, webRTCClient: webRTCClient)
		self.navigationController?.pushViewController(vc, animated: true)
	}
	
	private func buildSignalingClient() -> SignalingClient {
		// iOS 13 has native websocket support. For iOS 12 or lower we will use 3rd party library.
		let webSocketProvider: WebSocketProvider
		if #available(iOS 13.0, *) {
			webSocketProvider = NativeWebSocket(url: Config.default.signalingServerUrl)
		} else {
			webSocketProvider = StarscreamWebSocket(url: Config.default.signalingServerUrl)
		}
		return SignalingClient(webSocket: webSocketProvider)
	}
	
}
