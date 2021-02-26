//
//  GameScene.swift
//  TwoRooks
//
//  Created by Samuel McBroom on 2/10/21.
//

import SpriteKit

class GameScene: SKScene, UIGestureRecognizerDelegate {
	let boardNode = BoardNode()
	let undoNode = ImageNode(symbolName: "arrow.uturn.backward.circle.fill", width: 50)
	let choiceNodes = SKNode()
	let knightChoiceNode = PieceNode(Piece(isWhite: true, group: .knight))
	let bishopChoiceNode = PieceNode(Piece(isWhite: true, group: .bishop))
	let rookChoiceNode = PieceNode(Piece(isWhite: true, group: .rook))
	let queenChoiceNode = PieceNode(Piece(isWhite: true, group: .queen))
	let turnNode = PieceNode(Piece(isWhite: true, group: .rook))
	let statusNode = SKLabelNode()
	let timeNodes = SKNode()
	let whiteTimeNode = SKLabelNode()
	let blackTimeNode = SKLabelNode()
	private let theme = DataManager.shared.theme
	var board = Board()
	var pawnSquare: Square? = nil
	var times = DataManager.shared.times
	
	override func sceneDidLoad() {
		backgroundColor = .clear
		
		addChild(boardNode)
		boardNode.loadState()
		
		addChild(undoNode)
		undoNode.paint(theme.colors.squareBlack)
		
		addChild(turnNode)
		turnNode.resize(to: 100)
		turnNode.isWhite = board.whiteTurn
		
		addChild(statusNode)
		statusNode.verticalAlignmentMode = .center
		statusNode.fontName = "ArialRoundedMTBold"
		statusNode.fontSize = 20
		statusNode.fontColor = theme.colors.squareBlack
		statusNode.text = board.kingState(isWhite: board.whiteTurn)
		
		addChild(timeNodes)
		timeNodes.addChild(whiteTimeNode)
		timeNodes.addChild(blackTimeNode)
		
		whiteTimeNode.text = times.stringFor(whiteTime: true, withStyle: .positional)
		whiteTimeNode.position = CGPoint(x: 0, y: 20)
		whiteTimeNode.verticalAlignmentMode = .center
//		whiteTimeNode.horizontalAlignmentMode = .center
		whiteTimeNode.fontName = "ArialRoundedMTBold"
		whiteTimeNode.fontSize = 20
		whiteTimeNode.fontColor = theme.colors.pieceWhite
		
		blackTimeNode.text = times.stringFor(whiteTime: false, withStyle: .positional)
		blackTimeNode.position = CGPoint(x: 0, y: -20)
		blackTimeNode.verticalAlignmentMode = .center
//		blackTimeNode.horizontalAlignmentMode = .right
		blackTimeNode.fontName = "ArialRoundedMTBold"
		blackTimeNode.fontSize = 20
		blackTimeNode.fontColor = theme.colors.pieceBlack
		
		addChild(choiceNodes)
		choiceNodes.addChild(knightChoiceNode)
		choiceNodes.addChild(bishopChoiceNode)
		choiceNodes.addChild(rookChoiceNode)
		choiceNodes.addChild(queenChoiceNode)
		
		for child in choiceNodes.children {
			(child as! PieceNode).resize(to: 75)
		}
		choiceNodes.isHidden = true
	}
	
	override func didMove(to view: SKView) {
		view.ignoresSiblingOrder = true
		view.allowsTransparency = true
		view.backgroundColor = .clear
	}
	
