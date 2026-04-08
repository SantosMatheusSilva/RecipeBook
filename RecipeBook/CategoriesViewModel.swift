//
//  CategoriesViewModel.swift
//  RecipeBook
//
//  Created by Matheus Santos on 07/04/2026.
//

import Foundation
import Combine

@MainActor
class CategoriesViewModel: ObservableObject {
    // Services
    private let service: RecipeServices

    // Published state
    @Published private(set) var categories: [CategoryName] = []
    @Published private(set) var meals: [MealListItem] = []
    @Published var selectedCategory: CategoryName? = nil
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String? = nil

    init(service: RecipeServices = RecipeServices()) {
        self.service = service
    }

    // Carrega todas as categorias
    func loadCategories() async {
        isLoading = true
        errorMessage = nil

        do {
            categories = try await service.fetchCategoryNames()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // Seleciona uma categoria e busca suas refeições
    func selectCategory(_ category: CategoryName) async {
        selectedCategory = category
        await fetchMeals(for: category)
    }

    // Atualiza refeições da categoria selecionada
    func fetchMeals(for category: CategoryName) async {
        isLoading = true
        errorMessage = nil

        do {
            meals = try await service.fetchMealsByCategory(category: category.name)
        } catch {
            errorMessage = error.localizedDescription
            meals = []
        }

        isLoading = false
    }

    // Limpa seleção e lista de refeições
    func clearSelection() {
        selectedCategory = nil
        meals = []
    }
}
