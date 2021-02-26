//
//  DataManager.swift
//  TwoRooks
//
//  Created by Samuel McBroom on 2/21/21.
//

import Foundation

struct DataManager {
	enum Keys: String {
		case theme
		case state
		case history
		case times
	}
	
	let localStorage = UserDefaults.standard
	static var shared = DataManager()
	var theme: Theme {
		get {
			return get(forKey: .theme) as! Theme
		}
	}
	var state: Pieces {
		get {
			return get(forKey: .state) as! Pieces
		}
	}
	var history: [Move] {
		get {
			return get(forKey: .history) as! [Move]
		}
	}
	var times: Times {
		get {
			return get(forKey: .times) as! Times
		}
	}
	
	private init() {
	}
	
	func set(_ value: Any?, forKey key: Keys) {
		guard let object = value else {
			localStorage.setValue(nil, forKey: key.rawValue)
			return
		}
		
		let encodedData: Data?
		switch key {
			case .theme:
				encodedData = try? JSONEncoder().encode(object as! Theme)
			case .state:
				encodedData = try? PropertyListEncoder().encode(object as! Pieces)
			case .history:
				encodedData = try? PropertyListEncoder().encode(object as! [Move])
			case .times:
				encodedData = try? PropertyListEncoder().encode(object as! Times)
		}
		localStorage.setValue(encodedData!, forKey: key.rawValue)
	}
	
	private func get(forKey key: Keys) -> Any {
		if localStorage.value(forKey: key.rawValue) == nil {
			switch key {
				case .theme:
					return Theme.ocean
				case .state:
					var state = Array(repeatElement(nil, count: File.validFiles.count * Ranks.count)) as Pieces
					
					for rank in [1, 8] {
						state[.a, rank] = Piece(isWhite: rank == 1, group: .rook)
						state[.b, rank] = Piece(isWhite: rank == 1, group: .knight)
						state[.c, rank] = Piece(isWhite: rank == 1, group: .bishop)
						state[.d, rank] = Piece(isWhite: rank == 1, group: .queen)
						state[.e, rank] = Piece(isWhite: rank == 1, group: .king)
						state[.f, rank] = Piece(isWhite: rank == 1, group: .bishop)
						state[.g, rank] = Piece(isWhite: rank == 1, group: .knight)
						state[.h, rank] = Piece(isWhite: rank == 1, group: .rook)
					}
					
					for rank in [2, 7] {
						for file in File.validFiles {
							state[file, rank] = Piece(isWhite: rank == 2, group: .pawn)
						}
					}
					
					return state
				case .history:
					return []
				case .times:
					return Times(white: 0, black: 0)
			}
		}
		
		let data = localStorage.value(forKey: key.rawValue) as! Data
		switch key {
			case .theme:
				let theme = try? JSONDecoder().decode(Theme.self, from: data)
				return theme!
			case .state:
				let state = try? PropertyListDecoder().decode(Pieces.self, from: data)
				return state!
			case .history:
				let history = try? PropertyListDecoder().decode([Move].self, from: data)
				return history!
			case .times:
				let times = try? PropertyListDecoder().decode(Times.self, from: data)
				return times!
		}
	}
}
