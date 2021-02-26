//
//  PieceNode.swift
//  TwoRooks
//
//  Created by Samuel McBroom on 2/17/21.
//

import SpriteKit

class PieceNode: SKLabelNode {
	let group: Piece.Group
	private let theme = DataManager.shared.theme
	var isWhite: Bool {
		didSet {
			text = symbol
			fontColor = isWhite ? theme.colors.pieceWhite : theme.colors.pieceBlack
		}
	}
	var background = SKShapeNode()
	var selected: Bool = false {
		didSet {
			let pieceColor = isWhite ? theme.colors.pieceWhite : theme.colors.pieceBlack
			background.strokeColor = selected ? pieceColor : .clear
		}
	}
	private var symbol: String {
		get {
			switch group {
				case .pawn:
					return isWhite ? "♙" : "♟︎"
				case .knight:
					return isWhite ? "♘" : "♞"
				case .bishop:
					return isWhite ? "♗" : "♝"
				case .rook:
					return isWhite ? "♖" : "♜"
				case .queen:
					return isWhite ? "♕" : "♛"
				case .king:
					return isWhite ? "♔" : "♚"
			}
		}
	}
	
	init(_ piece: Piece) {
		self.group = piece.group
		self.isWhite = piece.isWhite
		super.init()
		zPosition = 2
		text = symbol
		fontName = "Menlo"
		fontColor = isWhite ? theme.colors.pieceWhite : theme.colors.pieceBlack
		verticalAlignmentMode = .center
		addChild(background)
		background.strokeColor = .clear
		background.zPosition = -1
	}
	
	required init?(coder aDecoder: NSCoder) {
		self.group = .pawn
		self.isWhite = true
		super.init(coder: aDecoder)
	}
	
	func resize(to tileLength: CGFloat) {
		fontSize = 40 * tileLength / 50
		let radius = tileLength / 8 * 3
		let box = CGRect(origin: CGPoint(x: -radius, y: -radius), size: CGSize(width: 2 * radius, height: 2 * radius))
		background.path = CGPath.init(ellipseIn: box, transform: nil)
		background.lineWidth = 3 * tileLength / 50
	}
}
