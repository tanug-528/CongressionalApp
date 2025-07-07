import SwiftUI

struct HomePage: View {
    @State private var selectedPage: String?

    let buttons: [ButtonItem] = [
        ButtonItem(label: "Normal Skin Conditions Analyzer"),
        ButtonItem(label: "Calendar"),
        ButtonItem(label: "Your History"),
        ButtonItem(label: "ABCDE Test"),
        ButtonItem(label: "General Cancer Test"),
        ButtonItem(label: "Dermatologist Map")
    ]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("Skin Health Dashboard")
                        .font(.largeTitle)
                        .bold()
                    Spacer()
                    NavigationLink(value: "Profile Page") {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                }
                .padding()

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(buttons, id: \.self) { button in
                        Button(action: {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            selectedPage = button.label
                        }) {
                            Text(button.label)
                                .frame(maxWidth: .infinity, minHeight: 80)
                                .background(Color.green.opacity(0.2))
                                .cornerRadius(10)
                                .foregroundColor(.black)
                        }
                    }
                }
                .padding()
                Spacer()
            }
            .navigationDestination(for: String.self) { pageLabel in
                PlaceholderPage(label: pageLabel)
            }
            .navigationTitle("") // Optional
            .navigationBarHidden(true)
            .navigationDestination(isPresented: Binding(get: {
                selectedPage != nil
            }, set: { newValue in
                if !newValue {
                    selectedPage = nil
                }
            })) {
                if let selected = selectedPage {
                    PlaceholderPage(label: selected)
                }
            }
        }
    }
}

struct ButtonItem: Hashable {
    let label: String
}

struct PlaceholderPage: View {
    let label: String

    var body: some View {
        Text(label)
            .font(.title)
            .padding()
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
    }
}
