//
//  Times.swift
//  TwoRooks
//
//  Created by Samuel McBroom on 2/24/21.
//

import Foundation

struct Times: Codable {
	var white: TimeInterval
	var black: TimeInterval
	
	func stringFor(whiteTime: Bool, withStyle style: DateComponentsFormatter.UnitsStyle) -> String {
		let formatter = DateComponentsFormatter()
		formatter.allowedUnits = [.hour, .minute, .second]
		formatter.unitsStyle = style
		formatter.zeroFormattingBehavior = .pad
		guard let formattedString = formatter.string(from: whiteTime ? white : black) else {
			return ""
		}
		return formattedString
	}
}
