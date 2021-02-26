//
//  Move.swift
//  TwoRooks
//
//  Created by Samuel McBroom on 2/23/21.
//

import Foundation

struct Move: Codable {
	let piece: Piece
	let fromSquare: Square
	let toSquare: Square
	let capturedPiece: Piece?
	let capturedSquare: Square?
	let promoted: Bool
	
	init(piece: Piece, from oldSquare: Square, to square: Square) {
		self.piece = piece
		self.fromSquare = oldSquare
		self.toSquare = square
		self.capturedPiece = nil
		self.capturedSquare = nil
		self.promoted = false
	}
	
	init(piece: Piece, from oldSquare: Square, to square: Square, captured capturedPiece: Piece, at capturedSquare: Square) {
		self.piece = piece
		self.fromSquare = oldSquare
		self.toSquare = square
		self.capturedPiece = capturedPiece
		self.capturedSquare = capturedSquare
		self.promoted = false
	}
	
	init(piece: Piece, from oldSquare: Square, to square: Square, promoted: Bool = false) {
		self.piece = piece
		self.fromSquare = oldSquare
		self.toSquare = square
		self.capturedPiece = nil
		self.capturedSquare = nil
		self.promoted = promoted
	}
	
	init(piece: Piece, from oldSquare: Square, to square: Square, captured capturedPiece: Piece, at capturedSquare: Square, promoted: Bool = false) {
		self.piece = piece
		self.fromSquare = oldSquare
		self.toSquare = square
		self.capturedPiece = capturedPiece
		self.capturedSquare = capturedSquare
		self.promoted = promoted
	}
}
