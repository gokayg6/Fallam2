import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// MARK: - Auth Provider
@MainActor
class AuthProvider: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: String?
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    init() {
        // Listen to auth state changes
        auth.addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.user = user
                self?.isAuthenticated = user != nil
            }
        }
    }
    
    // MARK: - Sign In with Email
    func signIn(email: String, password: String) async throws {
        isLoading = true
        error = nil
        
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            user = result.user
            isAuthenticated = true
            try await updateLastLogin()
            print("✅ User signed in: \(result.user.uid)")
        } catch {
            self.error = error.localizedDescription
            throw error
        }
        
        isLoading = false
    }
    
    // MARK: - Sign Up with Email
    func signUp(email: String, password: String, name: String) async throws {
        isLoading = true
        error = nil
        
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            user = result.user
            isAuthenticated = true
            
            // Create user document in Firestore
            try await createUserDocument(userId: result.user.uid, name: name, email: email)
            
            print("✅ User created: \(result.user.uid)")
        } catch {
            self.error = error.localizedDescription
            throw error
        }
        
        isLoading = false
    }
    
    // MARK: - Sign Out
    func signOut() throws {
        do {
            try auth.signOut()
            user = nil
            isAuthenticated = false
            print("✅ User signed out")
        } catch {
            self.error = error.localizedDescription
            throw error
        }
    }
    
    // MARK: - Delete Account
    func deleteAccount() async throws {
        guard let currentUser = auth.currentUser else { return }
        
        isLoading = true
        
        do {
            // Delete user document
            try await db.collection("users").document(currentUser.uid).delete()
            
            // Delete user auth
            try await currentUser.delete()
            
            user = nil
            isAuthenticated = false
            print("✅ User account deleted")
        } catch {
            self.error = error.localizedDescription
            throw error
        }
        
        isLoading = false
    }
    
    // MARK: - Guest Sign In
    func signInAsGuest() async throws {
        isLoading = true
        error = nil
        
        do {
            let result = try await auth.signInAnonymously()
            user = result.user
            isAuthenticated = true
            
            // Create guest user document
            try await createUserDocument(userId: result.user.uid, name: "Misafir", email: nil, isGuest: true)
            
            print("✅ Guest signed in: \(result.user.uid)")
        } catch {
            self.error = error.localizedDescription
            throw error
        }
        
        isLoading = false
    }
    
    // MARK: - Private Helpers
    private func createUserDocument(userId: String, name: String, email: String?, isGuest: Bool = false) async throws {
        let userData: [String: Any] = [
            "id": userId,
            "name": name,
            "email": email ?? "",
            "isGuest": isGuest,
            "karma": 100,
            "createdAt": Timestamp(date: Date()),
            "lastLoginAt": Timestamp(date: Date())
        ]
        
        try await db.collection("users").document(userId).setData(userData)
    }
    
    private func updateLastLogin() async throws {
        guard let userId = user?.uid else { return }
        
        try await db.collection("users").document(userId).updateData([
            "lastLoginAt": Timestamp(date: Date())
        ])
    }
}
