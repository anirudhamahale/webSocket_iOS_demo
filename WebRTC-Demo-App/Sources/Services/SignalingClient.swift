//
//  SignalClient.swift
//  WebRTC
//
//  Created by Stasel on 20/05/2018.
//  Copyright © 2018 Stasel. All rights reserved.
//

import Foundation
import WebRTC

protocol SignalClientDelegate: class {
	func signalClientDidConnect(_ signalClient: SignalingClient)
	func signalClientDidDisconnect(_ signalClient: SignalingClient)
	func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription)
	func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate)
}

final class SignalingClient {
	
	deinit {
		print("SignalingClient 🔥")
	}
	
	private let decoder = JSONDecoder()
	private let encoder = JSONEncoder()
	private let webSocket: WebSocketProvider
	weak var delegate: SignalClientDelegate?
	
	init(webSocket: WebSocketProvider) {
		self.webSocket = webSocket
	}
	
	func connect() {
		webSocket.delegate = self
		webSocket.connect()
	}
	
	func send(sdp rtcSdp: RTCSessionDescription) {
		let message = Message.sdp(SessionDescription(from: rtcSdp))
		do {
			let dataMessage = try encoder.encode(message)
			webSocket.send(data: dataMessage)
		}
		catch {
			debugPrint("Warning: Could not encode sdp: \(error)")
		}
	}
	
	func send(candidate rtcIceCandidate: RTCIceCandidate) {
		let message = Message.candidate(IceCandidate(from: rtcIceCandidate))
		do {
			let dataMessage = try encoder.encode(message)
			webSocket.send(data: dataMessage)
		}
		catch {
			debugPrint("Warning: Could not encode candidate: \(error)")
		}
	}
	
	func disconnect() {
		webSocket.disconnect()
	}
	
	static func build() -> SignalingClient {
		// iOS 13 has native websocket support. For iOS 12 or lower we will use 3rd party library.
		let webSocketProvider: WebSocketProvider
		if #available(iOS 13.0, *) {
			webSocketProvider = NativeWebSocket(url: Config.default.signalingServerUrl)
		} else {
			webSocketProvider = StarscreamWebSocket(url: Config.default.signalingServerUrl)
		}
		return SignalingClient(webSocket: webSocketProvider)
	}
	
	func test() {
		webSocket.testConnection()
	}
}


extension SignalingClient: WebSocketProviderDelegate {
	func webSocketDidConnect(_ webSocket: WebSocketProvider) {
		delegate?.signalClientDidConnect(self)
	}
	
	func webSocketDidDisconnect(_ webSocket: WebSocketProvider) {
		delegate?.signalClientDidDisconnect(self)
		
		// try to reconnect every two seconds
		DispatchQueue.main.asyncAfter(deadline: .now()+2) { [weak self] in
			if let obj = self {
				debugPrint("Trying to reconnect to signaling server...")
				obj.webSocket.connect()
			}
		}
	}
	
	func webSocket(_ webSocket: WebSocketProvider, didReceiveData data: Data) {
		let message: Message
		do {
			message = try decoder.decode(Message.self, from: data)
		}
		catch {
			debugPrint("Warning: Could not decode incoming message: \(error)")
			return
		}
		
		switch message {
			case .candidate(let iceCandidate):
				delegate?.signalClient(self, didReceiveCandidate: iceCandidate.rtcIceCandidate)
			case .sdp(let sessionDescription):
				delegate?.signalClient(self, didReceiveRemoteSdp: sessionDescription.rtcSessionDescription)
		}
	}
}
