//
//  Board.swift
//  TwoRooks
//
//  Created by Samuel McBroom on 2/10/21.
//

import Foundation

enum File: Int, CaseIterable, Comparable, Codable {
	case none
	case a
	case b
	case c
	case d
	case e
	case f
	case g
	case h
	
	static var validFiles: [File] {
		get {
			return Array(File.allCases.dropFirst())
		}
	}
	
	static func +(lhs: File, rhs: Int) -> File {
		guard let file = File(rawValue: lhs.rawValue + rhs) else {
			return .none
		}
		return file
	}
	
	static func -(lhs: File, rhs: Int) -> File {
		guard let file = File(rawValue: lhs.rawValue - rhs) else {
			return .none
		}
		return file
	}
	
	static func <(lhs: File, rhs: File) -> Bool {
		return lhs.rawValue < rhs.rawValue
	}
	
	static func +=(lhs: inout File, rhs: Int) {
		lhs = lhs + rhs
	}
}

let Ranks = 1...8

typealias Pieces = [Piece?]
extension Pieces {
	subscript(file: File, rank: Int) -> Element {
		get {
			return self[(file.rawValue - 1) * 8 + rank - 1]
		}
		
		set(newValue) {
			self[(file.rawValue - 1) * 8 + rank - 1] = newValue
		}
	}
	
	subscript(square: Square) -> Element {
		get {
			return self[square.file, square.rank]
		}
		
		set(newValue) {
			self[square.file, square.rank] = newValue
		}
	}
	
	static func square(at index: Int) -> Square {
		return Square(file: File(rawValue: index / 8 + 1)!, rank: index % 8 + 1)
	}
}

struct Board {
	var history: [Move] = DataManager.shared.history
	var pieces: Pieces = DataManager.shared.state
	var whiteTurn = DataManager.shared.history.count.isMultiple(of: 2)
	
	mutating func movePiece(_ piece: Piece, to square: Square) {
		pieces[square] = piece
	}
	
	mutating func movePiece(at oldSquare: Square, to square: Square) {
		let piece = pieces[oldSquare]
		capture(at: oldSquare)
		pieces[square] = piece
	}
	
	mutating func capture(at square: Square) {
		pieces[square] = nil
	}
	
	mutating func enPassant(from oldSquare: Square, to square: Square) {
		let offset = pieces[oldSquare]!.isWhite ? -1 : 1
		capture(at: Square(square, deltaRank: offset)!)
		movePiece(at: oldSquare, to: square)
	}
	
	mutating func castle(from oldSquare: Square, to square: Square) {
		let offset = oldSquare.file < square.file ? -1 : 1
		let rookSquare = oldSquare.file < square.file ? Square(file: .h, rank: square.rank) : Square(file: .a, rank: square.rank)
		movePiece(at: rookSquare, to: Square(file: square.file + offset, rank: square.rank))
		movePiece(at: oldSquare, to: square)
	}
	
	mutating func promote(at square: Square, to piece: Piece) {
		capture(at: square)
		movePiece(piece, to: square)
		DataManager.shared.set(history, forKey: .history)
		DataManager.shared.set(pieces, forKey: .state)
		whiteTurn.toggle()
	}
	
	private func attackedDiagonalsFrom(_ square: Square) -> [Square] {
		var attackedSquares: [Square] = []
		for delta in 1...7 {
			if let attackedSquare = Square(square, deltaFile: delta, deltaRank: delta) {
				attackedSquares.append(attackedSquare)
				guard pieces[attackedSquare] == nil else {
					break
				}
			}
		}
		
		for delta in 1...7 {
			if let attackedSquare = Square(square, deltaFile: delta, deltaRank: -delta) {
				attackedSquares.append(attackedSquare)
				guard pieces[attackedSquare] == nil else {
					break
				}
			}
		}
		
		for delta in 1...7 {
			if let attackedSquare = Square(square, deltaFile: -delta, deltaRank: delta) {
				attackedSquares.append(attackedSquare)
				guard pieces[attackedSquare] == nil else {
					break
				}
			}
		}
		
		for delta in 1...7 {
			if let attackedSquare = Square(square, deltaFile: -delta, deltaRank: -delta) {
				attackedSquares.append(attackedSquare)
				guard pieces[attackedSquare] == nil else {
					break
				}
			}
		}
		
		return attackedSquares
	}
	
