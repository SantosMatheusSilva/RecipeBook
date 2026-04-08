//
//  ContentView.swift
//  RecipeBook
//
//  Created by Matheus Santos on 27/03/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FavoriteRecipe.createdAt, order: .reverse) private var favorites: [FavoriteRecipe]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(favorites) { recipe in
                    NavigationLink {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(recipe.title)
                                .font(.headline)
                            if let category = recipe.category, !category.isEmpty {
                                Text(category)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(recipe.title)
                            Text(recipe.createdAt, format: Date.FormatStyle(date: .numeric, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteFavorites)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        } detail: {
            Text("Select a favourite recipe")
        }
    }

    private func deleteFavorites(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(favorites[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: FavoriteRecipe.self, inMemory: true)
}
