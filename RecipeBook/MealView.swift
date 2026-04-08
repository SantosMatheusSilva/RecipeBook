import SwiftUI

struct MealView: View {
    let mealID: String

    var body: some View {
        VStack(spacing: 16) {
            Text("Meal Details")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Meal ID: \(mealID)")
                .font(.body)
                .foregroundStyle(.secondary)

            // TODO: Replace with real meal details UI once API/model is ready.
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.15))
                .frame(height: 180)
                .overlay(
                    VStack(spacing: 8) {
                        ProgressView()
                        Text("Loading meal data...")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                )
        }
        .padding()
        .navigationTitle("Meal")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        MealView(mealID: "52772")
    }
}