	private func attackedLinesFrom(_ square: Square) -> [Square] {
		var attackedSquares: [Square] = []
		
		for delta in 1...7 {
			if let attackedSquare = Square(square, deltaFile: delta) {
				attackedSquares.append(attackedSquare)
				guard pieces[attackedSquare] == nil else {
					break
				}
			}
		}
		
		for delta in 1...7 {
			if let attackedSquare = Square(square, deltaFile: -delta) {
				attackedSquares.append(attackedSquare)
				guard pieces[attackedSquare] == nil else {
					break
				}
			}
		}
		
		for delta in 1...7 {
			if let attackedSquare = Square(square, deltaRank: delta) {
				attackedSquares.append(attackedSquare)
				guard pieces[attackedSquare] == nil else {
					break
				}
			}
		}
		
		for delta in 1...7 {
			if let attackedSquare = Square(square, deltaRank: -delta) {
				attackedSquares.append(attackedSquare)
				guard pieces[attackedSquare] == nil else {
					break
				}
			}
		}
		
		return attackedSquares
	}
	
	func attackedFrom(_ square: Square) -> [Square] {
		// No piece at square
		guard let piece = pieces[square] else {
			return []
		}
		
		var attackedSquares: [Square] = []
		switch piece.group {
			case .pawn:
				let offset = piece.isWhite ? 1 : -1
				
				if let attackedSquare = Square(square, deltaFile: -1, deltaRank: offset) {
					attackedSquares.append(attackedSquare)
				}
				
				if let attackedSquare = Square(square, deltaFile: 1, deltaRank: offset) {
					attackedSquares.append(attackedSquare)
				}
				
				return attackedSquares
			case .knight:
				for delta in [(-1, -2), (-1, 2), (1, -2), (1, 2), (-2, -1), (-2, 1), (2, -1), (2, 1)] {
					if let attackedSquare = Square(square, deltaFile: delta.0, deltaRank: delta.1) {
						attackedSquares.append(attackedSquare)
					}
				}
				
				return attackedSquares
			case .bishop:
				attackedSquares.append(contentsOf: attackedDiagonalsFrom(square))

				return attackedSquares
			case .rook:
				attackedSquares.append(contentsOf: attackedLinesFrom(square))
				
				return attackedSquares
			case .queen:
				attackedSquares.append(contentsOf: attackedDiagonalsFrom(square))
				attackedSquares.append(contentsOf: attackedLinesFrom(square))
				
				return attackedSquares
			case .king:
				for deltaFile in -1...1 {
					for deltaRank in -1...1 {
						guard deltaFile != 0 || deltaRank != 0 else {
							continue
						}
						
						if let attackedSquare = Square(square, deltaFile: deltaFile, deltaRank: deltaRank) {
							attackedSquares.append(attackedSquare)
						}
					}
				}
				return attackedSquares
		}
	}
	
	func canEnPassant(to square: Square, with offset: Int) -> Bool {
		guard let move = history.last else {
			return false
		}
		
		let fromSquare = Square(square, deltaRank: offset)
		let toSquare = Square(square, deltaRank: -offset)
		
		// Make sure opponent pawn moved two squares last turn
		return move.piece.group == .pawn && move.fromSquare == fromSquare && move.toSquare == toSquare
	}
	
