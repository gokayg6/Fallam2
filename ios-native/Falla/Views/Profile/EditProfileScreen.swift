import SwiftUI

// MARK: - Edit Profile Screen
struct EditProfileScreen: View {
    let user: UserProfile?
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var birthDate = Date()
    @State private var selectedZodiac = ""
    @State private var bio: String = ""
    @State private var isSaving = false
    @State private var animateContent = false
    @State private var showZodiacPicker = false
    @State private var showSuccessToast = false
    
    private let zodiacSigns = [
        "Koç", "Boğa", "İkizler", "Yengeç", "Aslan", "Başak",
        "Terazi", "Akrep", "Yay", "Oğlak", "Kova", "Balık"
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
                        // Avatar Section
                        avatarSection
                        
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
            
            // Success Toast
            if showSuccessToast {
                VStack {
                    Spacer()
                    
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        
                        Text("Profil güncellendi")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(.bottom, 120)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            loadUserData()
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
            
            Text("Profili Düzenle")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // MARK: - Avatar Section
    private var avatarSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#C97CF6"), Color(hex: "#7B8CDE")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: Color(hex: "#C97CF6").opacity(0.5), radius: 20)
                
                if let firstLetter = name.first {
                    Text(String(firstLetter).uppercased())
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.white)
                }
                
                // Edit badge
                Circle()
                    .fill(Color(hex: "#C97CF6"))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "camera.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    )
                    .offset(x: 35, y: 35)
            }
            
            Text("Fotoğraf Değiştir")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "#C97CF6"))
        }
        .opacity(animateContent ? 1 : 0)
        .scaleEffect(animateContent ? 1 : 0.9)
    }
    
    // MARK: - Form Section
    private var formSection: some View {
        VStack(spacing: 16) {
            // Name Field
            formField(title: "Ad Soyad", icon: "person.fill") {
                TextField("Adınız", text: $name)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
            }
            
            // Email Field
            formField(title: "E-posta", icon: "envelope.fill") {
                TextField("E-posta adresiniz", text: $email)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
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
                        Text(selectedZodiac.isEmpty ? "Burç seçin" : selectedZodiac)
                            .foregroundColor(selectedZodiac.isEmpty ? .white.opacity(0.5) : .white)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .font(.system(size: 16))
                }
            }
            
            // Bio Field
            formField(title: "Biyografi", icon: "text.alignleft") {
                TextField("Kendinizi tanıtın", text: $bio)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
            }
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
    
    // MARK: - Save Button
    private var saveButton: some View {
        Button(action: saveProfile) {
            HStack(spacing: 10) {
                if isSaving {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                    Text("Değişiklikleri Kaydet")
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: [Color(hex: "#C97CF6"), Color(hex: "#7B8CDE")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: Color(hex: "#C97CF6").opacity(0.5), radius: 20, y: 10)
        }
        .disabled(isSaving)
        .opacity(animateContent ? 1 : 0)
    }
    
    // MARK: - Zodiac Picker Sheet
    private var zodiacPickerSheet: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(zodiacSigns, id: \.self) { zodiac in
                            Button(action: {
                                selectedZodiac = zodiac
                                showZodiacPicker = false
                            }) {
                                VStack(spacing: 8) {
                                    Text(zodiacSymbol(for: zodiac))
                                        .font(.system(size: 32))
                                    
                                    Text(zodiac)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 90)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(
                                            selectedZodiac == zodiac
                                                ? Color(hex: "#C97CF6").opacity(0.3)
                                                : Color.white.opacity(0.05)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(
                                                    selectedZodiac == zodiac
                                                        ? Color(hex: "#C97CF6")
                                                        : Color.white.opacity(0.1),
                                                    lineWidth: selectedZodiac == zodiac ? 2 : 1
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
    
    // MARK: - Helpers
    private func loadUserData() {
        name = user?.name ?? ""
        email = user?.email ?? ""
    }
    
    private func saveProfile() {
        isSaving = true
        
        // Simulate saving to Firebase/Backend
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isSaving = false
            
            withAnimation(.spring()) {
                showSuccessToast = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showSuccessToast = false
                }
                dismiss()
            }
        }
    }
    
    private func zodiacSymbol(for name: String) -> String {
        switch name {
        case "Koç": return "♈"
        case "Boğa": return "♉"
        case "İkizler": return "♊"
        case "Yengeç": return "♋"
        case "Aslan": return "♌"
        case "Başak": return "♍"
        case "Terazi": return "♎"
        case "Akrep": return "♏"
        case "Yay": return "♐"
        case "Oğlak": return "♑"
        case "Kova": return "♒"
        case "Balık": return "♓"
        default: return "⭐"
        }
    }
}

#Preview {
    EditProfileScreen(user: UserProfile(
        id: "1",
        name: "Test Kullanıcı",
        email: "test@email.com",
        karma: 100,
        createdAt: Date(),
        lastLoginAt: Date()
    ))
}
