//
//  GameView.swift
//  TwoRooks
//
//  Created by Samuel McBroom on 2/10/21.
//

import SwiftUI
import SpriteKit

struct GameView: View {
	@State var title: String
	private var theme: Theme {
		return DataManager.shared.theme
	}
	private var scene: SKScene {
		let scene = GameScene()
		scene.scaleMode = .resizeFill
		return scene
	}
	
	var body: some View {
		ZStack {
			LinearGradient(gradient: Gradient(colors: [Color(theme.colors.squareWhite), Color(theme.colors.squareBlack)]), startPoint: .top, endPoint: .bottom)
				.edgesIgnoringSafeArea(.all)
			
			SpriteView(scene: scene, options: [.allowsTransparency])
				.edgesIgnoringSafeArea([.horizontal])
		}
		.navigationBarTitle(title, displayMode: .inline)
	}
}
