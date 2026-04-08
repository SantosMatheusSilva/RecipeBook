//
//  CategoriesView.swift
//  RecipeBook
//
//  Created by Matheus Santos on 07/04/2026.
//

import SwiftUI
import SwiftData

struct CategoriesView: View {
    @StateObject var viewModel = CategoriesViewModel()
    
    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.categories.isEmpty && viewModel.meals.isEmpty {
                ProgressView("Loading...")
            } else if let error = viewModel.errorMessage, viewModel.categories.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle").foregroundColor(.orange).font(.largeTitle)
                    Text(error).multilineTextAlignment(.center)
                    Button("Try Again") {
                        Task {
                            await viewModel.loadCategories()
                        }
                    }
                }
                .padding()
            } else {
                content
            }
        }
        .navigationTitle("All Categories")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink {
                    FavoritesView()
                } label: {
                    Label("Favorites", systemImage: "heart")
                }
            }

            if viewModel.selectedCategory != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear Selection") { viewModel.clearSelection() }
                }
            }
        }
        .task {
            if viewModel.categories.isEmpty {
                await viewModel.loadCategories()
            }
        }
        .refreshable {
            await viewModel.loadCategories()
        }
    }
    @ViewBuilder
    private var content: some View {
        if let selected = viewModel.selectedCategory {
            // Grid de refeições da categoria selecionada
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 12)], spacing: 12) {
                    ForEach(viewModel.meals) { item in
                        VStack(alignment: .leading, spacing: 8) {
                            AsyncImage(url: item.thumbnailURL) { phase in
                                switch phase {
                                case .empty:
                                    ZStack {
                                        Color.gray.opacity(0.15)
                                        ProgressView()
                                    }
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                case .failure:
                                    ZStack {
                                        Color.gray.opacity(0.15)
                                        Image(systemName: "photo")
                                            .font(.title2)
                                            .foregroundColor(.secondary)
                                    }
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(height: 120)
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                            Text(item.title)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            NavigationLink {
                                MealRecipeView(mealID: item.id)
                            } label: {
                                Text("Go to Recipe")
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(Color.accentColor)
                                    .foregroundColor(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 4)
                        }
                        .padding(10)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)
            } // ScrollView
            .overlay(alignment: .topLeading) {
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                        .allowsHitTesting(false)
                }
            }
            .navigationTitle(selected.name)
        } else {
            // Grid de categorias
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 12)], spacing: 12) {
                    ForEach(viewModel.categories) { category in
                        Button {
                            Task {
                                await viewModel.selectCategory(category)
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "tag")
                                    .foregroundColor(.accentColor)
                                Text(category.name)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .padding(.horizontal, 8)
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)
            }
            .overlay(alignment: .topLeading) {
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                        .allowsHitTesting(false)
                }
            }
        }
    }
}

#Preview {
    CategoriesView()
        .modelContainer(for: FavoriteRecipe.self, inMemory: true)
}
