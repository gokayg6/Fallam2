import SwiftUI

// MARK: - Chat Detail Screen
struct ChatDetailScreen: View {
    let match: ChatMatch
    @Environment(\.dismiss) private var dismiss
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = []
    @State private var animateContent = false
    @State private var showOptions = false
    @FocusState private var isInputFocused: Bool
    
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
                chatHeader
                
                // Messages
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 12) {
                            // Date Header
                            Text("Bugün")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.vertical, 8)
                            
                            ForEach(messages) { message in
                                MessageBubble(message: message, auraColor: match.auraColor)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 100)
                    }
                    .onChange(of: messages.count) { _ in
                        if let lastMessage = messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Input
                messageInput
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            loadMessages()
            withAnimation(.spring(response: 0.5).delay(0.1)) {
                animateContent = true
            }
        }
        .confirmationDialog("Seçenekler", isPresented: $showOptions) {
            Button("Kullanıcıyı Engelle", role: .destructive) {
                // Block user
            }
            Button("Sohbeti Sil", role: .destructive) {
                // Delete chat
            }
            Button("İptal", role: .cancel) {}
        }
    }
    
    // MARK: - Header
    private var chatHeader: some View {
        HStack(spacing: 12) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            
            // User Info
            HStack(spacing: 12) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color(hex: match.auraColor).opacity(0.3))
                        .frame(width: 44, height: 44)
                    
                    Text(match.userName.prefix(1))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: match.auraColor))
                    
                    // Online indicator
                    Circle()
                        .fill(Color(hex: "#10B981"))
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(Color.black, lineWidth: 2)
                        )
                        .offset(x: 15, y: 15)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(match.userName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("Çevrimiçi")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#10B981"))
                }
            }
            
            Spacer()
            
            Button(action: { showOptions = true }) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - Message Input
    private var messageInput: some View {
        HStack(spacing: 12) {
            // Text Field
            HStack(spacing: 8) {
                TextField("Mesaj yaz...", text: $messageText)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .focused($isInputFocused)
                
                if !messageText.isEmpty {
                    Button(action: { messageText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            
            // Send Button
            Button(action: sendMessage) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(
                                messageText.isEmpty
                                    ? Color.gray.opacity(0.5)
                                    : LinearGradient(
                                        colors: [Color(hex: "#C97CF6"), Color(hex: "#7B8CDE")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                            )
                    )
            }
            .disabled(messageText.isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - Functions
    private func loadMessages() {
        // Demo messages
        messages = [
            ChatMessage(id: "1", text: "Merhaba! Profiliğini çok beğendim 😊", isFromCurrentUser: false, timestamp: Date().addingTimeInterval(-3600)),
            ChatMessage(id: "2", text: "Teşekkür ederim! Aura'mız çok uyumlu görünüyor ✨", isFromCurrentUser: true, timestamp: Date().addingTimeInterval(-3500)),
            ChatMessage(id: "3", text: "Evet, bence de! Hangi burçsun?", isFromCurrentUser: false, timestamp: Date().addingTimeInterval(-3400)),
            ChatMessage(id: "4", text: "Ben Kova burcuyum, sen?", isFromCurrentUser: true, timestamp: Date().addingTimeInterval(-3300)),
            ChatMessage(id: "5", text: "Ben de Balık! Çok iyi uyum 💫", isFromCurrentUser: false, timestamp: Date().addingTimeInterval(-3200))
        ]
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newMessage = ChatMessage(
            id: UUID().uuidString,
            text: messageText,
            isFromCurrentUser: true,
            timestamp: Date()
        )
        
        messages.append(newMessage)
        messageText = ""
        isInputFocused = false
        
        // Simulate response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let responses = [
                "Harika! 😊",
                "Bende aynı şekilde düşünüyorum",
                "Çok ilginç!",
                "💫✨",
                "Devam edelim"
            ]
            
            let responseMessage = ChatMessage(
                id: UUID().uuidString,
                text: responses.randomElement() ?? "😊",
                isFromCurrentUser: false,
                timestamp: Date()
            )
            
            messages.append(responseMessage)
        }
    }
}

// MARK: - Chat Message Model
struct ChatMessage: Identifiable {
    let id: String
    let text: String
    let isFromCurrentUser: Bool
    let timestamp: Date
}

// MARK: - Message Bubble
struct MessageBubble: View {
    let message: ChatMessage
    let auraColor: String
    
    var body: some View {
        HStack {
            if message.isFromCurrentUser {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: message.isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        message.isFromCurrentUser
                            ? AnyView(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "#C97CF6"), Color(hex: "#7B8CDE")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            : AnyView(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Color(hex: auraColor).opacity(0.25))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .stroke(Color(hex: auraColor).opacity(0.4), lineWidth: 1)
                                    )
                            )
                    )
                
                Text(formatTime(message.timestamp))
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.4))
            }
            
            if !message.isFromCurrentUser {
                Spacer(minLength: 60)
            }
        }
        .id(message.id)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    ChatDetailScreen(match: ChatMatch(
        id: "1",
        userId: "u1",
        userName: "Elif",
        auraColor: "#C97CF6",
        lastMessage: "Merhaba!",
        lastMessageTime: Date()
    ))
}
