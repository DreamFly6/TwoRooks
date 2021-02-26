//
//  Square.swift
//  TwoRooks
//
//  Created by Samuel McBroom on 2/13/21.
//

import Foundation

struct Square: Equatable, Codable {
	let file: File
	let rank: Int
	
	init(file: File, rank: Int) {
		self.file = file
		self.rank = rank
	}
	
	init?(_ square: Square, deltaFile: Int = 0, deltaRank: Int = 0) {
		guard square.file + deltaFile != .none && Ranks.contains(square.rank + deltaRank) else {
			return nil
		}
		
		self.file = square.file + deltaFile
		self.rank = square.rank + deltaRank
	}
}
