import SwiftUI

struct AddExpenseView: View {
    @ObservedObject var viewModel: TripViewModel
    @Binding var isPresented: Bool

    @State private var title = ""
    @State private var amount = ""
    @State private var selectedPayer: Participant?
    @State private var selectedParticipants = Set<Participant>()
    @State private var category = ""
    @State private var editingExpenseId: UUID? = nil // Track which expense is being edited

    var body: some View {
        NavigationView {
            Form {
                Section(header: Label("Expense Info", systemImage: "doc.text.fill")) {
                    TextField("Title", text: $title)
                        .textInputAutocapitalization(.words)
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    Picker("Paid By", selection: $selectedPayer) {
                        Text("Select").tag(Optional<Participant>(nil))
                        ForEach(viewModel.trip.participants) { participant in
                            Text(participant.name).tag(Optional(participant))
                        }
                    }
                }

                Section(header: Label("Shared By", systemImage: "person.3.fill")) {
                    ForEach(viewModel.trip.participants) { participant in
                        MultipleSelectionRow(title: participant.name, isSelected: selectedParticipants.contains(participant)) {
                            if selectedParticipants.contains(participant) {
                                selectedParticipants.remove(participant)
                            } else {
                                selectedParticipants.insert(participant)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section(header: Label("Category", systemImage: "tag.fill")) {
                    TextField("e.g. Food, Travel", text: $category)
                        .textInputAutocapitalization(.words)
                }

                Section(header: Label("Existing Expenses", systemImage: "tray.full.fill")) {
                    ForEach(viewModel.trip.expenses) { expense in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(expense.title).font(.headline)
                                Text("$\(String(format: "%.2f", expense.amount)) • \(expense.category)")
                                    .font(.subheadline).foregroundColor(.secondary)
                            }
                            Spacer()
                            
                            HStack(spacing: 16) {
                                Button(action: {
                                    // First remove the expense from the list
                                    if let index = viewModel.trip.expenses.firstIndex(where: { $0.id == expense.id }) {
                                        viewModel.trip.expenses.remove(at: index)
                                    }
                                    
                                    // Then populate the form fields with the expense data
                                    title = expense.title
                                    amount = String(expense.amount)
                                    selectedPayer = expense.paidBy
                                    selectedParticipants = Set(expense.sharedBy)
                                    category = expense.category
                                    editingExpenseId = expense.id // Track that we're editing this expense
                                }) {
                                    Image(systemName: "pencil.circle")
                                        .foregroundColor(.blue)
                                }
                                .buttonStyle(BorderlessButtonStyle())

                                Button(action: {
                                    // Clear input fields if this expense is currently being edited
                                    if editingExpenseId == expense.id {
                                        clearForm()
                                    }
                                    
                                    // Delete the expense using the proper viewModel method
                                    viewModel.deleteExpense(expense)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Add Expense")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard !title.isEmpty,
                              let amt = Double(amount),
                              let payer = selectedPayer,
                              !selectedParticipants.isEmpty,
                              !category.isEmpty else { return }

                        viewModel.addExpense(title: title, amount: amt, paidBy: payer, sharedBy: Array(selectedParticipants), category: category)

                        // Reset fields
                        clearForm()

                        isPresented = false
                    }
                    .fontWeight(.bold)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    // Helper function to clear the form
    private func clearForm() {
        title = ""
        amount = ""
        selectedPayer = nil
        selectedParticipants = []
        category = ""
        editingExpenseId = nil
    }
}

struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: self.action) {
            HStack {
                Text(self.title)
                    .font(.body)
                    .foregroundColor(.primary)
                Spacer()
                if self.isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentColor)
                        .imageScale(.large)
                }
            }
            .contentShape(Rectangle())
        }
    }
}
