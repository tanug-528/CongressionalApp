import SwiftUI

// MARK: - ButtonItem Model
struct ButtonItem: Hashable, Identifiable {
    let id = UUID()
    let label: String
}

func iconName(for label: String) -> String {
    switch label {
    case "Normal Skin Conditions Analyzer": return "magnifyingglass"
    case "Calendar": return "calendar"
    case "Your History": return "clock.arrow.circlepath"
    case "ABCDE Test": return "checkmark.seal"
    case "General Cancer Test": return "cross.case"
    case "Dermatologist Map": return "map"
    default: return "questionmark"
    }
}

// MARK: - HomePage View
struct HomePage: View {
    let buttons: [ButtonItem] = [
        ButtonItem(label: "Normal Skin Conditions Analyzer"),
        ButtonItem(label: "Calendar"),
        ButtonItem(label: "Your History"),
        ButtonItem(label: "ABCDE Test"),
        ButtonItem(label: "General Cancer Test"),
        ButtonItem(label: "Dermatologist Map")
    ]

    let tileColors: [Color] = [
        Color(red: 1.0, green: 0.86, blue: 0.86),
        Color(red: 1.0, green: 0.95, blue: 0.92),
        Color(red: 1.0, green: 0.91, blue: 0.8),
        Color(red: 1.0, green: 0.84, blue: 0.73)
    ]

