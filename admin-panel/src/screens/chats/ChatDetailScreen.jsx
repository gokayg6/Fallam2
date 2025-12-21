/**
 * Chat Detail Screen - Admin Panel (Web)
 */

import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import firebaseService from '../../services/firebase.service';
import './ChatDetailScreen.css';

const ChatDetailScreen = () => {
  const { chatId } = useParams();
  const navigate = useNavigate();
  const [chat, setChat] = useState(null);
  const [userNames, setUserNames] = useState({}); // userId -> name mapping
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadChat();
  }, [chatId]);

  const loadChat = async () => {
    setLoading(true);
    try {
      console.log('Loading chat:', chatId);
      const chatData = await firebaseService.getChatDetail(chatId);
      console.log('Chat data loaded:', chatData);
      console.log('Messages count:', chatData.messages?.length || 0);
      console.log('Messages:', chatData.messages);
      
      // Kullanıcı adlarını yükle
      const userIds = new Set();
      if (chatData.users && Array.isArray(chatData.users)) {
        chatData.users.forEach(userId => userIds.add(userId));
      }
      if (chatData.messages && Array.isArray(chatData.messages)) {
        chatData.messages.forEach(msg => {
          if (msg.senderId) userIds.add(msg.senderId);
        });
      }
      
      // Tüm kullanıcı adlarını paralel olarak yükle
      const namePromises = Array.from(userIds).map(async (userId) => {
        try {
          const user = await firebaseService.getUserById(userId);
          return { userId, name: user.name || 'İsimsiz' };
        } catch (error) {
          console.error(`Error loading user ${userId}:`, error);
          return { userId, name: 'Bilinmiyor' };
        }
      });
      
      const userData = await Promise.all(namePromises);
      const namesMap = {};
      userData.forEach(({ userId, name }) => {
        namesMap[userId] = name;
      });
      
      setUserNames(namesMap);
      setChat(chatData);
    } catch (error) {
      console.error('Load chat error:', error);
      alert('Sohbet bilgileri yüklenemedi: ' + error.message);
      navigate('/chats');
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteChat = () => {
    if (!window.confirm('Bu sohbeti silmek istediğinize emin misiniz?')) {
      return;
    }

    firebaseService
      .deleteChat(chatId)
      .then(() => {
        alert('Sohbet silindi');
        navigate('/chats');
      })
      .catch(error => {
        alert('Sohbet silinemedi');
        console.error(error);
      });
  };

  const handleDeleteMessage = async (messageId) => {
    if (!window.confirm('Bu mesajı silmek istediğinize emin misiniz?')) {
      return;
    }

    try {
      await firebaseService.deleteMessage(chatId, messageId);
      // Mesajı listeden kaldır
      setChat({
        ...chat,
        messages: chat.messages.filter(msg => msg.id !== messageId),
      });
    } catch (error) {
      alert('Mesaj silinemedi');
      console.error(error);
    }
  };

  const formatDate = timestamp => {
    if (!timestamp) return 'N/A';
    const date = timestamp.toDate ? timestamp.toDate() : new Date(timestamp);
    return date.toLocaleDateString('tr-TR', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  if (loading) {
    return (
      <div className="chat-detail-container">
        <div className="loading">Yükleniyor...</div>
      </div>
    );
  }

  if (!chat) {
    return null;
  }

  return (
    <div className="chat-detail-container">
      <div className="chat-detail-header">
        <h1 className="chat-detail-title">Sohbet Detayı</h1>
        <button className="back-button" onClick={() => navigate('/chats')}>
          ← Geri
        </button>
      </div>

      <div className="chat-detail-section">
        <h2 className="section-title">Bilgiler</h2>
        <div className="info-grid">
          <InfoRow label="Sohbet ID" value={chat.id} />
          <InfoRow
            label="Kullanıcılar"
            value={
              chat.users && chat.users.length > 0
                ? chat.users
                    .map(userId => userNames[userId] || userId)
                    .join(', ')
                : 'N/A'
            }
          />
          <InfoRow label="Oluşturulma" value={formatDate(chat.createdAt)} />
          <InfoRow
            label="Mesaj Sayısı"
            value={chat.messages ? chat.messages.length : 0}
          />
        </div>
      </div>

      <div className="chat-detail-section">
        <div className="section-header">
          <h2 className="section-title">
            Mesajlar ({chat.messages ? chat.messages.length : 0})
          </h2>
          <button className="refresh-button" onClick={loadChat}>
            🔄 Yenile
          </button>
        </div>
        <div className="messages-list">
          {chat.messages && chat.messages.length > 0 ? (
            chat.messages.map(message => (
              <div key={message.id} className="message-card">
                <div className="message-header">
                  <span className="message-sender">
                    Gönderen: {message.senderId ? (userNames[message.senderId] || message.senderId) : 'Bilinmiyor'}
                  </span>
                  <button
                    className="delete-message-btn"
                    onClick={() => handleDeleteMessage(message.id)}
                    title="Mesajı Sil"
                  >
                    🗑️
                  </button>
                </div>
                <p className="message-text">{message.text || message.content || 'Mesaj içeriği yok'}</p>
                <span className="message-time">
                  {formatDate(message.timestamp || message.createdAt)}
                </span>
              </div>
            ))
          ) : (
            <div className="empty-messages">
              <p>Bu sohbette mesaj bulunmuyor</p>
            </div>
          )}
        </div>
      </div>

      <div className="chat-detail-actions">
        <button className="delete-button" onClick={handleDeleteChat}>
          🗑️ Sohbeti Sil
        </button>
      </div>
    </div>
  );
};

const InfoRow = ({ label, value }) => (
  <div className="info-row">
    <span className="info-label">{label}</span>
    <span className="info-value">{value}</span>
  </div>
);

export default ChatDetailScreen;

