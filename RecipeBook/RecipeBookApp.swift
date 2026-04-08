//
//  RecipeBookApp.swift
//  RecipeBook
//
//  Created by Matheus Santos on 27/03/2026.
//

import SwiftUI
import SwiftData

@main
struct RecipeBookApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                CategoriesView() // view principal 
            }
            .modelContainer(for: [FavoriteRecipe.self])
        }
    }
}

#Preview("App Root") {
    NavigationStack {
        CategoriesView()
    }
    .modelContainer(for: FavoriteRecipe.self, inMemory: true)
}
