/**
 * Dashboard Screen - Admin Panel (Web)
 */

import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import firebaseService from '../../services/firebase.service';
import './DashboardScreen.css';

const DashboardScreen = () => {
  const [stats, setStats] = useState({
    totalUsers: 0,
    activeUsers: 0,
    premiumUsers: 0,
    totalFortunes: 0,
    todayFortunes: 0,
    totalTests: 0,
    totalMatches: 0,
    totalChats: 0,
  });
  const [premiumUsers, setPremiumUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [loadingPremium, setLoadingPremium] = useState(false);
  const navigate = useNavigate();

  useEffect(() => {
    loadStats();
    loadPremiumUsers();
  }, []);

  const loadStats = async () => {
    setLoading(true);
    try {
      const [totalUsers, activeUsers, premiumUsers, todayFortunes, tests, matches, chats] = await Promise.all([
        firebaseService.getTotalUsers(),
        firebaseService.getActiveUsers(),
        firebaseService.getPremiumUsersCount(),
        firebaseService.getDailyFortunesCount(new Date()),
        firebaseService.getAllTestResults(1000), // Toplam sayı için
        firebaseService.getAllMatches(1000),
        firebaseService.getAllChats(1000),
      ]);

      // Toplam fal sayısını yaklaşık olarak al
      const fortunes = await firebaseService.getAllFortunes(1);
      const totalFortunes = fortunes.length > 0 ? 'N/A' : 0;

      setStats({
        totalUsers,
        activeUsers,
        premiumUsers,
        totalFortunes,
        todayFortunes,
        totalTests: tests.length,
        totalMatches: matches.length,
        totalChats: chats.length,
      });
    } catch (error) {
      console.error('Load stats error:', error);
    } finally {
      setLoading(false);
    }
  };

  const loadPremiumUsers = async () => {
    setLoadingPremium(true);
    try {
      console.log('Loading premium users...');
      const users = await firebaseService.getPremiumUsers(10); // İlk 10 premium kullanıcı
      console.log('Premium users loaded:', users);
      setPremiumUsers(users || []);
    } catch (error) {
      console.error('Load premium users error:', error);
      setPremiumUsers([]);
    } finally {
      setLoadingPremium(false);
    }
  };

  const formatDate = (timestamp) => {
    if (!timestamp) return 'N/A';
    const date = timestamp.toDate ? timestamp.toDate() : new Date(timestamp);
    return date.toLocaleDateString('tr-TR', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
    });
  };

  const StatCard = ({ title, value, icon, color, onClick }) => (
    <div
      className="stat-card"
      style={{ borderLeftColor: color }}
      onClick={onClick}
    >
      <div className="stat-card-content">
        <span className="stat-icon" style={{ color }}>
          {icon}
        </span>
        <div className="stat-card-text">
          <div className="stat-value">{value}</div>
          <div className="stat-title">{title}</div>
        </div>
      </div>
    </div>
  );

  if (loading) {
    return (
      <div className="dashboard-container">
        <div className="loading">Yükleniyor...</div>
      </div>
    );
  }

  return (
    <div className="dashboard-container">
      <div className="dashboard-header">
        <div>
          <h1 className="dashboard-title">Dashboard</h1>
          <p className="dashboard-subtitle">Genel Bakış</p>
        </div>
        <button className="refresh-btn" onClick={loadStats} title="Yenile">
          🔄
        </button>
      </div>

      <div className="stats-grid">
        <StatCard
          title="Toplam Kullanıcı"
          value={stats.totalUsers}
          icon="👥"
          color="#D26AFF"
          onClick={() => navigate('/users')}
        />

        <StatCard
          title="Aktif Kullanıcı (30 gün)"
          value={stats.activeUsers}
          icon="👤"
          color="#9B51E0"
          onClick={() => navigate('/users')}
        />

        <StatCard
          title="Premium Kullanıcı"
          value={stats.premiumUsers}
          icon="👑"
          color="#FFD700"
          onClick={() => navigate('/users')}
        />

        <StatCard
          title="Bugünkü Fallar"
          value={stats.todayFortunes}
          icon="🔮"
          color="#E0C88F"
          onClick={() => navigate('/fortunes')}
        />

        <StatCard
          title="Toplam Fal"
          value={stats.totalFortunes}
          icon="📚"
          color="#6A4C93"
          onClick={() => navigate('/fortunes')}
        />

        <StatCard
          title="Toplam Test"
          value={stats.totalTests}
          icon="📝"
          color="#4CAF50"
          onClick={() => navigate('/tests')}
        />

        <StatCard
          title="Toplam Eşleşme"
          value={stats.totalMatches}
          icon="💕"
          color="#FF6B9D"
          onClick={() => navigate('/matches')}
        />

        <StatCard
          title="Toplam Sohbet"
          value={stats.totalChats}
          icon="💬"
          color="#2196F3"
          onClick={() => navigate('/chats')}
        />
      </div>

      <div className="premium-section">
        <div className="premium-header">
          <div>
            <h2 className="section-title">Premium Kullanıcılar</h2>
            <p className="section-subtitle">
              {stats.premiumUsers} premium kullanıcı ({premiumUsers.length} gösteriliyor)
            </p>
          </div>
          <button
            className="refresh-btn-small"
            onClick={loadPremiumUsers}
            title="Yenile"
            disabled={loadingPremium}
          >
            {loadingPremium ? '⏳' : '🔄'}
          </button>
        </div>

        {loadingPremium ? (
          <div className="loading-small">Yükleniyor...</div>
        ) : premiumUsers.length === 0 ? (
          <div className="empty-premium">
            <span className="empty-icon">👑</span>
            <p className="empty-text">Premium kullanıcı bulunamadı</p>
          </div>
        ) : (
          <div className="premium-grid">
            {premiumUsers.map(user => (
              <div
                key={user.id}
                className="premium-card"
                onClick={() => navigate(`/users/${user.id}`)}
              >
                <div className="premium-card-header">
                  <div className="premium-badge">👑 Premium</div>
                </div>
                <div className="premium-card-content">
                  <h3 className="premium-name">{user.name || 'İsimsiz'}</h3>
                  <p className="premium-email">{user.email || 'Email yok'}</p>
                  <div className="premium-meta">
                    <span className="premium-meta-item">
                      💎 Karma: {user.karma || 0}
                    </span>
                    <span className="premium-meta-item">
                      📅 {formatDate(user.createdAt)}
                    </span>
                  </div>
                  {user.premiumUpgradeDate && (
                    <p className="premium-upgrade-date">
                      Premium: {formatDate(user.premiumUpgradeDate)}
                    </p>
                  )}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      <div className="quick-actions">
        <h2 className="section-title">Hızlı İşlemler</h2>

        <div
          className="action-button"
          onClick={() => navigate('/users')}
        >
          <span className="action-icon">👥</span>
          <span className="action-text">Kullanıcıları Görüntüle</span>
          <span className="action-arrow">→</span>
        </div>

        <div
          className="action-button"
          onClick={() => navigate('/fortunes')}
        >
          <span className="action-icon">🔮</span>
          <span className="action-text">Falları Görüntüle</span>
          <span className="action-arrow">→</span>
        </div>

        <div
          className="action-button"
          onClick={() => navigate('/statistics')}
        >
          <span className="action-icon">📈</span>
          <span className="action-text">İstatistikleri Görüntüle</span>
          <span className="action-arrow">→</span>
        </div>
      </div>
    </div>
  );
};

export default DashboardScreen;

