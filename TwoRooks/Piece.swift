//
//  Piece.swift
//  TwoRooks
//
//  Created by Samuel McBroom on 2/12/21.
//

import Foundation

struct Piece: Codable {
	enum Group: String, Codable {
		case pawn
		case knight
		case bishop
		case rook
		case queen
		case king
	}

	let isWhite: Bool
	let group: Group
}
