//
//  FavouritesViewModel.swift
//  RecipeBook
//
//  Created by Matheus Santos on 08/04/2026.
//

import Foundation
import Combine
import SwiftData

@MainActor
final class FavoriteViewModel: ObservableObject {
    @Published private(set) var favorites: [FavoriteRecipe] = []

    private var modelContext: ModelContext?

    func configure(with modelContext: ModelContext) {
        self.modelContext = modelContext
        reload()
    }

    func reload() {
        guard let modelContext else { return }

        do {
            let descriptor = FetchDescriptor<FavoriteRecipe>(
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            favorites = try modelContext.fetch(descriptor)
        } catch {
            print("[FavoriteViewModel] fetch error: \(error)")
            favorites = []
        }
    }

    func isFavourite(mealID: String) -> Bool {
        favorites.contains(where: { $0.id == mealID })
    }

    func add(recipe: Recipe) {
        guard let modelContext else { return }
        guard !isFavourite(mealID: recipe.id) else { return }

        let favorite = FavoriteRecipe(
            id: recipe.id,
            title: recipe.title,
            category: recipe.category,
            area: recipe.area,
            instructions: recipe.instructions,
            imageURLString: recipe.imageURL?.absoluteString
        )

        modelContext.insert(favorite)
        saveAndReload()
    }

    func add(mealID: String, title: String, thumbnailURLString: String?) {
        guard !isFavourite(mealID: mealID) else { return }
        guard let modelContext else { return }

        let favorite = FavoriteRecipe(
            id: mealID,
            title: title,
            imageURLString: thumbnailURLString
        )

        modelContext.insert(favorite)
        saveAndReload()
    }

    func remove(mealID: String) {
        guard let modelContext else { return }

        if let existing = favorites.first(where: { $0.id == mealID }) {
            modelContext.delete(existing)
            saveAndReload()
            return
        }

        do {
            let predicate = #Predicate<FavoriteRecipe> { $0.id == mealID }
            let descriptor = FetchDescriptor<FavoriteRecipe>(predicate: predicate)
            if let first = try modelContext.fetch(descriptor).first {
                modelContext.delete(first)
                saveAndReload()
            }
        } catch {
            print("[FavoriteViewModel] remove fetch error: \(error)")
        }
    }

    func remove(at offsets: IndexSet) {
        for index in offsets {
            let mealID = favorites[index].id
            remove(mealID: mealID)
        }
    }

    func toggle(recipe: Recipe) {
        if isFavourite(mealID: recipe.id) {
            remove(mealID: recipe.id)
        } else {
            add(recipe: recipe)
        }
    }

    private func saveAndReload() {
        guard let modelContext else { return }

        do {
            try modelContext.save()
        } catch {
            print("[FavoriteViewModel] save error: \(error)")
        }

        reload()
    }
}

typealias FavouritesViewModel = FavoriteViewModel
