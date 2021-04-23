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
	case autumn = "🍁"
	case winter = "❄️"
	case spring = "🌸"
	case summer = "☀️"
	
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
				return Colors(squareWhite: color(0xcce8b5), squareBlack: color(0x38571a), pieceWhite: .white, pieceBlack: .black)
			case .moon:
				return Colors(squareWhite: color(0xc0c0c0), squareBlack: color(0x606060), pieceWhite: .white, pieceBlack: .black)
			case .autumn:
				return Colors(squareWhite: color(0xffad3a), squareBlack: color(0xb22a00), pieceWhite: .white, pieceBlack: .black)
			case .winter:
				return Colors(squareWhite: color(0xcaf0fe), squareBlack: color(0x76aac7), pieceWhite: color(0x444444), pieceBlack: .black)
			case .spring:
				return Colors(squareWhite: color(0xfff76b), squareBlack: color(0xb1dd8c), pieceWhite: color(0x606060), pieceBlack: .black)
			case .summer:
				return Colors(squareWhite: color(0xfff995), squareBlack: color(0xffaa00), pieceWhite: color(0x606060), pieceBlack: .black)
		}
	}
}
