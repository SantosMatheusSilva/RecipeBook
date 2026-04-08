//
//  RecipeServices.swift
//  RecipeBook
//
//  Created by Matheus Santos on 27/03/2026.
//

import Foundation

struct RecipeResponse: Decodable {
    let meals: [Recipe]?
}

class RecipeServices {
    
    let baseUrl = APIHandler.shared.baseURL

    private func performRequest<T: Decodable>(urlString: String, decode type: T.Type) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "RecipeServices", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL inválida"])
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "RecipeServices", code: -3, userInfo: [NSLocalizedDescriptionKey: "Resposta inválida do servidor"])
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "RecipeServices", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Erro no servidor: \(httpResponse.statusCode)"])
        }

        return try JSONDecoder().decode(type, from: data)
    }
    
    // search.php?s=Arrabiata -> endpoint para busca por nome
    func fetchRecipeByName(name: String) async throws -> [Recipe] {
        let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
        let urlString = "\(baseUrl)/search.php?s=\(encodedName)"

        let recipeResponse = try await performRequest(urlString: urlString, decode: RecipeResponse.self)
        return recipeResponse.meals ?? []
    }
    
    // list.php?c=list -> endpoint para listar categorias
    func fetchCategoryNames() async throws -> [CategoryName] {
        let urlString = "\(baseUrl)/list.php?c=list"
        let decoded = try await performRequest(urlString: urlString, decode: CategoryNameResponse.self)
        return decoded.meals
    }
    
    // filter.php?c=... -> endpoint para listar receitas de uma categoria
    func fetchMealsByCategory(category: String) async throws -> [MealListItem] {
        let encodedCategory = category.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? category
        let urlString = "\(baseUrl)/filter.php?c=\(encodedCategory)"
        let decoded = try await performRequest(urlString: urlString, decode: MealsByCategoryResponse.self)
        return decoded.meals
    }
    
    // lookup.php?i=... -> endpoint para buscar receita completa
    func fetchRecipeByID(id: String) async throws -> Recipe {
        let trimmed = id.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw NSError(domain: "RecipeServices", code: -4, userInfo: [NSLocalizedDescriptionKey: "ID vazio"])
        }

        let urlString = "\(baseUrl)/lookup.php?i=\(trimmed)"
        let decoded = try await performRequest(urlString: urlString, decode: MealResponse.self)
        if let meal = decoded.meals?.first {
            return Recipe(from: meal)
        } else {
            throw NSError(domain: "RecipeServices", code: -5, userInfo: [NSLocalizedDescriptionKey: "Receita não encontrada"])
        }
    }
}
