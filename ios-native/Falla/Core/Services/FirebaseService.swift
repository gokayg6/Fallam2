import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

// MARK: - Firebase Service
class FirebaseService {
    static let shared = FirebaseService()
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private let auth = Auth.auth()
    
    private init() {}
    
    // MARK: - Current User ID
    var currentUserId: String? {
        auth.currentUser?.uid
    }
    
    // MARK: - User Operations
    
    func getUser(userId: String) async throws -> [String: Any]? {
        let document = try await db.collection("users").document(userId).getDocument()
        return document.data()
    }
    
    func updateUser(userId: String, data: [String: Any]) async throws {
        try await db.collection("users").document(userId).updateData(data)
    }
    
    func updateKarma(userId: String, amount: Int) async throws {
        try await db.collection("users").document(userId).updateData([
            "karma": FieldValue.increment(Int64(amount))
        ])
    }
    
    // MARK: - Fortune Operations
    
    func saveFortune(fortune: [String: Any]) async throws -> String {
        let docRef = try await db.collection("fortunes").addDocument(data: fortune)
        return docRef.documentID
    }
    
    func getUserFortunes(userId: String) async throws -> [[String: Any]] {
        let snapshot = try await db.collection("fortunes")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.map { doc in
            var data = doc.data()
            data["id"] = doc.documentID
            return data
        }
    }
    
    func getFortune(fortuneId: String) async throws -> [String: Any]? {
        let document = try await db.collection("fortunes").document(fortuneId).getDocument()
        guard var data = document.data() else { return nil }
        data["id"] = document.documentID
        return data
    }
    
    func toggleFavorite(fortuneId: String, isFavorite: Bool) async throws {
        try await db.collection("fortunes").document(fortuneId).updateData([
            "isFavorite": isFavorite
        ])
    }
    
    func deleteFortune(fortuneId: String) async throws {
        try await db.collection("fortunes").document(fortuneId).delete()
    }
    
    // MARK: - Test Results Operations
    
    func saveTestResult(result: [String: Any]) async throws -> String {
        let docRef = try await db.collection("test_results").addDocument(data: result)
        return docRef.documentID
    }
    
    func getUserTestResults(userId: String) async throws -> [[String: Any]] {
        let snapshot = try await db.collection("test_results")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.map { doc in
            var data = doc.data()
            data["id"] = doc.documentID
            return data
        }
    }
    
    // MARK: - Social Operations
    
    func getMatches(userId: String) async throws -> [[String: Any]] {
        let snapshot = try await db.collection("matches")
            .whereField("userIds", arrayContains: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.map { doc in
            var data = doc.data()
            data["id"] = doc.documentID
            return data
        }
    }
    
    func sendRequest(fromUserId: String, toUserId: String) async throws {
        let request: [String: Any] = [
            "fromUserId": fromUserId,
            "toUserId": toUserId,
            "status": "pending",
            "createdAt": Timestamp(date: Date())
        ]
        
        try await db.collection("social_requests").addDocument(data: request)
    }
    
    func getPendingRequests(userId: String) async throws -> [[String: Any]] {
        let snapshot = try await db.collection("social_requests")
            .whereField("toUserId", isEqualTo: userId)
            .whereField("status", isEqualTo: "pending")
            .getDocuments()
        
        return snapshot.documents.map { doc in
            var data = doc.data()
            data["id"] = doc.documentID
            return data
        }
    }
    
    func respondToRequest(requestId: String, accept: Bool) async throws {
        try await db.collection("social_requests").document(requestId).updateData([
            "status": accept ? "accepted" : "rejected"
        ])
    }
    
    // MARK: - Chat Operations
    
    func sendMessage(matchId: String, message: [String: Any]) async throws {
        try await db.collection("matches").document(matchId)
            .collection("messages").addDocument(data: message)
        
        // Update last message
        try await db.collection("matches").document(matchId).updateData([
            "lastMessage": message["text"] ?? "",
            "lastMessageAt": Timestamp(date: Date())
        ])
    }
    
    func getMessages(matchId: String) async throws -> [[String: Any]] {
        let snapshot = try await db.collection("matches").document(matchId)
            .collection("messages")
            .order(by: "createdAt", descending: false)
            .getDocuments()
        
        return snapshot.documents.map { doc in
            var data = doc.data()
            data["id"] = doc.documentID
            return data
        }
    }
    
    // MARK: - Storage Operations
    
    func uploadImage(data: Data, path: String) async throws -> String {
        let ref = storage.reference().child(path)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        _ = try await ref.putDataAsync(data, metadata: metadata)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }
    
    func deleteImage(path: String) async throws {
        let ref = storage.reference().child(path)
        try await ref.delete()
    }
}
