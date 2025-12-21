/**
 * Match Detail Screen - Admin Panel (Web)
 */

import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import firebaseService from '../../services/firebase.service';
import './MatchDetailScreen.css';

const MatchDetailScreen = () => {
  const { matchId } = useParams();
  const navigate = useNavigate();
  const [match, setMatch] = useState(null);
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadMatch();
  }, [matchId]);

  const loadMatch = async () => {
    setLoading(true);
    try {
      const matchData = await firebaseService.getMatchDetail(matchId);
      setMatch(matchData);

      // Kullanıcı bilgilerini çek
      if (matchData.users && Array.isArray(matchData.users)) {
        const userPromises = matchData.users.map(async userId => {
          try {
            const user = await firebaseService.getUserById(userId);
            return { id: userId, ...user };
          } catch (error) {
            console.warn(`User ${userId} not found:`, error);
            return { id: userId, name: 'Bilinmeyen Kullanıcı', email: 'N/A' };
          }
        });
        const usersData = await Promise.all(userPromises);
        setUsers(usersData);
      }
    } catch (error) {
      alert('Eşleşme bilgileri yüklenemedi');
      navigate('/matches');
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteMatch = () => {
    if (!window.confirm('Bu eşleşmeyi silmek istediğinize emin misiniz?')) {
      return;
    }

    firebaseService
      .deleteMatch(matchId)
      .then(() => {
        alert('Eşleşme silindi');
        navigate('/matches');
      })
      .catch(error => {
        alert('Eşleşme silinemedi');
        console.error(error);
      });
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

  if (loading) {
    return (
      <div className="match-detail-container">
        <div className="loading">Yükleniyor...</div>
      </div>
    );
  }

  if (!match) {
    return null;
  }

  const statusInfo = getStatusDisplay(match.status);

  return (
    <div className="match-detail-container">
      <div className="match-detail-header">
        <button className="back-btn" onClick={() => navigate('/matches')}>
          ← Geri
        </button>
        <div className="match-header-content">
          <h1 className="match-detail-title">Eşleşme Detayı</h1>
          <button className="delete-btn" onClick={handleDeleteMatch}>
            🗑️ Sil
          </button>
        </div>
      </div>

      <div className="match-detail-section">
        <h2 className="section-title">Durum</h2>
        <div className="status-badge" style={{ color: statusInfo.color }}>
          {statusInfo.text}
        </div>
      </div>

      <div className="match-detail-section">
        <h2 className="section-title">Kullanıcılar</h2>
        <div className="users-grid">
          {users.map(user => (
            <div key={user.id} className="user-card">
              <div className="user-avatar">👤</div>
              <div className="user-info">
                <h3 className="user-name">{user.name || 'İsimsiz'}</h3>
                <p className="user-email">{user.email || 'Email yok'}</p>
                <p className="user-id">ID: {user.id}</p>
              </div>
            </div>
          ))}
        </div>
      </div>

      <div className="match-detail-section">
        <h2 className="section-title">Eşleşme Bilgileri</h2>
        <div className="info-grid">
          {match.score && (
            <div className="info-item">
              <span className="info-label">Skor:</span>
              <span className="info-value">{match.score.toFixed(1)}%</span>
            </div>
          )}
          {match.hasAuraCompatibility && (
            <div className="info-item">
              <span className="info-label">Aura Uyumu:</span>
              <span className="info-value">✨ Var</span>
            </div>
          )}
          {match.initiator && (
            <div className="info-item">
              <span className="info-label">Başlatan:</span>
              <span className="info-value">
                {users.find(u => u.id === match.initiator)?.name || match.initiator.substring(0, 8) + '...'}
              </span>
            </div>
          )}
        </div>
      </div>

      <div className="match-detail-section">
        <h2 className="section-title">Zaman Bilgileri</h2>
        <div className="info-grid">
          <div className="info-item">
            <span className="info-label">Oluşturulma:</span>
            <span className="info-value">{formatDate(match.createdAt)}</span>
          </div>
          {match.acceptedAt && (
            <div className="info-item">
              <span className="info-label">Kabul:</span>
              <span className="info-value">{formatDate(match.acceptedAt)}</span>
            </div>
          )}
          {match.rejectedAt && (
            <div className="info-item">
              <span className="info-label">Red:</span>
              <span className="info-value">{formatDate(match.rejectedAt)}</span>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default MatchDetailScreen;

