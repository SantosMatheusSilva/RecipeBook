//
//  Models.swift
//  RecipeBook
//
//  Created by Matheus Santos on 27/03/2026.
//

import Foundation

// Wrapper da resposta da API TheMealDB
struct MealResponse: Codable {
    let meals: [Meal]?
}

// Modelo cru conforme a API TheMealDB
struct Meal: Codable, Identifiable {
    let id: String
    let name: String?
    let category: String?
    let area: String?
    let instructions: String?
    let thumbnailURL: URL?
    let tags: [String]?
    let youtubeURL: URL?
    let sourceURL: URL?
    let ingredients: [Ingredient]

    enum CodingKeys: String, CodingKey {
        case id = "idMeal"
        case name = "strMeal"
        case category = "strCategory"
        case area = "strArea"
        case instructions = "strInstructions"
        case thumbnailURL = "strMealThumb"
        case strTags
        case youtubeURL = "strYoutube"
        case sourceURL = "strSource"
        // ingredientes e medidas 1..20
        case strIngredient1, strIngredient2, strIngredient3, strIngredient4, strIngredient5,
             strIngredient6, strIngredient7, strIngredient8, strIngredient9, strIngredient10,
             strIngredient11, strIngredient12, strIngredient13, strIngredient14, strIngredient15,
             strIngredient16, strIngredient17, strIngredient18, strIngredient19, strIngredient20,
             strMeasure1, strMeasure2, strMeasure3, strMeasure4, strMeasure5,
             strMeasure6, strMeasure7, strMeasure8, strMeasure9, strMeasure10,
             strMeasure11, strMeasure12, strMeasure13, strMeasure14, strMeasure15,
             strMeasure16, strMeasure17, strMeasure18, strMeasure19, strMeasure20
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.category = try container.decodeIfPresent(String.self, forKey: .category)
        self.area = try container.decodeIfPresent(String.self, forKey: .area)
        self.instructions = try container.decodeIfPresent(String.self, forKey: .instructions)
        if let thumbString = try container.decodeIfPresent(String.self, forKey: .thumbnailURL) {
            self.thumbnailURL = URL(string: thumbString)
        } else { self.thumbnailURL = nil }

        if let tagsString = try container.decodeIfPresent(String.self, forKey: .strTags) {
            let parts = tagsString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            self.tags = parts.isEmpty ? nil : parts
        } else { self.tags = nil }

        if let yt = try container.decodeIfPresent(String.self, forKey: .youtubeURL) {
            self.youtubeURL = URL(string: yt)
        } else { self.youtubeURL = nil }

        if let src = try container.decodeIfPresent(String.self, forKey: .sourceURL) {
            self.sourceURL = URL(string: src)
        } else { self.sourceURL = nil }

        // Construir ingredientes/medidas
        var built: [Ingredient] = []
        for i in 1...20 {
            let ingKey = CodingKeys(rawValue: "strIngredient\(i)")!
            let measKey = CodingKeys(rawValue: "strMeasure\(i)")!
            let name = try container.decodeIfPresent(String.self, forKey: ingKey)?.trimmingCharacters(in: .whitespacesAndNewlines)
            let measure = try container.decodeIfPresent(String.self, forKey: measKey)?.trimmingCharacters(in: .whitespacesAndNewlines)
            if let name, !name.isEmpty {
                let m = (measure?.isEmpty == false) ? measure : nil
                built.append(Ingredient(name: name, measure: m))
            }
        }
        self.ingredients = built
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(category, forKey: .category)
        try container.encodeIfPresent(area, forKey: .area)
        try container.encodeIfPresent(instructions, forKey: .instructions)
        try container.encodeIfPresent(thumbnailURL?.absoluteString, forKey: .thumbnailURL)
        if let tags, !tags.isEmpty {
            try container.encode(tags.joined(separator: ","), forKey: .strTags)
        }
        try container.encodeIfPresent(youtubeURL?.absoluteString, forKey: .youtubeURL)
        try container.encodeIfPresent(sourceURL?.absoluteString, forKey: .sourceURL)

        // Escrever até 20 pares
        for i in 1...20 {
            let ingKey = CodingKeys(rawValue: "strIngredient\(i)")!
            let measKey = CodingKeys(rawValue: "strMeasure\(i)")!
            if i <= ingredients.count {
                let ingredient = ingredients[i - 1]
                try container.encode(ingredient.name, forKey: ingKey)
                if let m = ingredient.measure, !m.isEmpty {
                    try container.encode(m, forKey: measKey)
                }
            } else {
                // Preencher com vazio para manter compatibilidade se necessário
                try container.encode("", forKey: ingKey)
                try container.encode("", forKey: measKey)
            }
        }
    }
}
struct Ingredient: Codable, Hashable {
    let name: String
    let measure: String?
}

// Modelo de domínio simplificado para uso no app
struct Recipe: Codable, Identifiable {
    let id: String
    let title: String
    let category: String?
    let area: String?
    let instructions: String?
    let imageURL: URL?
    let tags: [String]?
    let youtubeURL: URL?
    let sourceURL: URL?
    let ingredients: [Ingredient]

    init(from meal: Meal) {
        self.id = meal.id
        self.title = meal.name ?? ""
        self.category = meal.category
        self.area = meal.area
        self.instructions = meal.instructions
        self.imageURL = meal.thumbnailURL
        self.tags = meal.tags
        self.youtubeURL = meal.youtubeURL
        self.sourceURL = meal.sourceURL
        self.ingredients = meal.ingredients
    }
}

// Resposta de categorias simples (https://www.themealdb.com/api/json/v1/1/list.php?c=list)
struct CategoryNameResponse: Codable {
    let meals: [CategoryName]
}
struct CategoryName: Codable, Identifiable {
    let id: String
    let name: String

    enum CodingKeys: String, CodingKey {
        case strCategory
    }

    init(id: String, name: String) {
        self.id = id
        self.name = name
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let value = try container.decode(String.self, forKey: .strCategory)
        self.name = value
        self.id = value // usar o próprio nome como id estável
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .strCategory)
    }
}

// Resposta de refeições por categoria (https://www.themealdb.com/api/json/v1/1/filter.php?c=...)
struct MealsByCategoryResponse: Codable {
    let meals: [MealListItem]
}

struct MealListItem: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let thumbnailURL: URL?

    enum CodingKeys: String, CodingKey {
        case id = "idMeal"
        case title = "strMeal"
        case thumbnailURL = "strMealThumb"
    }
}