	func canCastle(to square: Square) -> Bool {
		let kingSquare = Square(file: .e, rank: square.rank)
		let offset = kingSquare.file < square.file ? 1 : -1
		let rookFile: File = kingSquare.file < square.file ? .h : .a
		let rookSquare = Square(file: rookFile, rank: square.rank)
		
		// Check square next to king is empty
		guard pieces[kingSquare.file + offset, square.rank] == nil else {
			return false
		}
		
		// Check square two away from king is empty
		guard pieces[kingSquare.file + offset * 2, square.rank] == nil else {
			return false
		}
		
		// If queenside castle, make sure square three away from king is empy
		if kingSquare.file > square.file && pieces[kingSquare.file + offset * 3, square.rank] != nil {
			return false
		}
		
		// King cannot pass through attacked square when castling
		if let king = pieces[kingSquare], inCheckAt(Square(square, deltaFile: offset)!, isWhite: king.isWhite) {
			return false
		}
		
		// King cannot castle when in check
		if let king = pieces[kingSquare], inCheckAt(kingSquare, isWhite: king.isWhite) {
			return false
		}
		
		// Check that king has never been moved, and that rook has never been moved or captured
		for move in history {
			if move.fromSquare == kingSquare || move.fromSquare == rookSquare || move.toSquare == rookSquare {
				return false
			}
		}
		
		return true
	}
	
	func inCheckAt(_ square: Square, isWhite: Bool) -> Bool {
		for (index, piece) in pieces.enumerated() {
			let checkSquare = Pieces.square(at: index)
			if let piece = piece, piece.isWhite != isWhite, attackedFrom(checkSquare).contains(square) {
				return true
			}
		}
		return false
	}
	
	mutating func canMove(from oldSquare: Square, to square: Square) -> Bool {
		// Make sure piece at oldSquare exists
		guard let piece = pieces[oldSquare] else {
			return false
		}
		
		// Ignore move if square occupied by piece of same color
		if let attackedPiece = pieces[square], attackedPiece.isWhite == piece.isWhite {
			return false
		}
		
		let attackedSquares = attackedFrom(oldSquare)
		var validSquares: [Square] = []
		
		switch piece.group {
			case .pawn:
				let offset = piece.isWhite ? 1 : -1
				let startRank = piece.isWhite ? 2 : 7
				
				// Check if attack squares are valid
				validSquares.append(contentsOf: attackedSquares.filter({ pieces[$0] != nil || canEnPassant(to: square, with: offset) }))
				
				// Check if forward or two square forward moves are valid
				if pieces[oldSquare.file, oldSquare.rank + offset] == nil {
					validSquares.append(Square(file: oldSquare.file, rank: oldSquare.rank + offset))
					if oldSquare.rank == startRank && pieces[oldSquare.file, oldSquare.rank + offset * 2] == nil {
						validSquares.append(Square(file: oldSquare.file, rank: oldSquare.rank + offset * 2))
					}
				}
				break
			case .knight:
				validSquares.append(contentsOf: attackedSquares)
				break
			case .bishop:
				validSquares.append(contentsOf: attackedSquares)
				break
			case .rook:
				validSquares.append(contentsOf: attackedSquares)
				break
			case .queen:
				validSquares.append(contentsOf: attackedSquares)
				break
			case .king:
				let rank = piece.isWhite ? 1 : 8
				// Check if in check at attack squares
				validSquares.append(contentsOf: attackedSquares.filter({ !inCheckAt($0, isWhite: piece.isWhite) }))
				// Check if castle squares are valid
				let castleSquares = [Square(file: .g, rank: rank), Square(file: .c, rank: rank)]
				validSquares.append(contentsOf: castleSquares.filter({ canCastle(to: $0) }))
				break
		}
		
		guard validSquares.contains(square) else {
			return false
		}
		
		move(from: oldSquare, to: square, checkTest: true)
		
		let kingIndex = pieces.firstIndex(where: { $0?.group == .king && $0?.isWhite == piece.isWhite })!
		let inCheck = inCheckAt(Pieces.square(at: kingIndex), isWhite: piece.isWhite)
		
		undo(checkTest: true)
		
		return !inCheck
	}
	
