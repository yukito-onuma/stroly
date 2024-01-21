//
//  ContentView.swift
//  stroly
//
//  Created by 長濱聖英 on 2023/11/03.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        mainView()
    }
}


#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
