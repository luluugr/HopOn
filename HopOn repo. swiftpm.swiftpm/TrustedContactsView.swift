import SwiftUI

struct TrustedContact: Identifiable, Codable {
    var id = UUID()
    let name: String
    let phone: String
    let relation: String
}

struct TrustedContactsView: View {
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("trusted_contacts_json") private var contactsJSON: String = "[]"
    @State private var contacts: [TrustedContact] = []
    @State private var showForm = false
    
 
    @State private var newName = ""
    @State private var newPhone = ""
    @State private var newRelation = "Family"
    
    let relationTypes = ["Family", "Friend", "Partner", "Emergency"]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.lightBackground.ignoresSafeArea()
                
                if contacts.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "person.2.slash.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.mediumBlue.opacity(0.5))
                        Text("No Trusted Contacts")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.darkBlue)
                        Text("Add the people we should notify in case of an emergency.")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .foregroundColor(.gray)
                    }
                } else {
                    List {
                        ForEach(contacts) { contact in
                            HStack(spacing: 15) {
                                ZStack {
                                    Circle()
                                        .fill(Color.mediumBlue.opacity(0.1))
                                        .frame(width: 50, height: 50)
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.darkBlue)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(contact.name)
                                        .font(.headline)
                                        .foregroundColor(.darkBlue)
                                    Text(contact.relation)
                                        .font(.caption)
                                        .bold()
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        
                                        .background(Color.softOrange)
                                        .foregroundColor(.darkOrange)
                                        .cornerRadius(4)
                                }
                                Spacer()
                                Image(systemName: "checkmark.shield.fill")
                                    .foregroundColor(.green)
                            }
                            .listRowBackground(Color.white.opacity(0.7))
                        }
                        .onDelete(perform: deleteContact)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Safety Network")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }.fontWeight(.bold)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showForm = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.darkOrange)
                    }
                }
            }
            .sheet(isPresented: $showForm) {
                NavigationStack {
                    Form {
                        Section(header: Text("Contact Details")) {
                            TextField("Name (e.g. Mom)", text: $newName)
                            TextField("Phone (Simulated)", text: $newPhone)
                                .keyboardType(.phonePad)
                            Picker("Relation", selection: $newRelation) {
                                ForEach(relationTypes, id: \.self) { type in Text(type) }
                            }
                        }
                    }
                    .navigationTitle("New Contact")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { showForm = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") { saveContact() }
                            .disabled(newName.isEmpty)
                        }
                    }
                }
            }
        }
        .onAppear { loadContacts() }
    }
    
    func saveContact() {
        let new = TrustedContact(name: newName, phone: newPhone, relation: newRelation)
        contacts.append(new)
        saveToStorage()
        newName = ""; newPhone = ""; showForm = false
    }
    
    func deleteContact(at offsets: IndexSet) {
        contacts.remove(atOffsets: offsets)
        saveToStorage()
    }
    
    func saveToStorage() {
        if let encoded = try? JSONEncoder().encode(contacts),
           let jsonString = String(data: encoded, encoding: .utf8) {
            contactsJSON = jsonString
        }
    }
    
    func loadContacts() {
        if let data = contactsJSON.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([TrustedContact].self, from: data) {
            contacts = decoded
        }
    }
}
