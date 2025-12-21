/**
 * Statistics Screen - Admin Panel (Web)
 */

import React, { useState, useEffect } from 'react';
import firebaseService from '../../services/firebase.service';
import './StatisticsScreen.css';

const StatisticsScreen = () => {
  const [stats, setStats] = useState({
    totalUsers: 0,
    activeUsers: 0,
    totalFortunes: 0,
    fortunesByType: {},
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadStatistics();
  }, []);

  const loadStatistics = async () => {
    setLoading(true);
    try {
      const [totalUsers, activeUsers, fortunesByType] = await Promise.all([
        firebaseService.getTotalUsers(),
        firebaseService.getActiveUsers(),
        firebaseService.getFortunesByType(),
      ]);

      const totalFortunes = Object.values(fortunesByType).reduce(
        (sum, count) => sum + count,
        0,
      );

      setStats({
        totalUsers,
        activeUsers,
        totalFortunes,
        fortunesByType,
      });
    } catch (error) {
      console.error('Load statistics error:', error);
    } finally {
      setLoading(false);
    }
  };

  const getFortuneTypeName = type => {
    const types = {
      tarot: 'Tarot Falı',
      coffee: 'Kahve Falı',
      palm: 'El Falı',
      katina: 'Katina Falı',
      water: 'Su Falı',
      astrology: 'Astroloji',
      dream: 'Rüya Yorumu',
      daily: 'Günlük Yorum',
    };
    return types[type] || type;
  };

  if (loading) {
    return (
      <div className="statistics-container">
        <div className="loading">Yükleniyor...</div>
      </div>
    );
  }

  return (
    <div className="statistics-container">
      <div className="statistics-header">
        <h1 className="statistics-title">İstatistikler</h1>
        <p className="statistics-subtitle">Genel veriler</p>
      </div>

      <div className="stats-grid">
        <StatCard
          title="Toplam Kullanıcı"
          value={stats.totalUsers}
          icon="👥"
          color="#D26AFF"
        />
        <StatCard
          title="Aktif Kullanıcı (30 gün)"
          value={stats.activeUsers}
          icon="👤"
          color="#9B51E0"
        />
        <StatCard
          title="Toplam Fal"
          value={stats.totalFortunes}
          icon="🔮"
          color="#E0C88F"
        />
      </div>

      <div className="statistics-section">
        <h2 className="section-title">Fal Türlerine Göre Dağılım</h2>
        <div className="type-list">
          {Object.entries(stats.fortunesByType).length === 0 ? (
            <p className="empty-text">Veri bulunamadı</p>
          ) : (
            Object.entries(stats.fortunesByType).map(([type, count]) => (
              <div key={type} className="type-row">
                <span className="type-name">{getFortuneTypeName(type)}</span>
                <span className="type-count">{count}</span>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
};

const StatCard = ({ title, value, icon, color }) => (
  <div className="stat-card" style={{ borderLeftColor: color }}>
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

export default StatisticsScreen;

