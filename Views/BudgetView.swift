import SwiftUI

struct BudgetView: View {
    @ObservedObject var viewModel: TripViewModel
    @State private var categoryName: String = ""
    @State private var budgetAmount: String = ""
    @State private var editingCategory: String? = nil
    
    var body: some View {
        Form {
            Section(header: Label("Set Budget", systemImage: "slider.horizontal.3")) {
                TextField("Category", text: $categoryName)
                    .textInputAutocapitalization(.words)
                TextField("Amount", text: $budgetAmount)
                    .keyboardType(.decimalPad)
                
                HStack {
                    Button(action: {
                        print("Button pressed - Category: '\(categoryName)', Amount: '\(budgetAmount)', Editing: \(editingCategory ?? "nil")")
                        
                        guard let amount = Double(budgetAmount), !categoryName.isEmpty else {
                            print("Invalid input")
                            return
                        }
                        
                        // If we're editing and category name changed, delete the old one
                        if let oldCategory = editingCategory, oldCategory != categoryName {
                            print("Category name changed from '\(oldCategory)' to '\(categoryName)' - deleting old")
                            viewModel.deleteBudget(for: oldCategory)
                        }
                        
                        print("Setting budget: category='\(categoryName)', amount=\(amount)")
                        viewModel.setBudget(category: categoryName, amount: amount)
                        
                        print("Budget status after update: \(viewModel.budgetStatus())")
                        clearForm()
                    }) {
                        Text(editingCategory != nil ? "Update Budget" : "Add Budget")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background((categoryName.isEmpty || budgetAmount.isEmpty) ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(categoryName.isEmpty || budgetAmount.isEmpty)
                    
                    // Cancel button (only show when editing)
                    if editingCategory != nil {
                        Button(action: {
                            print("Cancel pressed")
                            clearForm()
                        }) {
                            Text("Cancel")
                                .padding()
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(.vertical, 6)
            }
            
            Section(header: Label("Current Budgets", systemImage: "list.bullet")) {
                ForEach(viewModel.budgetStatus().sorted(by: { $0.key < $1.key }), id: \.key) { category, status in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(category)
                                .fontWeight(.medium)
                            if editingCategory == category {
                                Text("Editing...")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        Spacer()
                        
                        Text(String(format: "$%.2f / $%.2f", status.spent, status.budget))
                            .foregroundColor(status.isOver ? .red : .green)
                            .bold()
                        
                        // Edit Button
                        Button(action: {
                            print("Edit button pressed for category: '\(category)', budget: \(status.budget)")
                            startEditing(category: category, budget: status.budget)
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(editingCategory == category ? .blue : .primary)
                                .frame(width: 30, height: 30)
                                .contentShape(Rectangle())
                        }
                        .disabled(editingCategory != nil && editingCategory != category)
                        .buttonStyle(PlainButtonStyle())
                        
                        // Delete Button
                        Button(action: {
                            print("Delete button pressed for category: '\(category)'")
                            deleteCategory(category)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .frame(width: 30, height: 30)
                                .contentShape(Rectangle())
                        }
                        .disabled(editingCategory == category)
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.vertical, 6)
                    .background(editingCategory == category ? Color.blue.opacity(0.1) : Color.clear)
                    .cornerRadius(8)
                }
            }
        }
        .navigationTitle("Budget Tracker")
        .listStyle(InsetGroupedListStyle())
    }
    
    private func startEditing(category: String, budget: Double) {
        print("Starting edit - Category: '\(category)', Budget: \(budget)")
        categoryName = category
        budgetAmount = String(format: "%.2f", budget)
        editingCategory = category
        print("Form populated - CategoryName: '\(categoryName)', BudgetAmount: '\(budgetAmount)', EditingCategory: \(editingCategory ?? "nil")")
    }
    
    private func deleteCategory(_ category: String) {
        print("Deleting category: '\(category)'")
        if editingCategory == category {
            print("Clearing form because deleting currently editing category")
            clearForm()
        }
        viewModel.deleteBudget(for: category)
    }
    
    private func clearForm() {
        print("Clearing form")
        categoryName = ""
        budgetAmount = ""
        editingCategory = nil
        print("Form cleared - CategoryName: '\(categoryName)', BudgetAmount: '\(budgetAmount)', EditingCategory: \(editingCategory ?? "nil")")
    }
}
