import SwiftUI

struct TripDetailView: View {
    @ObservedObject var viewModel: TripViewModel
    @State private var showAddExpense = false
    @State private var showSettlements = false
    @State private var settlementsText = ""

    var body: some View {
        VStack {
            List {
                Section(header: Label("Participants", systemImage: "person.3.fill").font(.headline)) {
                    ForEach(viewModel.trip.participants) { participant in
                        Text(participant.name)
                            .font(.body)
                            .padding(.vertical, 4)
                    }
                }

                Section(header: Label("Expenses", systemImage: "creditcard.fill").font(.headline)) {
                    ForEach(viewModel.trip.expenses) { expense in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(expense.title)
                                .font(.title3).bold()
                                .foregroundColor(.accentColor)
                            HStack {
                                Label("Paid by: \(expense.paidBy.name)", systemImage: "person.fill.checkmark")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("$\(expense.amount, specifier: "%.2f")")
                                    .font(.subheadline).bold()
                                    .foregroundColor(.green)
                            }
                            Text("Shared by: \(expense.sharedBy.map { $0.name }.joined(separator: ", "))")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            Text("Category: \(expense.category)")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        .padding(8)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        .padding(.vertical, 4)
                    }
                }

                Section(header: Label("Balances", systemImage: "chart.pie.fill").font(.headline)) {
                    ForEach(viewModel.calculateBalances().sorted(by: { $0.key.name < $1.key.name }), id: \.key) { participant, balance in
                        HStack {
                            Text(participant.name)
                                .fontWeight(.medium)
                            Spacer()
                            Text(String(format: "$%.2f", balance))
                                .foregroundColor(balance >= 0 ? .green : .red)
                                .bold()
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())

            VStack(spacing: 12) {
                Button {
                    showAddExpense = true
                } label: {
                    Label("Add Expense", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(colors: [Color.blue.opacity(0.8), Color.blue], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(12)
                        .shadow(color: Color.blue.opacity(0.4), radius: 6, x: 0, y: 4)
                }
                .sheet(isPresented: $showAddExpense) {
                    AddExpenseView(viewModel: viewModel, isPresented: $showAddExpense)
                }

                HStack(spacing: 16) {
                    NavigationLink(destination: BudgetView(viewModel: viewModel)) {
                        Label("Manage Budgets", systemImage: "chart.bar.fill")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.85))
                            .cornerRadius(10)
                            .shadow(radius: 3)
                    }

                    NavigationLink(destination: AIInsightsView(viewModel: viewModel)) {
                        Label("View AI Insights", systemImage: "lightbulb.fill")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.85))
                            .cornerRadius(10)
                            .shadow(radius: 3)
                    }
                }

                Button {
                    let settlements = viewModel.calculateSettlements()
                    if settlements.isEmpty {
                        settlementsText = "All settled up! 🎉"
                    } else {
                        settlementsText = settlements.map {
                            "\($0.from.name) owes \($0.to.name) $\(String(format: "%.2f", $0.amount))"
                        }.joined(separator: "\n")
                    }
                    withAnimation {
                        showSettlements = true
                    }
                } label: {
                    Label("Settle", systemImage: "checkmark.seal.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(colors: [Color.purple.opacity(0.85), Color.purple], startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(12)
                        .shadow(color: Color.purple.opacity(0.5), radius: 6, x: 0, y: 4)
                }
                .alert(isPresented: $showSettlements) {
                    Alert(title: Text("Settlement Summary"),
                          message: Text(settlementsText),
                          dismissButton: .default(Text("Thanks!")))
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground).opacity(0.95))
            .shadow(radius: 8)
        }
        .navigationTitle(viewModel.trip.name)
    }
}

