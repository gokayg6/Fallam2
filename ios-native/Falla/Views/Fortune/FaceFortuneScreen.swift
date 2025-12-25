import SwiftUI
import PhotosUI

// MARK: - Face Fortune Screen
struct FaceFortuneScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var faceImage: UIImage?
    @State private var showImagePicker = false
    @State private var isAnalyzing = false
    @State private var analysisResult: FaceAnalysisResult?
    @State private var showCamera = false
    
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
                        infoCard
                        
                        // Image Upload
                        imageUploadSection
                        
                        // Guidelines
                        if faceImage == nil {
                            guidelinesSection
                        }
                        
                        // Analyze Button
                        if faceImage != nil && analysisResult == nil {
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
            SingleImagePicker(image: $faceImage)
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
            
            Text("Yüz Analizi")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            // Karma cost
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.orange)
                Text("12")
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
    
    // MARK: - Info Card
    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#98D98E"), Color(hex: "#7CB342")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "face.smiling")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Yüz Analizi")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Yüz hatlarınız kişiliğinizi yansıtır")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            Text("Fizyognomi, yüz hatlarından kişilik analizi yapma sanatıdır. Yapay zeka teknolojimiz yüz özelliklerinizi analiz ederek kişiliğiniz, güçlü yönleriniz ve potansiyeliniz hakkında bilgi verir.")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(4)
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Image Upload Section
    private var imageUploadSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Yüz Fotoğrafı")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            if let image = faceImage {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    Button(action: { 
                        faceImage = nil 
                        analysisResult = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding(12)
                }
            } else {
                VStack(spacing: 20) {
                    // Camera Button
                    Button(action: { showCamera = true }) {
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "#7CB342").opacity(0.2))
                                    .frame(width: 70, height: 70)
                                
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(Color(hex: "#7CB342"))
                            }
                            
                            Text("Fotoğraf Çek")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    Text("veya")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                    
                    // Gallery Button
                    Button(action: { showImagePicker = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 16))
                            Text("Galeriden Seç")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Capsule())
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 220)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            style: StrokeStyle(lineWidth: 2, dash: [8])
                        )
                        .foregroundColor(.white.opacity(0.2))
                )
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
                FaceGuidelineRow(icon: "face.smiling", text: "Yüzünüz net ve tam görünmeli")
                FaceGuidelineRow(icon: "sun.max", text: "İyi aydınlatılmış ortam")
                FaceGuidelineRow(icon: "eye", text: "Düz bakış açısı, kameraya bakın")
                FaceGuidelineRow(icon: "rectangle.portrait", text: "Sadece yüzünüzü çerçeveleyin")
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    struct FaceGuidelineRow: View {
        let icon: String
        let text: String
        
        var body: some View {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "#7CB342"))
                    .frame(width: 24)
                
                Text(text)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
    
    // MARK: - Analyze Button
    private var analyzeButton: some View {
        Button(action: analyzeFace) {
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
                    colors: [Color(hex: "#98D98E"), Color(hex: "#7CB342")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color(hex: "#7CB342").opacity(0.4), radius: 20, x: 0, y: 8)
        }
    }
    
    // MARK: - Results Section
    private func resultsSection(_ result: FaceAnalysisResult) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Analiz Sonuçları")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            // Personality Traits
            VStack(alignment: .leading, spacing: 12) {
                Text("Kişilik Özellikleri")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                ForEach(result.traits, id: \.self) { trait in
                    HStack(spacing: 10) {
                        Circle()
                            .fill(Color(hex: "#7CB342"))
                            .frame(width: 8, height: 8)
                        
                        Text(trait)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Face Features
            VStack(alignment: .leading, spacing: 12) {
                Text("Yüz Özellikleri")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                FaceFeatureRow(feature: "Göz Yapısı", analysis: result.eyeAnalysis)
                FaceFeatureRow(feature: "Alın Yapısı", analysis: result.foreheadAnalysis)
                FaceFeatureRow(feature: "Çene Yapısı", analysis: result.chinAnalysis)
                FaceFeatureRow(feature: "Burun Yapısı", analysis: result.noseAnalysis)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // General Reading
            VStack(alignment: .leading, spacing: 12) {
                Text("Genel Yorum")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(result.generalReading)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(4)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    struct FaceFeatureRow: View {
        let feature: String
        let analysis: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(feature)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: "#98D98E"))
                
                Text(analysis)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
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
                                colors: [Color(hex: "#98D98E"), Color(hex: "#7CB342")],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                    
                    Image(systemName: "face.smiling")
                        .font(.system(size: 32))
                        .foregroundColor(Color(hex: "#7CB342"))
                }
                
                Text("Yüzünüz analiz ediliyor...")
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
    
    // MARK: - Analyze Face
    private func analyzeFace() {
        isAnalyzing = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            isAnalyzing = false
            analysisResult = FaceAnalysisResult(
                traits: [
                    "Kararlı ve güçlü iradeli",
                    "Duygusal zeka yüksek",
                    "Sosyal ve iletişime açık",
                    "Analitik düşünce yapısı",
                    "Yaratıcı ve sanatsal yönler"
                ],
                eyeAnalysis: "Gözleriniz derin ve anlamlı. İyi bir gözlemci olduğunuzu gösterir.",
                foreheadAnalysis: "Geniş alın yapısı, entelektüel kapasiteyi ve stratejik düşünmeyi işaret eder.",
                chinAnalysis: "Çene yapınız kararlılık ve dayanıklılık gösterir.",
                noseAnalysis: "Burnunuzun şekli liderlik özelliklerini yansıtır.",
                generalReading: "Yüz hatlarınız güçlü bir kişiliğe sahip olduğunuzu gösteriyor. Dengeli ve uyumlu yüz oranlarınız, hem mantıksal hem de duygusal zekânızın yüksek olduğuna işaret ediyor. Liderlik potansiyeliniz var ve çevrenizdekiler sizin fikirlerinize değer veriyor."
            )
        }
    }
}

// MARK: - Face Analysis Result
struct FaceAnalysisResult {
    let traits: [String]
    let eyeAnalysis: String
    let foreheadAnalysis: String
    let chinAnalysis: String
    let noseAnalysis: String
    let generalReading: String
}

#Preview {
    FaceFortuneScreen()
}
