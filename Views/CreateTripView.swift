import SwiftUI

struct CreateTripView: View {
    @State private var tripName = ""
    @State private var participantName = ""
    @State private var participants: [Participant] = []
    @State private var tripCreated = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    Spacer(minLength: 30)

                    // Title with icon
                    VStack(spacing: 8) {
                        Image(systemName: "airplane.departure")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            .foregroundColor(.yellow)
                            .shadow(radius: 10)

                        Text("Plan Your Trip")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundColor(.yellow)

                        Text("Create a trip and add participants to get started!")
                            .font(.headline)
                            .foregroundColor(.yellow.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }

                    // Input for trip name with icon inside
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Trip Name")
                            .font(.title3)
                            .foregroundColor(.yellow.opacity(0.85))
                            .bold()

                        HStack {
                            Image(systemName: "tag.fill")
                                .foregroundColor(.yellow.opacity(0.7))

                            TextField("Enter your trip name", text: $tripName)
                                .foregroundColor(.yellow)
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                                .disableAutocorrection(true)
                        }
                        .padding(14)
                        .background(Color.white.opacity(0.12))
                        .cornerRadius(15)
                        .shadow(color: Color.yellow.opacity(0.3), radius: 6, x: 0, y: 4)
                    }
                    .padding(.horizontal, 32)

                    // Participants input + add button
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Add Participants")
                            .font(.title3)
                            .foregroundColor(.yellow.opacity(0.85))
                            .bold()

                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(.yellow.opacity(0.7))

                            TextField("Participant name", text: $participantName)
                                .foregroundColor(.yellow)
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .disableAutocorrection(true)

                            Button(action: addParticipant) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 34))
                                    .foregroundColor(participantName.isEmpty ? Color.yellow.opacity(0.35) : Color.green.opacity(0.9))
                                    .shadow(color: participantName.isEmpty ? .clear : Color.green.opacity(0.6), radius: 8, x: 0, y: 3)
                            }
                            .disabled(participantName.isEmpty)
                            .animation(.easeInOut, value: participantName.isEmpty)
                        }
                        .padding(14)
                        .background(Color.white.opacity(0.12))
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.5), radius: 6, x: 0, y: 3)
                    }
                    .padding(.horizontal, 32)

                    // Participants list with delete only
                    if participants.isEmpty {
                        Text("No participants added yet. Add some friends!")
                            .foregroundColor(.yellow.opacity(0.6))
                            .italic()
                            .font(.system(size: 18, design: .rounded))
                            .padding(.vertical, 20)
                            .frame(maxWidth: .infinity)
                    } else {
                        List {
                            ForEach(participants) { participant in
                                HStack {
                                    Image(systemName: "person.crop.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.system(size: 22))
                                    Text(participant.name)
                                        .font(.system(size: 18, weight: .medium, design: .rounded))
                                        .foregroundColor(.yellow)
                                }
                                .padding(.vertical, 6)
                                .listRowBackground(Color.black.opacity(0.25))
                            }
                            .onDelete(perform: deleteParticipant)
                        }
                        .listStyle(PlainListStyle())
                        .frame(maxHeight: 200) // fixed height so it doesn't push other UI out
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.3), radius: 12, x: 0, y: 5)
                        .padding(.horizontal, 32)
                    }

                    Spacer()

                    // Create Trip button
                    Button(action: {
                        tripCreated = true
                    }) {
                        Text("Create Trip")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(tripName.isEmpty || participants.isEmpty ? Color.white.opacity(0.25) : Color.green)
                            .foregroundColor(tripName.isEmpty || participants.isEmpty ? Color.white.opacity(0.7) : Color.white)
                            .cornerRadius(30)
                            .shadow(color: tripName.isEmpty || participants.isEmpty ? .clear : Color.green.opacity(0.8), radius: 14, x: 0, y: 7)
                    }
                    .disabled(tripName.isEmpty || participants.isEmpty)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)

                    NavigationLink(
                        destination: TripDetailView(viewModel: TripViewModel(tripName: tripName, participants: participants)),
                        isActive: $tripCreated
                    ) {
                        EmptyView()
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }

    private func addParticipant() {
        let trimmedName = participantName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        let newParticipant = Participant(name: trimmedName)
        participants.append(newParticipant)
        participantName = ""
        hideKeyboard()
    }

    private func deleteParticipant(at offsets: IndexSet) {
        participants.remove(atOffsets: offsets)
    }
}

// Keyboard dismissal helper
#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

