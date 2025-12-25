import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authProvider: AuthProvider
    @State private var showGetStarted = true
    
    var body: some View {
        Group {
            if showGetStarted && !authProvider.isAuthenticated {
                GetStartedScreen(onContinue: {
                    showGetStarted = false
                })
                .transition(.opacity)
            } else if authProvider.isAuthenticated {
                MainScreen()
                    .transition(.opacity)
            } else {
                LoginScreen()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authProvider.isAuthenticated)
        .animation(.easeInOut(duration: 0.3), value: showGetStarted)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthProvider())
        .environmentObject(ThemeProvider())
}
