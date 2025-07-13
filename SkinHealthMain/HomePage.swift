import SwiftUI

import SwiftUI

struct HomePage: View {
    let buttons: [String] = [
        "Normal Skin Conditions Analyzer",
        "Calendar",
        "Your History",
        "ABCDE Test",
        "General Cancer Test",
        "Dermatologist Map"
    ]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("Skin Health Dashboard")
                        .font(.largeTitle).bold()
                    Spacer()
                    NavigationLink(value: "Profile Page") {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                }
                .padding()

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(buttons, id: \.self) { label in
                        NavigationLink(value: label) {
                            Text(label)
                                .frame(maxWidth: .infinity, minHeight: 80)
                                .background(Color.green.opacity(0.2))
                                .cornerRadius(10)
                                .foregroundColor(.black)
                        }
                        .buttonStyle(.plain)
                        .simultaneousGesture(
                            TapGesture().onEnded {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            }
                        )
                    }
                }
                .padding()
                Spacer()
            }
            .navigationDestination(for: String.self) { page in
                switch page {
                    // COPY PASTE CODE
                case "General Cancer Test":
                    GeneralSkinCancerView()
                default:
                    VStack {
                        Text(page)
                            .font(.title)
                            .padding()
                        Text("This page is under construction.")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

// COPY PASTE CODE
struct GeneralSkinCancerView: View {
    var body: some View {
        GeneralSkinCancer()
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
    }
}
