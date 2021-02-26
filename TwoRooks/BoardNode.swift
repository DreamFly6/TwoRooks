//
//  BoardNode.swift
//  TwoRooks
//
//  Created by Samuel McBroom on 2/17/21.
//

import SpriteKit

typealias PieceNodes = [PieceNode?]
extension PieceNodes {
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

class BoardNode: SKNode {
	private let theme = DataManager.shared.theme
	private var squareNodes: [SquareNode] = []
	private var pieceNodes: PieceNodes = []
	var length: CGFloat = 0
	var selectedSquareNode: SquareNode? {
		didSet {
			if let squareNode = selectedSquareNode {
				pieceNodes[squareNode.square]?.selected = true
			}
			
			if let oldSquareNode = oldValue {
				pieceNodes[oldSquareNode.square]?.selected = false
			}
		}
	}
	
	func loadState() {
		selectedSquareNode = nil
		pieceNodes = []
		removeAllChildren()
		let state = DataManager.shared.state
		for (index, piece) in state.enumerated() {
			let squareNode = SquareNode(PieceNodes.square(at: index))
			addChild(squareNode)
			squareNodes.append(squareNode)
			
			pieceNodes.append(nil)
			if piece == nil {
				continue
			}
			
			movePieceNode(piece!, to: PieceNodes.square(at: index))
		}
		
		for file in File.validFiles {
			for rank in Ranks {
				let squareNode = SquareNode(file: file, rank: rank)
				addChild(squareNode)
				squareNodes.append(squareNode)
			}
		}
	}
	
	func loadLastMove(from history: [Move]) {
		selectedSquareNode = nil
		
		guard let move = history.last else {
			return
		}
		
		if move.capturedPiece != nil {
			captureNode(at: move.capturedSquare!)
		}
		
		movePieceNode(at: move.fromSquare, to: move.toSquare)
		// Castle
		if move.piece.group == .king {
			if move.toSquare.file == move.fromSquare.file - 2 {
				movePieceNode(at: Square(file: .a, rank: move.toSquare.rank), to: Square(move.toSquare, deltaFile: 1)!)
			} else if move.toSquare.file == move.fromSquare.file + 2 {
				movePieceNode(at: Square(file: .h, rank: move.toSquare.rank), to: Square(move.toSquare, deltaFile: -1)!)
			}
		}
	}
	
	private func pointAt(_ square: Square) -> CGPoint {
		let tileLength = length / 8
		return CGPoint(x: CGFloat(square.file.rawValue) * tileLength, y: CGFloat(square.rank) * tileLength)
	}
	
	func movePieceNode(_ piece: Piece, to square: Square) {
		let pieceNode = PieceNode(piece)
		addChild(pieceNode)
		pieceNodes[square] = pieceNode
		pieceNode.resize(to: length / 8)
		pieceNode.position = pointAt(square)
		pieceNode.alpha = 0
		pieceNode.run(.fadeIn(withDuration: 0.2))
	}
	
	func movePieceNode(at oldSquare: Square, to square: Square) {
		let pieceNode = pieceNodes[oldSquare]!
		pieceNodes[oldSquare] = nil
		pieceNodes[square] = pieceNode
		pieceNode.run(.move(to: pointAt(square), duration: 0.2))
	}
	
	func captureNode(at square: Square) {
		let pieceNode = pieceNodes[square]!
		pieceNodes[square] = nil
		pieceNode.run(.fadeOut(withDuration: 0.2)) {
			self.removeChildren(in: [pieceNode])
		}
	}
	
	func enPassant(from oldSquare: Square, to square: Square) {
		let offset = pieceNodes[oldSquare]!.isWhite ? -1 : 1
		captureNode(at: Square(square, deltaRank: offset)!)
		movePieceNode(at: oldSquare, to: square)
	}
	
	func castle(from oldSquare: Square, to square: Square) {
		let direction = oldSquare.file < square.file ? -1 : 1
		let rookSquare = oldSquare.file < square.file ? Square(file: .h, rank: square.rank) : Square(file: .a, rank: square.rank)
		movePieceNode(at: rookSquare, to: Square(file: square.file + direction, rank: square.rank))
		movePieceNode(at: oldSquare, to: square)
	}
	
	func promote(at square: Square, to piece: Piece) {
		captureNode(at: square)
		movePieceNode(piece, to: square)
	}
	
	func undo(from history: [Move]) {
		selectedSquareNode = nil
		
		guard let move = history.last else {
			return
		}
		
		if move.promoted {
			captureNode(at: move.toSquare)
			movePieceNode(move.piece, to: move.toSquare)
		}
		
		movePieceNode(at: move.toSquare, to: move.fromSquare)
		// Undo castle
		if move.piece.group == .king {
			if move.toSquare.file == move.fromSquare.file - 2 {
				movePieceNode(at: Square(move.toSquare, deltaFile: 1)!, to: Square(file: .a, rank: move.toSquare.rank))
			} else if move.toSquare.file == move.fromSquare.file + 2 {
				movePieceNode(at: Square(move.toSquare, deltaFile: -1)!, to: Square(file: .h, rank: move.toSquare.rank))
			}
		}
		
		if let capturedPiece = move.capturedPiece {
			movePieceNode(capturedPiece, to: move.capturedSquare!)
		}
	}
	
	func resize(to length: CGFloat) {
		self.length = length
		let tileLength = length / 8
		
		for squareNode in squareNodes {
			squareNode.resize(to: tileLength)
			squareNode.position = pointAt(squareNode.square)
		}
		
		for (index, pieceNode) in pieceNodes.enumerated() {
			guard pieceNode != nil else {
				continue
			}
			
			pieceNode?.resize(to: tileLength)
			pieceNode?.position = pointAt(PieceNodes.square(at: index))
		}
	}
}