    @State private var selectedPage: String? = nil
    @State private var showConfirmation = false

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
                    ForEach(Array(buttons.enumerated()), id: \.offset) { index, button in
                        NavigationLink(value: button.label) {
                            VStack(spacing: 8) {
                                Image(systemName: iconName(for: button.label))
                                    .font(.system(size: 30))
                                Text(button.label)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity, minHeight: 80)
                            .background(tileColors[index % tileColors.count])
                            .cornerRadius(10)
                            .foregroundColor(.black)
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                        })
                    }
                }
                .padding()

                Spacer()
            }
            .navigationTitle("")
            .navigationDestination(for: String.self) { label in
                destinationView(for: label)
            }
            .alert(isPresented: $showConfirmation) {
                Alert(
                    title: Text("Profile Saved"),
                    message: Text("Your changes have been saved successfully."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    @ViewBuilder
    func destinationView(for label: String?) -> some View {
        switch label {
        case "Your History":
            YourHistoryView()
        case "Profile Page":
            ProfilePage()
        case let other?:
            PlaceholderPage(label: other)
        default:
            EmptyView()
        }
    }
}



// MARK: - PlaceholderPage View
struct PlaceholderPage: View {
    let label: String

    var body: some View {
        Text(label)
            .font(.title)
            .padding()
    }
}

// MARK: - YourHistoryView
struct YourHistoryView: View {
    @AppStorage("age") private var age: Double = 25
    @AppStorage("gender") private var gender = "Select"
    @AppStorage("ethnicity") private var ethnicity = "Select"
    @AppStorage("hairColor") private var hairColor = "Select"
    @AppStorage("skinColor") private var skinColor = "Select"
    @AppStorage("uvExposure") private var uvExposure = "Select"
    @AppStorage("tanningFrequency") private var tanningFrequency = "Select"
    @AppStorage("sunscreenUsage") private var sunscreenUsage = "Select"
    @AppStorage("moleCount") private var moleCount = "Select"
    @AppStorage("familyCancerHistory") private var familyCancerHistory = ""
    @State private var selectedFamilyMembers: Set<String> = []
    @AppStorage("cancerType") private var cancerType = "Not sure"
    @AppStorage("diagnosisAge") private var diagnosisAge = "Not sure"
    @State private var showConfirmation = false

    let genders = ["Male", "Female", "Non-binary", "Prefer not to say"]
    let ethnicities = ["Asian", "Black", "Caucasian", "Hispanic", "Mixed", "Other"]
    let hairColors = ["Black", "Brown", "Blonde", "Red", "Grey/White", "Other"]
    let skinTones: [(String, Color)] = [
        ("Very Light", Color(red: 1.0, green: 0.9, blue: 0.8)),
        ("Light", Color(red: 1.0, green: 0.85, blue: 0.7)),
        ("Medium", Color(red: 0.9, green: 0.7, blue: 0.5)),
        ("Olive", Color(red: 0.8, green: 0.6, blue: 0.4)),
        ("Brown", Color(red: 0.6, green: 0.4, blue: 0.25)),
        ("Dark Brown", Color(red: 0.4, green: 0.3, blue: 0.2))
    ]
    let uvOptions = ["<15 mins", "15–30 mins", "30–60 mins", "1–2 hours", ">2 hours"]
    let frequencyOptions = ["Never", "Rarely", "Sometimes", "Often", "Always"]
    let moleOptions = ["None", "Few (1–10)", "Some (10–30)", "Many (30+)"]
    let familyMembers = ["Parent", "Sibling", "Child", "Grandparent", "Other"]
    let cancerTypes = ["Melanoma", "Basal Cell Carcinoma", "Squamous Cell Carcinoma", "Merkel Cell Carcinoma", "Kaposi Sarcoma", "Not sure"]
    let diagnosisAges = ["1-10", "10-18", "19-25", "26-35", "36-45", "46-55", "56-65", "66-75", "76-85", "86-95", "Not sure"]

    var body: some View {
        Form {
            // MARK: - Health Profile Section
            Section(header: Text("Health Profile")) {
                VStack(alignment: .leading) {
                    Text("Age: \(Int(age))")
                    Slider(value: $age, in: 0...100, step: 1)
                }
                Picker("Gender", selection: $gender) {
                    ForEach(genders, id: \.self) { Text($0) }
                }
                Picker("Ethnicity", selection: $ethnicity) {
                    ForEach(ethnicities, id: \.self) { Text($0) }
                }
                Picker("Biological Hair Color", selection: $hairColor) {
                    ForEach(hairColors, id: \.self) { Text($0) }
                }
                VStack(alignment: .leading) {
                    Text("Skin Color")
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(skinTones, id: \.0) { (label, color) in
                                Button(action: { skinColor = label }) {
                                    VStack {
                                        Rectangle()
                                            .fill(color)
                                            .frame(width: 40, height: 40)
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(skinColor == label ? Color.green : Color.clear, lineWidth: 2)
                                            )
                                        Text(label)
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                    }
                }
                Picker("UV Exposure", selection: $uvExposure) {
                    ForEach(uvOptions, id: \.self) { Text($0) }
                }
                Picker("Indoor Tanning Bed Usage", selection: $tanningFrequency) {
                    ForEach(frequencyOptions, id: \.self) { Text($0) }
                }
                Picker("Sunscreen Usage", selection: $sunscreenUsage) {
                    ForEach(frequencyOptions, id: \.self) { Text($0) }
                }
                Picker("Estimated Mole Count", selection: $moleCount) {
                    ForEach(moleOptions, id: \.self) { Text($0) }
                }
            }

            // MARK: - Family History Section
            Section(header: Text("Family History")) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Has anyone in your family had any form of cancer?")
                        .font(.headline)

                    Picker("Select", selection: $familyCancerHistory) {
                        Text("Select").tag("")
                        Text("Yes").tag("Yes")
                        Text("No").tag("No")
                    }
                    .pickerStyle(.segmented)
                }

                if familyCancerHistory == "Yes" {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Which family member(s) were diagnosed with skin cancer?")
                        ForEach(familyMembers, id: \.self) { member in
                            HStack {
                                Image(systemName: selectedFamilyMembers.contains(member) ? "checkmark.square.fill" : "square")
                                    .onTapGesture {
                                        if selectedFamilyMembers.contains(member) {
                                            selectedFamilyMembers.remove(member)
                                        } else {
                                            selectedFamilyMembers.insert(member)
                                        }
                                    }
                                Text(member)
                            }
                        }

                        Picker("Type of Skin Cancer", selection: $cancerType) {
                            ForEach(cancerTypes, id: \.self) { Text($0) }
                        }

                        Picker("Diagnosis Age", selection: $diagnosisAge) {
                            ForEach(diagnosisAges, id: \.self) { Text($0) }
                        }
                    }
                }
            }

            // MARK: - Save Button
            Section {
                Button("Save Changes") {
                    showConfirmation = true
                }
                .alert(isPresented: $showConfirmation) {
                    Alert(
                        title: Text("Profile Saved"),
                        message: Text("Your changes have been saved successfully."),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
    }
}


// MARK: - ProfilePage View
struct ProfilePage: View {
    var body: some View {
        ZStack {
            Color(red: 1.0, green: 0.86, blue: 0.86)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Your Profile")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                Text("This is where profile details would go.")
                    .font(.body)
            }
        }
    }
}
