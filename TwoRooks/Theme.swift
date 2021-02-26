//
//  Theme.swift
//  TwoRooks
//
//  Created by Samuel McBroom on 2/21/21.
//

import UIKit

enum Theme: String, CaseIterable, Identifiable, Codable {
	typealias Colors = (squareWhite: UIColor, squareBlack: UIColor, pieceWhite: UIColor, pieceBlack: UIColor)
	var id: String {
		return rawValue
	}
	
	case ocean = "🌊"
	case forest = "🌲"
	case moon = "🌑"
	
	private func color(_ hex: UInt32) -> UIColor {
		let red = (hex & 0xff0000) >> 16
		let green = (hex & 0x00ff00) >> 8
		let blue = hex & 0x0000ff
		return UIColor(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: 1)
	}
	
	var colors: Colors {
		switch self {
			case .ocean:
				return Colors(squareWhite: color(0xb2ecee), squareBlack: color(0x0375fb), pieceWhite: color(0x00c1ce), pieceBlack: color(0x0100a7))
			case .forest:
				return Colors(squareWhite: color(0x72dd65), squareBlack: color(0x1c8900), pieceWhite: color(0xcc8b33), pieceBlack: color(0x834600))
			case .moon:
				return Colors(squareWhite: color(0xc0c0c0), squareBlack: color(0x606060), pieceWhite: .white, pieceBlack: .black)
		}
	}
}