	mutating func move(from oldSquare: Square, to square: Square, checkTest: Bool = false) {
		let piece = pieces[oldSquare]!
		let move: Move
		var promoted = false
		
		if piece.group == .pawn && square.file != oldSquare.file && pieces[square] == nil {
			// En passant
			let offset = piece.isWhite ? 1 : -1
			let enPassantSquare = Square(square, deltaRank: -offset)!
			move = Move(piece: piece, from: oldSquare, to: square, captured: pieces[enPassantSquare]!, at: enPassantSquare)
			enPassant(from: oldSquare, to: square)
		} else if piece.group == .king && (square.file == oldSquare.file + 2 || square.file == oldSquare.file - 2) {
			// Castle
			move = Move(piece: piece, from: oldSquare, to: square)
			castle(from: oldSquare, to: square)
		} else {
			// Promoted
			let rank = piece.isWhite ? 8 : 1
			if piece.group == .pawn && square.rank == rank {
				promoted = true
			}
			
			if let oldPiece = pieces[square] {
				move = Move(piece: piece, from: oldSquare, to: square, captured: oldPiece, at: square, promoted: promoted)
				capture(at: square)
			} else {
				move = Move(piece: piece, from: oldSquare, to: square, promoted: promoted)
			}
			movePiece(at: oldSquare, to: square)
			
			// Don't need to handle if pawn upgraded because only position of piece matters for blocking check, not type
		}
		
		history.append(move)
		
		// Wait to save if promoted until promoted piece is chosen
		if !checkTest && !promoted {
			DataManager.shared.set(history, forKey: .history)
			DataManager.shared.set(pieces, forKey: .state)
			whiteTurn.toggle()
		}
	}
	
	mutating func kingState(isWhite: Bool) -> String {
		var findSquare: Square?
		for (index, piece) in pieces.enumerated() {
			if let king = piece, king.group == .king, king.isWhite == isWhite {
				findSquare = Pieces.square(at: index)
				break
			}
		}
		
		guard let kingSquare = findSquare else {
			return ""
		}
		
		if inCheckAt(kingSquare, isWhite: isWhite) {
			// Check checkmate
			for (index, piece) in pieces.enumerated() {
				guard piece != nil && piece?.isWhite == isWhite else {
					continue
				}
				
				// If player can move any piece somewhere, then it is possible to get king out of check
				for checkIndex in 0..<pieces.count {
					if canMove(from: Pieces.square(at: index), to: Pieces.square(at: checkIndex)) {
						return "Check!"
					}
				}
			}
			return "Checkmate!"
		}
		
		// Check stalemate
		for (index, piece) in pieces.enumerated() {
			guard piece != nil && piece?.isWhite == isWhite else {
				continue
			}
			
			// If player can move any piece and they are not in check, then it is a stalemate
			for checkIndex in 0..<pieces.count {
				if canMove(from: Pieces.square(at: index), to: Pieces.square(at: checkIndex)) {
					return ""
				}
			}
		}
		return "Stalemate!"
	}
	
	mutating func undo(checkTest: Bool = false) {
		if history.isEmpty {
			return
		}
		
		let move = history.removeLast()
		
		if move.promoted {
			capture(at: move.toSquare)
			movePiece(move.piece, to: move.toSquare)
		}
		
		movePiece(at: move.toSquare, to: move.fromSquare)
		// Undo castle
		if move.piece.group == .king {
			if move.toSquare.file == move.fromSquare.file - 2 {
				movePiece(at: Square(move.toSquare, deltaFile: 1)!, to: Square(file: .a, rank: move.toSquare.rank))
			} else if move.toSquare.file == move.fromSquare.file + 2 {
				movePiece(at: Square(move.toSquare, deltaFile: -1)!, to: Square(file: .h, rank: move.toSquare.rank))
			}
		}
		
		if let capturedPiece = move.capturedPiece {
			movePiece(capturedPiece, to: move.capturedSquare!)
		}

		if !checkTest {
			DataManager.shared.set(history, forKey: .history)
			DataManager.shared.set(pieces, forKey: .state)
			whiteTurn.toggle()
		}
	}
}
