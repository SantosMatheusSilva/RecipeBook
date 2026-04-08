//
//  FavoritesView.swift
//  RecipeBook
//
//  Created by Matheus Santos on 08/04/2026.
//

import SwiftUI
import SwiftData

struct FavoritesView: View {
    @StateObject private var viewModel = FavoriteViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Group {
            if viewModel.favorites.isEmpty {
                ContentUnavailableView(
                    "No favourites yet",
                    systemImage: "heart.slash",
                    description: Text("Save recipes to find them here later.")
                )
            } else {
                List {
                    ForEach(viewModel.favorites) { favorite in
                        NavigationLink {
                            MealRecipeView(mealID: favorite.id)
                        } label: {
                            HStack(spacing: 12) {
                                thumbnail(for: favorite)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(favorite.title)
                                        .font(.headline)
                                        .lineLimit(2)

                                    if let category = favorite.category, !category.isEmpty {
                                        Text(category)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }

                                    if let area = favorite.area, !area.isEmpty {
                                        Text(area)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete(perform: viewModel.remove)
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Favorites")
        .toolbar {
            if !viewModel.favorites.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
        }
        .task {
            viewModel.configure(with: modelContext)
        }
        .onAppear {
            viewModel.reload()
        }
    }

    @ViewBuilder
    private func thumbnail(for favorite: FavoriteRecipe) -> some View {
        if
            let imageURLString = favorite.imageURLString,
            let imageURL = URL(string: imageURLString)
        {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.15))
                        ProgressView()
                    }
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    placeholderThumbnail
                @unknown default:
                    placeholderThumbnail
                }
            }
            .frame(width: 72, height: 72)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            placeholderThumbnail
                .frame(width: 72, height: 72)
        }
    }

    private var placeholderThumbnail: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.15))
            Image(systemName: "fork.knife")
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        FavoritesView()
    }
    .modelContainer(for: FavoriteRecipe.self, inMemory: true)
}