	override func didChangeSize(_ oldSize: CGSize) {
		let length = min(size.width, size.height)
		let boardRaduis = length / 2
		let tileRadius = length / 16
		boardNode.resize(to: length)
		boardNode.position = CGPoint(x: size.width / 2 - boardRaduis - tileRadius, y: size.height / 2 - boardRaduis - tileRadius)
		
		let spacer: CGFloat = 80
		if size.width < size.height {
			let midEdge = (size.height - length) / 4
			undoNode.position = CGPoint(x: size.width - 50, y: size.height - midEdge)
			knightChoiceNode.position = CGPoint(x: size.width / 2 - spacer / 2 - spacer, y: midEdge)
			bishopChoiceNode.position = CGPoint(x: size.width / 2 - spacer / 2, y: midEdge)
			rookChoiceNode.position = CGPoint(x: size.width / 2 + spacer / 2, y: midEdge)
			queenChoiceNode.position = CGPoint(x: size.width / 2 + spacer / 2 + spacer, y: midEdge)
			turnNode.position = CGPoint(x: size.width / 2, y: size.height - midEdge)
			timeNodes.position = CGPoint(x: 60, y: size.height - midEdge)
		} else {
			let midEdge = (size.width - length) / 4
			undoNode.position = CGPoint(x: size.width - midEdge, y: size.height - 50)
			knightChoiceNode.position = CGPoint(x: midEdge, y: size.height / 2 + spacer / 2 + spacer)
			bishopChoiceNode.position = CGPoint(x: midEdge, y: size.height / 2 + spacer / 2)
			rookChoiceNode.position = CGPoint(x: midEdge, y: size.height / 2 - spacer / 2)
			queenChoiceNode.position = CGPoint(x: midEdge, y: size.height / 2 - spacer / 2 - spacer)
			turnNode.position = CGPoint(x: size.width - midEdge, y: size.height / 2)
			timeNodes.position = CGPoint(x: size.width - midEdge, y: 50)
		}
		statusNode.position = CGPoint(x: turnNode.position.x, y: turnNode.position.y - turnNode.frame.height)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		for node in nodes(at: touches.first!.location(in: self)) {
			if node == undoNode {
				undo()
				return
			}
			
			if node == knightChoiceNode, let square = pawnSquare {
				promote(at: square, to: Piece(isWhite: board.whiteTurn, group: .knight))
				return
			}
			
			if node == bishopChoiceNode, let square = pawnSquare {
				promote(at: square, to: Piece(isWhite: board.whiteTurn, group: .bishop))
				return
			}
			
			if node == rookChoiceNode, let square = pawnSquare {
				promote(at: square, to: Piece(isWhite: board.whiteTurn, group: .rook))
				return
			}
			
			if node == queenChoiceNode, let square = pawnSquare {
				promote(at: square, to: Piece(isWhite: board.whiteTurn, group: .queen))
				return
			}
			
			guard pawnSquare == nil else {
				return
			}
			
			guard let squareNode = node as? SquareNode else {
				continue
			}
			
			if let selectedSquareNode = boardNode.selectedSquareNode, squareNode == selectedSquareNode {
				continue
			}
			
			if let piece = board.pieces[squareNode.square], piece.isWhite == board.whiteTurn {
				boardNode.selectedSquareNode = squareNode
				return
			}
			
			if let selectedSquareNode = boardNode.selectedSquareNode {
				let oldSquare = Square(file: selectedSquareNode.file, rank: selectedSquareNode.rank)
				let square = Square(file: squareNode.file, rank: squareNode.rank)
				if board.canMove(from: oldSquare, to: square) {
					board.move(from: oldSquare, to: square)
					boardNode.loadLastMove(from: board.history)

					// Check if promotion
					let rank = board.whiteTurn ? 8 : 1
					if let piece = board.pieces[square], piece.group == .pawn, square.rank == rank {
						pawnSquare = square
						undoNode.isHidden = true
						for child in choiceNodes.children.map({ $0 as! PieceNode }) {
							child.isWhite = board.whiteTurn
						}
						choiceNodes.isHidden = false
					} else {
						statusNode.text = board.kingState(isWhite: board.whiteTurn)
						turnNode.isWhite = board.whiteTurn
					}
				}
			}
			return
		}
	}
	
	func promote(at square: Square, to piece: Piece) {
		board.promote(at: square, to: piece)
		boardNode.promote(at: square, to: piece)
		pawnSquare = nil
		undoNode.isHidden = false
		choiceNodes.isHidden = true
		statusNode.text = board.kingState(isWhite: board.whiteTurn)
		turnNode.isWhite = board.whiteTurn
	}
	
	func undo() {
		// Must undo boardNode first because board saves history
		boardNode.undo(from: board.history)
		board.undo()
		statusNode.text = board.kingState(isWhite: board.whiteTurn)
		turnNode.isWhite = board.whiteTurn
	}
	
	override func update(_ currentTime: TimeInterval) {
		guard let fps = view?.preferredFramesPerSecond else {
			return
		}
		
		if board.whiteTurn {
			times.white += 1 / Double(fps)
			whiteTimeNode.text = times.stringFor(whiteTime: true, withStyle: .positional)
		} else {
			times.black += 1 / Double(fps)
			blackTimeNode.text = times.stringFor(whiteTime: false, withStyle: .positional)
		}
		
		DataManager.shared.set(times, forKey: .times)
		
		return
	}
}
