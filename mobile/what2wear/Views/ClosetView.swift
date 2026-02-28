import SwiftUI

/// Main closet tab — shows a filterable grid of saved clothing items.
struct ClosetView: View {

    @StateObject private var viewModel = ClosetViewModel()
    @State private var showAddItem = false

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                if viewModel.items.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 16) {
                            // Filter chips
                            filterBar
                                .padding(.top, 8)

                            // Grid
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(viewModel.filteredItems) { item in
                                    ClothingItemCard(
                                        image: viewModel.loadImage(for: item),
                                        category: item.category,
                                        colorHex: item.colorHex
                                    )
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            viewModel.deleteItem(id: item.id)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
            }
            .navigationTitle("My Closet")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddItem = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.body.weight(.semibold))
                            .foregroundColor(.textPrimary)
                    }
                }
            }
            .sheet(isPresented: $showAddItem) {
                AddClothingView(viewModel: viewModel)
            }
        }
    }

    // MARK: - Filter bar

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ClosetViewModel.FilterOption.allCases, id: \.self) { option in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.selectedFilter = option
                        }
                    } label: {
                        Text(option.rawValue)
                            .font(.subheadline)
                            .fontWeight(viewModel.selectedFilter == option ? .semibold : .regular)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(viewModel.selectedFilter == option ? Color.black : Color(.secondarySystemBackground))
                            .foregroundColor(viewModel.selectedFilter == option ? .white : .primary)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "tshirt.fill")
                .font(.system(size: 64, weight: .light))
                .foregroundColor(Color(.tertiaryLabel))

            Text("Your closet is empty")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)

            Text("Add your first clothing item to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showAddItem = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "plus")
                    Text("Add Item")
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 14)
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(14)
            }
            .padding(.top, 8)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
