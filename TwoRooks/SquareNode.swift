//
//  SquareNode.swift
//  TwoRooks
//
//  Created by Samuel McBroom on 2/17/21.
//

import SpriteKit

class SquareNode: SKShapeNode {
	private let theme = DataManager.shared.theme
	let file: File
	let rank: Int
	var pieceNode: PieceNode?
	var square: Square {
		return Square(file: file, rank: rank)
	}
	
	init(_ square: Square) {
		self.file = square.file
		self.rank = square.rank
		super.init()
		fillColor = (square.rank + square.file.rawValue - 1).isMultiple(of: 2) ? theme.colors.squareWhite : theme.colors.squareBlack
		lineWidth = 0
	}
	
	convenience init(file: File, rank: Int) {
		self.init(Square(file: file, rank: rank))
	}
	
	required init?(coder aDecoder: NSCoder) {
		self.file = .a
		self.rank = 1
		super.init(coder: aDecoder)
	}
	
	func resize(to length: CGFloat) {
		let box = CGRect(origin: CGPoint(x: -length / 2, y: -length / 2), size: CGSize(width: length, height: length))
		path = CGPath(rect: box, transform: nil)
	}
}
