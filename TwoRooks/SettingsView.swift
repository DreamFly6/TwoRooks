//
//  SettingsView.swift
//  TwoRooks
//
//  Created by Samuel McBroom on 2/21/21.
//

import SwiftUI

struct SettingsView: View {
	@Environment(\.presentationMode) var presentationMode
	@State private var selectedTheme = DataManager.shared.theme
	
	var body: some View {
		NavigationView {
			Form {
				Section(header: Text("Theme")) {
					Picker("Theme", selection: $selectedTheme) {
						ForEach(Theme.allCases) { theme in
							Text(theme.rawValue).tag(theme)
						}
					}
					.pickerStyle(SegmentedPickerStyle())
					.onChange(of: selectedTheme, perform: { _ in
						DataManager.shared.set(selectedTheme, forKey: .theme)
					})
				}
			}
			.navigationBarTitle("Settings", displayMode: .inline)
			.navigationBarItems(trailing: Button(action: {
				self.presentationMode.wrappedValue.dismiss()
			}, label: {
				Text("Done")
			}))
		}
	}
}
