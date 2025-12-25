import SwiftUI
import PhotosUI

// MARK: - Coffee Fortune Screen
struct CoffeeFortuneScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedImages: [UIImage] = []
    @State private var showImagePicker = false
    @State private var isAnalyzing = false
    @State private var showResult = false
    @State private var fortuneResult: String = ""
    
    var body: some View {
        ZStack {
            // Background
            Image("app_background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                    .padding(.top, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Instructions Card
                        instructionsCard
                        
                        // Image Upload Section
                        imageUploadSection
                        
                        // Additional Info Form
                        additionalInfoForm
                        
                        // Submit Button
                        submitButton
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                }
            }
            
            // Loading Overlay
            if isAnalyzing {
                analyzingOverlay
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(images: $selectedImages, maxSelection: 3)
        }
        .sheet(isPresented: $showResult) {
            FortuneResultView(result: fortuneResult, type: .coffee)
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .glassCircleButton(size: 40)
            }
            
            Spacer()
            
            Text("Kahve Falı")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            // Karma cost badge
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.orange)
                Text("5")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Instructions Card
    private var instructionsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#E8A87C"), Color(hex: "#C38D6A")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Kahve Falınızı Yükleyin")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Fincan fotoğraflarınızı ekleyin")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            VStack(alignment: .leading, spacing: 12) {
                InstructionRow(number: "1", text: "Kahvenizi için bitirdikten sonra fincanı ters çevirin")
                InstructionRow(number: "2", text: "5 dakika bekleyin ve fincanı çevirin")
                InstructionRow(number: "3", text: "Fincanın içini 3 farklı açıdan fotoğraflayın")
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
        )
    }
    
    // MARK: - Instruction Row
    struct InstructionRow: View {
        let number: String
        let text: String
        
        var body: some View {
            HStack(alignment: .top, spacing: 12) {
                Text(number)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .background(Color(hex: "#E8A87C"))
                    .clipShape(Circle())
                
                Text(text)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
    
    // MARK: - Image Upload Section
    private var imageUploadSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Fotoğraflar")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            if selectedImages.isEmpty {
                // Empty state
                Button(action: { showImagePicker = true }) {
                    VStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text("Fotoğraf Ekle")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("En az 1, en fazla 3 fotoğraf")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 160)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                style: StrokeStyle(lineWidth: 2, dash: [8])
                            )
                            .foregroundColor(.white.opacity(0.2))
                    )
                }
            } else {
                // Selected images grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            Button(action: {
                                selectedImages.remove(at: index)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .background(Color.black.opacity(0.5))
                                    .clipShape(Circle())
                            }
                            .offset(x: 6, y: -6)
                        }
                    }
                    
                    if selectedImages.count < 3 {
                        Button(action: { showImagePicker = true }) {
                            VStack {
                                Image(systemName: "plus")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .frame(width: 100, height: 100)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Additional Info Form
    @State private var question: String = ""
    @State private var relationshipStatus: String = "Belirtmek istemiyorum"
    
    private var additionalInfoForm: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ek Bilgiler (Opsiyonel)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            // Question field
            VStack(alignment: .leading, spacing: 8) {
                Text("Sormak istediğiniz bir soru var mı?")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                
                TextField("", text: $question, prompt: Text("Örn: İş hayatım nasıl olacak?").foregroundColor(.white.opacity(0.4)))
                    .foregroundColor(.white)
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // Relationship status
            VStack(alignment: .leading, spacing: 8) {
                Text("İlişki Durumu")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                
                Menu {
                    Button("Belirtmek istemiyorum") { relationshipStatus = "Belirtmek istemiyorum" }
                    Button("Bekar") { relationshipStatus = "Bekar" }
                    Button("İlişkide") { relationshipStatus = "İlişkide" }
                    Button("Evli") { relationshipStatus = "Evli" }
                    Button("Nişanlı") { relationshipStatus = "Nişanlı" }
                } label: {
                    HStack {
                        Text(relationshipStatus)
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Submit Button
    private var submitButton: some View {
        Button(action: submitFortune) {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 18))
                Text("Falımı Yorumla")
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: selectedImages.isEmpty 
                        ? [Color.gray.opacity(0.5), Color.gray.opacity(0.3)]
                        : [Color(hex: "#E8A87C"), Color(hex: "#C38D6A")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: selectedImages.isEmpty ? .clear : Color(hex: "#E8A87C").opacity(0.4), radius: 20, x: 0, y: 8)
        }
        .disabled(selectedImages.isEmpty)
    }
    
    // MARK: - Analyzing Overlay
    private var analyzingOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Animated coffee cup
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 4)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "#E8A87C"), Color(hex: "#C38D6A")],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                    
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 32))
                        .foregroundColor(Color(hex: "#E8A87C"))
                }
                
                Text("Falınız yorumlanıyor...")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("Bu işlem 30 saniye kadar sürebilir")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(40)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
    }
    
    // MARK: - Submit Fortune
    private func submitFortune() {
        isAnalyzing = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            isAnalyzing = false
            fortuneResult = "Fincanınızda görülen şekiller size güzel haberler müjdeliyor. Yakın zamanda hayatınıza yeni ve olumlu değişiklikler girecek gibi görünüyor..."
            showResult = true
        }
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    let maxSelection: Int
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = maxSelection - images.count
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()
            
            for result in results {
                result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                    if let image = object as? UIImage {
                        DispatchQueue.main.async {
                            self.parent.images.append(image)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Fortune Result View
struct FortuneResultView: View {
    let result: String
    let type: FortuneType
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Image("app_background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Fal Sonucu")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Type Icon
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: type.gradientColors,
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: type.iconName)
                                .font(.system(size: 36))
                                .foregroundColor(.white)
                        }
                        
                        Text(type.displayName)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        // Result Card
                        VStack(alignment: .leading, spacing: 16) {
                            Text(result)
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(6)
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                        )
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
            }
            .padding(.top, 20)
        }
    }
}

// MARK: - Fortune Type Extension
extension FortuneType {
    var gradientColors: [Color] {
        switch self {
        case .coffee: return [Color(hex: "#E8A87C"), Color(hex: "#C38D6A")]
        case .tarot: return [Color(hex: "#C97CF6"), Color(hex: "#9B59B6")]
        case .palm: return [Color(hex: "#F5A9B8"), Color(hex: "#E87E95")]
        case .face: return [Color(hex: "#98D98E"), Color(hex: "#7CB342")]
        case .dream: return [Color(hex: "#7986CB"), Color(hex: "#5C6BC0")]
        default: return [Color(hex: "#7B8CDE"), Color(hex: "#A78BDA")]
        }
    }
}

#Preview {
    CoffeeFortuneScreen()
}
