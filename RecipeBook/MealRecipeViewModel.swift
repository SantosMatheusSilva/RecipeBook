//
//  MealRecipeViewModel.swift
//  RecipeBook
//
//  Created by Matheus Santos on 07/04/2026.
//

import Foundation
import Combine

final class MealRecipeViewModel: ObservableObject {
    private let service: RecipeServices

    @Published private(set) var recipe: Recipe?
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?

    init(service: RecipeServices = RecipeServices()) {
        self.service = service
    }

    @MainActor
    func loadRecipe(id: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let recipe = try await service.fetchRecipeByID(id: id)
            self.recipe = recipe
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

