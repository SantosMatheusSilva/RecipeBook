//
//  MealRecipeView.swift
//  RecipeBook
//
//  Created by Matheus Santos on 07/04/2026.
//

import SwiftUI
import SwiftData

struct MealRecipeView: View {
    @StateObject private var viewModel = MealRecipeViewModel()
    @StateObject private var favoriteViewModel = FavoriteViewModel()
    @Environment(\.modelContext) private var modelContext
    let mealID: String

    var body: some View {
        content
            .task(id: mealID) {
                await viewModel.loadRecipe(id: mealID)
            }
            .task {
                favoriteViewModel.configure(with: modelContext)
            }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView("Loading…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let recipe = viewModel.recipe {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header(recipe)
                    meta(recipe)
                    if !recipe.ingredients.isEmpty {
                        Text("Ingredients").font(.headline)
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(recipe.ingredients, id: \.self) { ing in
                                HStack {
                                    Text(ing.name)
                                    Spacer()
                                    if let measure = ing.measure, !measure.isEmpty {
                                        Text(measure).foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                    if let instructions = recipe.instructions, !instructions.isEmpty {
                        Text("Instructions").font(.headline)
                        Text(instructions)
                    }
                    if let source = recipe.sourceURL {
                        Link(destination: source) {
                            Label("View source", systemImage: "link")
                                .font(.body)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(recipe.title)
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 0) {
                    Divider()
                    Button {
                        favoriteViewModel.toggle(recipe: recipe)
                    } label: {
                        Label(
                            favoriteViewModel.isFavourite(mealID: recipe.id) ? "Remove from favourites" : "Add to favourites",
                            systemImage: favoriteViewModel.isFavourite(mealID: recipe.id) ? "heart.fill" : "heart"
                        )
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(.thinMaterial)
            }
        } else if let error = viewModel.errorMessage {
            ContentUnavailableView("Error", systemImage: "exclamationmark.triangle", description: Text(error))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ContentUnavailableView("No data", systemImage: "fork.knife", description: Text("Select a recipe"))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    
    @ViewBuilder
    private func header(_ recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let thumb = recipe.imageURL {
                AsyncImage(url: thumb) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    ZStack {
                        Rectangle().fill(.quaternary)
                        ProgressView()
                    }
                }
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    @ViewBuilder
    private func meta(_ recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                if let category = recipe.category, !category.isEmpty {
                    Label(category, systemImage: "square.grid.2x2")
                }
                if let area = recipe.area, !area.isEmpty {
                    Label(area, systemImage: "globe")
                }
            }
            .foregroundStyle(.secondary)

            if let tagsString = recipe.tags, !tagsString.isEmpty {
                let tags: [String] = tagsString
                    //.split(separator: ",")
                    //.map { String($0).trimmingCharacters(in: //CharacterSet.whitespacesAndNewlines) }
                    //.filter { !$0.isEmpty }
                if !tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(tags.indices, id: \.self) { idx in
                                TagView(text: tags[idx])
                            }
                        }
                    }
                }
            }
            if let youtube = recipe.youtubeURL {
                Link(destination: youtube) {
                    Label("Watch on youtube", systemImage: "play.rectangle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private func ingredients(_ recipe: Recipe) -> [(String, String?)] {
        // Considerando o modelo Recipe estilo TheMealDB com pares strIngredientX e strMeasureX
        var result: [(String, String?)] = []
        let mirror = Mirror(reflecting: recipe)
        let ingredientPairs: [(String?, String?)] = (1...20).map { i in
            let ingKey = "strIngredient\(i)"
            let meaKey = "strMeasure\(i)"
            let ing = mirror.children.first { $0.label == ingKey }?.value as? String
            let mea = mirror.children.first { $0.label == meaKey }?.value as? String
            return (ing?.trimmingCharacters(in: .whitespacesAndNewlines), mea?.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        for (name, measure) in ingredientPairs {
            if let name, !name.isEmpty { result.append((name, measure)) }
        }
        return result
    }
}

private struct TagView: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Capsule().fill(Color.secondary.opacity(0.15)))
    }
}

#Preview {
    NavigationStack {
        MealRecipeView(mealID: "52771")
    }
    .modelContainer(for: FavoriteRecipe.self, inMemory: true)
}
