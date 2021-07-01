//
//  StarscreamProvider.swift
//  WebRTC-Demo
//
//  Created by stasel on 15/07/2019.
//  Copyright © 2019 stasel. All rights reserved.
//

import Foundation
import Starscream

class StarscreamWebSocket: WebSocketProvider {
	func testConnection() {
		let dict = ["type": "user", "name": "Anirudha"]
		
		let encoder = JSONEncoder()
		if let jsonData = try? encoder.encode(dict) {
			socket.write(data: jsonData)
		}
	}
	
	weak var delegate: WebSocketProviderDelegate?
	private let socket: WebSocket
	
	init(url: URL) {
		self.socket = WebSocket(request: URLRequest(url: url))
		self.socket.delegate = self
	}
	
	func connect() {
		self.socket.connect()
	}
	
	func send(data: Data) {
		self.socket.write(data: data)
	}
	
	func disconnect() {
		self.socket.disconnect()
	}
}

extension StarscreamWebSocket: Starscream.WebSocketDelegate {
	func didReceive(event: WebSocketEvent, client: WebSocket) {
		switch event {
			case let .connected(dict):
				print(dict)
				self.delegate?.webSocketDidConnect(self)
			case let .disconnected(string, id):
				print(string, id)
				self.delegate?.webSocketDidDisconnect(self)
			case let .text(message):
				print(message)
			// debugPrint("Warning: Expected to receive data format but received a string. Check the websocket server config.")
			case let .binary(data):
				self.delegate?.webSocket(self, didReceiveData: data)
			default:
				break
		}
	}
}
