//
//  Item.swift
//  RecipeBook
//
//  Created by Matheus Santos on 27/03/2026.
//

import Foundation
import SwiftData

@Model
final class FavoriteRecipe {
    @Attribute(.unique) var id: String
    var title: String
    var category: String?
    var area: String?
    var instructions: String?
    var imageURLString: String?
    var createdAt: Date

    init(
        id: String,
        title: String,
        category: String? = nil,
        area: String? = nil,
        instructions: String? = nil,
        imageURLString: String? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.area = area
        self.instructions = instructions
        self.imageURLString = imageURLString
        self.createdAt = createdAt
    }
}
