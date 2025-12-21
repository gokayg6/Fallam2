/**
 * Matches Screen - Admin Panel (Web)
 */

import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import firebaseService from '../../services/firebase.service';
import './MatchesScreen.css';

const MatchesScreen = () => {
  const [matches, setMatches] = useState([]);
  const [userNames, setUserNames] = useState({}); // userId -> name mapping
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    loadMatches();
  }, []);

  const loadMatches = async () => {
    setLoading(true);
    try {
      const isAdmin = await firebaseService.checkAdminStatus();
      if (!isAdmin) {
        alert('Admin yetkisi gerekli. Lütfen admin hesabıyla giriş yapın.');
        setMatches([]);
        return;
      }

      const matchesData = await firebaseService.getAllMatches(50);
      
      // Tüm unique user ID'leri topla
      const userIds = new Set();
      (matchesData || []).forEach(match => {
        if (match.users && Array.isArray(match.users)) {
          match.users.forEach(uid => userIds.add(uid));
        }
      });

      // Her user için name'i çek
      const namesMap = {};
      await Promise.all(
        Array.from(userIds).map(async userId => {
          try {
            const user = await firebaseService.getUserById(userId);
            namesMap[userId] = user.name || 'İsimsiz';
          } catch (error) {
            console.warn(`User ${userId} not found:`, error);
            namesMap[userId] = userId.substring(0, 8) + '...';
          }
        })
      );

      setUserNames(namesMap);
      setMatches(matchesData || []);
    } catch (error) {
      console.error('Load matches error:', error);
      alert('Eşleşmeler yüklenirken bir hata oluştu: ' + error.message);
      setMatches([]);
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteMatch = async (matchId, e) => {
    e.stopPropagation();
    if (!window.confirm('Bu eşleşmeyi silmek istediğinize emin misiniz?')) {
      return;
    }

    try {
      await firebaseService.deleteMatch(matchId);
      setMatches(matches.filter(match => match.id !== matchId));
    } catch (error) {
      console.error('Delete match error:', error);
      alert('Eşleşme silinirken bir hata oluştu');
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

  const getStatusDisplay = status => {
    const statusMap = {
      accepted: { text: 'Kabul Edildi', color: '#4CAF50' },
      pending: { text: 'Beklemede', color: '#FF9800' },
      rejected: { text: 'Reddedildi', color: '#F44336' },
    };
    return statusMap[status] || { text: status || 'Bilinmiyor', color: '#999' };
  };

  const getUsersDisplay = users => {
    if (!users || users.length === 0) return 'Kullanıcı yok';
    if (users.length === 1) return userNames[users[0]] || users[0].substring(0, 8) + '...';
    return users.map(uid => userNames[uid] || uid.substring(0, 8) + '...').join(' & ');
  };

  if (loading) {
    return (
      <div className="matches-container">
        <div className="loading">Yükleniyor...</div>
      </div>
    );
  }

  return (
    <div className="matches-container">
      <div className="matches-header">
        <div>
          <h1 className="matches-title">Eşleşmeler</h1>
          <p className="matches-subtitle">{matches.length} eşleşme</p>
        </div>
        <button className="refresh-btn" onClick={loadMatches} title="Yenile">
          🔄
        </button>
      </div>

      <div className="matches-list">
        {matches.length === 0 ? (
          <div className="empty-state">
            <span className="empty-icon">💕</span>
            <p className="empty-text">Eşleşme bulunamadı</p>
          </div>
        ) : (
          matches.map(match => {
            const statusInfo = getStatusDisplay(match.status);
            return (
              <div 
                key={match.id} 
                className="match-card"
                onClick={() => navigate(`/matches/${match.id}`)}
              >
                <div className="match-card-content">
                  <div className="match-info">
                    <div className="match-header-row">
                      <h3 className="match-title">
                        {getUsersDisplay(match.users)}
                      </h3>
                      <button
                        className="delete-btn"
                        onClick={e => handleDeleteMatch(match.id, e)}
                        title="Eşleşmeyi Sil"
                      >
                        🗑️
                      </button>
                    </div>
                    <div className="match-details">
                      <span
                        className="match-status"
                        style={{ color: statusInfo.color }}
                      >
                        {statusInfo.text}
                      </span>
                      {match.score && (
                        <span className="match-score">
                          Skor: {match.score.toFixed(1)}%
                        </span>
                      )}
                      {match.hasAuraCompatibility && (
                        <span className="match-aura">✨ Aura Uyumu</span>
                      )}
                    </div>
                    <p className="match-meta">
                      Oluşturulma: {formatDate(match.createdAt)}
                    </p>
                    {match.acceptedAt && (
                      <p className="match-meta">
                        Kabul: {formatDate(match.acceptedAt)}
                      </p>
                    )}
                    {match.rejectedAt && (
                      <p className="match-meta">
                        Red: {formatDate(match.rejectedAt)}
                      </p>
                    )}
                  </div>
                  <span className="match-arrow">→</span>
                </div>
              </div>
            );
          })
        )}
      </div>
    </div>
  );
};

export default MatchesScreen;

