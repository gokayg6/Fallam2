import SwiftUI

// MARK: - Ads Service (Singleton)
// GoogleMobileAds SDK olmadan simüle edilmiş reklam servisi
// Gerçek entegrasyon için Xcode'da: File > Add Package Dependencies > https://github.com/googleads/swift-package-manager-google-mobile-ads.git
final class AdsService: NSObject {
    static let shared = AdsService()
    
    // MARK: - Ad Unit IDs (Production - from Dart project)
    static let bannerAdUnitId = "ca-app-pub-5956124359067452/3098716914"
    static let interstitialAdUnitId = "ca-app-pub-5956124359067452/9225141569"
    static let rewardedAdUnitId = "ca-app-pub-5956124359067452/6477643001"
    
    // MARK: - Ad State
    private(set) var isInterstitialLoaded = false
    private(set) var isRewardedLoaded = false
    
    // MARK: - Analytics
    private(set) var adImpressions = 0
    private(set) var adClicks = 0
    
    private override init() {
        super.init()
    }
    
    // MARK: - Initialize SDK
    static func initialize() {
        print("🎯 AdMob SDK initialize called (simulated)")
        // Gerçek entegrasyon için:
        // GADMobileAds.sharedInstance().start { status in ... }
    }
    
    // MARK: - Load Interstitial Ad
    func loadInterstitialAd(completion: ((Bool) -> Void)? = nil) {
        // Simüle yükleme
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.isInterstitialLoaded = true
            self?.adImpressions += 1
            print("🎯 Interstitial ad loaded (simulated)")
            completion?(true)
        }
    }
    
    // MARK: - Show Interstitial Ad
    func showInterstitialAd(completion: (() -> Void)? = nil) {
        guard isInterstitialLoaded else {
            print("❌ Interstitial ad not loaded")
            completion?()
            return
        }
        
        print("🎯 Showing interstitial ad (simulated)")
        isInterstitialLoaded = false
        adClicks += 1
        
        // Simüle gösterim süresi
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion?()
            // Auto-reload
            self.loadInterstitialAd()
        }
    }
    
    // MARK: - Load Rewarded Ad
    func loadRewardedAd(completion: ((Bool) -> Void)? = nil) {
        // Simüle yükleme
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.isRewardedLoaded = true
            self?.adImpressions += 1
            print("🎯 Rewarded ad loaded (simulated)")
            completion?(true)
        }
    }
    
    // MARK: - Show Rewarded Ad
    func showRewardedAd(completion: @escaping (Bool) -> Void) {
        guard isRewardedLoaded else {
            print("❌ Rewarded ad not loaded")
            completion(false)
            return
        }
        
        print("🎯 Showing rewarded ad (simulated)")
        isRewardedLoaded = false
        adClicks += 1
        
        // Simüle reklam izleme süresi
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            print("🎯 User earned reward (simulated)")
            completion(true)
            // Auto-reload
            self.loadRewardedAd()
        }
    }
    
    // MARK: - Dispose Ads
    func disposeInterstitialAd() {
        isInterstitialLoaded = false
    }
    
    func disposeRewardedAd() {
        isRewardedLoaded = false
    }
    
    func disposeAllAds() {
        disposeInterstitialAd()
        disposeRewardedAd()
    }
}

// MARK: - Banner Ad View (SwiftUI) - Placeholder
struct BannerAdView: View {
    let adUnitID: String
    
    init(adUnitID: String = AdsService.bannerAdUnitId) {
        self.adUnitID = adUnitID
    }
    
    var body: some View {
        // Placeholder banner - gerçek entegrasyon için GoogleMobileAds SDK gerekli
        HStack(spacing: 8) {
            Image(systemName: "megaphone.fill")
                .foregroundColor(.white.opacity(0.5))
            Text("Reklam Alanı")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(Color.black.opacity(0.3))
        .cornerRadius(8)
    }
}

#Preview {
    BannerAdView()
        .padding()
        .background(Color.black)
}
