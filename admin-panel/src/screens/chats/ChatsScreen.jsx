/**
 * Chats Screen - Admin Panel (Web)
 */

import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import firebaseService from '../../services/firebase.service';
import './ChatsScreen.css';

const ChatsScreen = () => {
  const [chats, setChats] = useState([]);
  const [userNames, setUserNames] = useState({}); // userId -> name mapping
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    loadChats();
  }, []);

  const loadChats = async () => {
    setLoading(true);
    try {
      // Önce admin kontrolü yap
      const isAdmin = await firebaseService.checkAdminStatus();
      
      if (!isAdmin) {
        alert('Admin yetkisi gerekli. Lütfen admin hesabıyla giriş yapın.');
        setChats([]);
        return;
      }
      
      const chatsData = await firebaseService.getAllChats(50);
      
      // Tüm unique user ID'leri topla
      const userIds = new Set();
      (chatsData || []).forEach(chat => {
        if (chat.users && Array.isArray(chat.users)) {
          chat.users.forEach(uid => userIds.add(uid));
        }
      });

      // Batch olarak user bilgilerini çek
      const namesMap = {};
      await Promise.all(
        Array.from(userIds).map(async userId => {
          try {
            const user = await firebaseService.getUserById(userId);
            namesMap[userId] = user.name || 'İsimsiz';
          } catch (error) {
            namesMap[userId] = userId.substring(0, 8) + '...';
          }
        })
      );

      setUserNames(namesMap);
      setChats(chatsData || []);
    } catch (error) {
      console.error('Load chats error:', error);
      alert('Sohbetler yüklenirken bir hata oluştu: ' + error.message);
      setChats([]);
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteChat = async (chatId, e) => {
    e.stopPropagation();
    if (!window.confirm('Bu sohbeti silmek istediğinize emin misiniz?')) {
      return;
    }

    try {
      await firebaseService.deleteChat(chatId);
      setChats(chats.filter(chat => chat.id !== chatId));
    } catch (error) {
      console.error('Delete chat error:', error);
      alert('Sohbet silinirken bir hata oluştu');
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

  const getUsersDisplay = users => {
    if (!users || users.length === 0) return 'Kullanıcı yok';
    if (users.length === 1) return userNames[users[0]] || users[0].substring(0, 8) + '...';
    return users.map(uid => userNames[uid] || uid.substring(0, 8) + '...').join(' & ');
  };

  if (loading) {
    return (
      <div className="chats-container">
        <div className="loading">Yükleniyor...</div>
      </div>
    );
  }

  return (
    <div className="chats-container">
      <div className="chats-header">
        <div>
          <h1 className="chats-title">Sohbetler</h1>
          <p className="chats-subtitle">{chats.length} sohbet</p>
        </div>
        <button className="refresh-btn" onClick={loadChats} title="Yenile">
          🔄
        </button>
      </div>

      <div className="chats-list">
        {chats.length === 0 ? (
          <div className="empty-state">
            <span className="empty-icon">💬</span>
            <p className="empty-text">Sohbet bulunamadı</p>
          </div>
        ) : (
          chats.map(chat => (
            <div key={chat.id} className="chat-card">
              <div
                className="chat-card-content"
                onClick={() => navigate(`/chats/${chat.id}`)}
              >
                <div className="chat-info">
                  <div className="chat-header-row">
                    <h3 className="chat-title">
                      {getUsersDisplay(chat.users)}
                    </h3>
                    <button
                      className="delete-btn"
                      onClick={e => handleDeleteChat(chat.id, e)}
                      title="Sohbeti Sil"
                    >
                      🗑️
                    </button>
                  </div>
                  <p className="chat-meta">
                    Oluşturulma: {formatDate(chat.createdAt)}
                  </p>
                  {chat.lastMessage && (
                    <p className="chat-last-message">
                      Son mesaj: {chat.lastMessage.substring(0, 50)}...
                    </p>
                  )}
                </div>
                <span className="chat-arrow">→</span>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
};

export default ChatsScreen;

