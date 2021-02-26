//
//  GamesView.swift
//  TwoRooks
//
//  Created by Samuel McBroom on 2/10/21.
//

import SwiftUI

struct GamesView: View {
	@State private var showSettings = false
	@State private var showNewSelection = false
	
	var body: some View {
		NavigationView {
			List {
				Section {
					NavigationLink(destination: GameView(title: "♟")) {
						HStack {
							Image(systemName: "person.2.fill")
							Text("Local")
						}
					}
				}
			}
			.listStyle(InsetGroupedListStyle())
			.navigationBarTitle("Games", displayMode: .large)
			.navigationBarItems(trailing: HStack {
				Button(action: {
					showNewSelection = true
				}, label: {
					Image(systemName: "plus.circle.fill")
						.imageScale(.large)
				})
				.actionSheet(isPresented: $showNewSelection, content: {
					ActionSheet(title: Text("New Game"), message: Text("Choosing 'Local' will overwrite the current local game."), buttons: [
						.destructive(Text("Local"), action: {
							DataManager.shared.set(nil, forKey: .state)
							DataManager.shared.set(nil, forKey: .history)
							DataManager.shared.set(nil, forKey: .times)
						}),
//						.default(Text("Multiplayer"), action: {
//							
//						}),
						.cancel()
					])
				})
				
				Spacer()
				
				Button(action: {
					showSettings = true
				}, label: {
					Image(systemName: "gearshape.fill")
						.imageScale(.large)
				})
				.sheet(isPresented: $showSettings, content: {
					SettingsView()
				})
			})
		}
		.navigationViewStyle(StackNavigationViewStyle())
	}
}
