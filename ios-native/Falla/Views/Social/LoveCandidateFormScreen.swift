import SwiftUI

// MARK: - Love Candidate Form Screen
struct LoveCandidateFormScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var birthDate = Date()
    @State private var selectedZodiac = ""
    @State private var bio = ""
    @State private var showZodiacPicker = false
    @State private var animateContent = false
    @State private var isSaving = false
    
    private let zodiacSigns = [
        ("Koç", "♈"), ("Boğa", "♉"), ("İkizler", "♊"), ("Yengeç", "♋"),
        ("Aslan", "♌"), ("Başak", "♍"), ("Terazi", "♎"), ("Akrep", "♏"),
        ("Yay", "♐"), ("Oğlak", "♑"), ("Kova", "♒"), ("Balık", "♓")
    ]
    
    var body: some View {
        ZStack {
            // Background
            Image("theme_purple")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Form Fields
                        formSection
                        
                        // Save Button
                        saveButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.spring(response: 0.6).delay(0.1)) {
                animateContent = true
            }
        }
        .sheet(isPresented: $showZodiacPicker) {
            zodiacPickerSheet
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack(spacing: 12) {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Text("Yeni Aday Ekle")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // MARK: - Form Section
    private var formSection: some View {
        VStack(spacing: 20) {
            // Avatar placeholder
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#C97CF6").opacity(0.3), Color(hex: "#7B8CDE").opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                if name.isEmpty {
                    Image(systemName: "person.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color(hex: "#C97CF6"))
                } else {
                    Text(name.prefix(1).uppercased())
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(Color(hex: "#C97CF6"))
                }
            }
            .opacity(animateContent ? 1 : 0)
            .scaleEffect(animateContent ? 1 : 0.8)
            
            // Name Field
            formField(title: "İsim", icon: "person.fill") {
                TextField("Adayın ismi", text: $name)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
            }
            
            // Birth Date Field
            formField(title: "Doğum Tarihi", icon: "calendar") {
                DatePicker("", selection: $birthDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .colorScheme(.dark)
            }
            
            // Zodiac Field
            formField(title: "Burç", icon: "sparkles") {
                Button(action: { showZodiacPicker = true }) {
                    HStack {
                        if selectedZodiac.isEmpty {
                            Text("Burç seç")
                                .foregroundColor(.white.opacity(0.5))
                        } else {
                            Text(selectedZodiac)
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .font(.system(size: 16))
                }
            }
            
            // Bio Field
            formField(title: "Biyografi", icon: "text.alignleft") {
                TextField("Kısa bir açıklama", text: $bio)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
            }
            
            // Tips
            tipsSection
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
    }
    
    private func formField<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#C97CF6"))
                
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            content()
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
        }
    }
    
    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(Color(hex: "#F59E0B"))
                
                Text("İpuçları")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                tipRow("Doğru burç bilgisi daha iyi uyum analizi sağlar")
                tipRow("Biyografi diğer kullanıcıların seni tanımasına yardımcı olur")
                tipRow("Tüm bilgiler gizli tutulur")
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "#F59E0B").opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: "#F59E0B").opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private func tipRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Color(hex: "#F59E0B"))
                .frame(width: 4, height: 4)
                .padding(.top, 6)
            
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))
        }
    }
    
    // MARK: - Save Button
    private var saveButton: some View {
        Button(action: save) {
            HStack(spacing: 10) {
                if isSaving {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                    Text("Kaydet")
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                isFormValid
                    ? LinearGradient(
                        colors: [Color(hex: "#C97CF6"), Color(hex: "#7B8CDE")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    : LinearGradient(
                        colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.3)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: Color(hex: "#C97CF6").opacity(0.4), radius: 15, y: 5)
        }
        .disabled(!isFormValid || isSaving)
        .opacity(animateContent ? 1 : 0)
    }
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && !selectedZodiac.isEmpty
    }
    
    // MARK: - Zodiac Picker Sheet
    private var zodiacPickerSheet: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(zodiacSigns, id: \.0) { zodiac in
                            Button(action: {
                                selectedZodiac = zodiac.0
                                showZodiacPicker = false
                            }) {
                                VStack(spacing: 8) {
                                    Text(zodiac.1)
                                        .font(.system(size: 32))
                                    
                                    Text(zodiac.0)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 90)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(
                                            selectedZodiac == zodiac.0
                                                ? Color(hex: "#C97CF6").opacity(0.3)
                                                : Color.white.opacity(0.05)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(
                                                    selectedZodiac == zodiac.0
                                                        ? Color(hex: "#C97CF6")
                                                        : Color.white.opacity(0.1),
                                                    lineWidth: selectedZodiac == zodiac.0 ? 2 : 1
                                                )
                                        )
                                )
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Burç Seç")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        showZodiacPicker = false
                    }
                    .foregroundColor(Color(hex: "#C97CF6"))
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    // MARK: - Actions
    private func save() {
        isSaving = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isSaving = false
            dismiss()
        }
    }
}

#Preview {
    LoveCandidateFormScreen()
}
