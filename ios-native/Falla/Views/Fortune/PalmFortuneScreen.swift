import SwiftUI
import PhotosUI

// MARK: - Palm Fortune Screen
struct PalmFortuneScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedHand: HandType = .right
    @State private var palmImage: UIImage?
    @State private var showImagePicker = false
    @State private var isAnalyzing = false
    @State private var analysisResult: PalmAnalysisResult?
    
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
                        // Info Card
                        palmInfoCard
                        
                        // Hand Selection
                        handSelectionSection
                        
                        // Palm Image Upload
                        palmImageSection
                        
                        // Guidelines
                        guidelinesSection
                        
                        // Analyze Button
                        if palmImage != nil {
                            analyzeButton
                        }
                        
                        // Results
                        if let result = analysisResult {
                            resultsSection(result)
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                }
            }
            
            // Analyzing Overlay
            if isAnalyzing {
                analyzingOverlay
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showImagePicker) {
            SingleImagePicker(image: $palmImage)
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .glassCircleButton(size: 40)
            }
            
            Spacer()
            
            Text("El Falı")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            // Karma cost
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.orange)
                Text("10")
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
    
    // MARK: - Palm Info Card
    private var palmInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#F5A9B8"), Color(hex: "#E87E95")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("El Falı Analizi")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Avuç içinizdeki çizgiler geleceğinizi anlatır")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            Text("El falı, avuç içinizdeki çizgileri analiz ederek kişiliğiniz, geleceğiniz ve kaderiniz hakkında bilgi verir. Yapay zeka teknolojimiz el çizgilerinizi detaylı şekilde analiz eder.")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(4)
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Hand Selection
    private var handSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Hangi Elinizi Kullanacaksınız?")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                HandSelectionButton(
                    type: .left,
                    isSelected: selectedHand == .left
                ) {
                    selectedHand = .left
                }
                
                HandSelectionButton(
                    type: .right,
                    isSelected: selectedHand == .right
                ) {
                    selectedHand = .right
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Palm Image Section
    private var palmImageSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("El Fotoğrafı")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            if let image = palmImage {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    Button(action: { palmImage = nil }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding(12)
                }
            } else {
                Button(action: { showImagePicker = true }) {
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "hand.raised")
                                .font(.system(size: 36))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        Text("Fotoğraf Çek veya Seç")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                style: StrokeStyle(lineWidth: 2, dash: [8])
                            )
                            .foregroundColor(.white.opacity(0.2))
                    )
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Guidelines Section
    private var guidelinesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Fotoğraf İpuçları")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 10) {
                GuidelineRow(icon: "sun.max", text: "İyi aydınlatılmış ortamda çekin")
                GuidelineRow(icon: "hand.raised", text: "Avuç içinizi düz tutun")
                GuidelineRow(icon: "camera", text: "Tüm çizgiler görünür olsun")
                GuidelineRow(icon: "checkmark.circle", text: "Net ve bulanık olmayan fotoğraf")
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Guideline Row
    struct GuidelineRow: View {
        let icon: String
        let text: String
        
        var body: some View {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "#F5A9B8"))
                    .frame(width: 24)
                
                Text(text)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
    
    // MARK: - Analyze Button
    private var analyzeButton: some View {
        Button(action: analyzePalm) {
            HStack(spacing: 12) {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 18))
                Text("Analiz Et")
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: [Color(hex: "#F5A9B8"), Color(hex: "#E87E95")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color(hex: "#E87E95").opacity(0.4), radius: 20, x: 0, y: 8)
        }
    }
    
    // MARK: - Results Section
    private func resultsSection(_ result: PalmAnalysisResult) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Analiz Sonuçları")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            // Life Line
            PalmLineResult(
                title: "Yaşam Çizgisi",
                description: result.lifeLine,
                icon: "heart.fill",
                color: Color(hex: "#FF6B6B")
            )
            
            // Heart Line
            PalmLineResult(
                title: "Kalp Çizgisi",
                description: result.heartLine,
                icon: "suit.heart.fill",
                color: Color(hex: "#FF8ED2")
            )
            
            // Head Line
            PalmLineResult(
                title: "Akıl Çizgisi",
                description: result.headLine,
                icon: "brain",
                color: Color(hex: "#6C5CE7")
            )
            
            // Fate Line
            PalmLineResult(
                title: "Kader Çizgisi",
                description: result.fateLine,
                icon: "star.fill",
                color: Color(hex: "#FDCB6E")
            )
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Analyzing Overlay
    private var analyzingOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 4)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "#F5A9B8"), Color(hex: "#E87E95")],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                    
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 32))
                        .foregroundColor(Color(hex: "#F5A9B8"))
                }
                
                Text("El çizgileriniz analiz ediliyor...")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("Bu işlem birkaç saniye sürebilir")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(40)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
    }
    
    // MARK: - Analyze Palm
    private func analyzePalm() {
        isAnalyzing = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            isAnalyzing = false
            analysisResult = PalmAnalysisResult(
                lifeLine: "Yaşam çizginiz uzun ve belirgin. Güçlü bir sağlık yapısına ve uzun ömre işaret ediyor.",
                heartLine: "Kalp çizginiz derin ve net. Duygusal olarak tutarlı ve sadık bir kişiliğe sahipsiniz.",
                headLine: "Akıl çizginiz düz ve uzun. Mantıksal düşünce yapısına sahip, analitik bir zekayı gösteriyor.",
                fateLine: "Kader çizginiz belirgin. Kariyerinizde başarılı olacağınıza ve hedeflerinize ulaşacağınıza işaret ediyor."
            )
        }
    }
}

// MARK: - Hand Type
enum HandType {
    case left, right
    
    var title: String {
        switch self {
        case .left: return "Sol El"
        case .right: return "Sağ El"
        }
    }
    
    var description: String {
        switch self {
        case .left: return "Potansiyel"
        case .right: return "Gerçekleşen"
        }
    }
}

// MARK: - Hand Selection Button
struct HandSelectionButton: View {
    let type: HandType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: type == .left ? "hand.point.left.fill" : "hand.point.right.fill")
                    .font(.system(size: 28))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.5))
                
                Text(type.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                
                Text(type.description)
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .white.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color(hex: "#E87E95") : Color.white.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(isSelected ? 0 : 0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Palm Analysis Result
struct PalmAnalysisResult {
    let lifeLine: String
    let heartLine: String
    let headLine: String
    let fateLine: String
}

// MARK: - Palm Line Result
struct PalmLineResult: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text(description)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Single Image Picker
struct SingleImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
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
        let parent: SingleImagePicker
        
        init(_ parent: SingleImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()
            
            guard let result = results.first else { return }
            
            result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self.parent.image = image
                    }
                }
            }
        }
    }
}

#Preview {
    PalmFortuneScreen()
}
