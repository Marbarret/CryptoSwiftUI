//
//  SettingsView.swift
//  CryptoSwiftUI
//
//  Created by Marcylene Barreto on 28/06/22.
//

import SwiftUI

struct SettingsView: View {
    
    let defaultURL1 = URL(string: "https://www.google.com")!
    let defaultURL2 = URL(string: "https://www.google.com")!
    let defaultURL3 = URL(string: "https://www.google.com")!
    let defaultURL4 = URL(string: "https://www.google.com")!
    
    var body: some View {
        NavigationView {
            List {
                sectionSettings
            }
            .font(.headline)
            .accentColor(.blue)
            .listStyle(GroupedListStyle())
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    XMarkButton()
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

extension SettingsView {
    private var sectionSettings: some View {
        Section(header: Text("SwiftUI")) {
            VStack(alignment: .leading) {
                Image("logo")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                Text("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.")
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundColor(Color.theme.accent)
            }
            .padding()
            Link("Link na descricao", destination: defaultURL1)
        }
    }
}
