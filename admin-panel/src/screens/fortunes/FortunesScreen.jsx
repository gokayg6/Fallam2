/**
 * Fortunes Screen - Admin Panel (Web)
 */

import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import firebaseService from '../../services/firebase.service';
import './FortunesScreen.css';

const FortunesScreen = () => {
  const [fortunes, setFortunes] = useState([]);
  const [filteredFortunes, setFilteredFortunes] = useState([]);
  const [filterType, setFilterType] = useState('all');
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    loadFortunes();
  }, []);

  useEffect(() => {
    if (filterType === 'all') {
      setFilteredFortunes(fortunes);
    } else {
      setFilteredFortunes(fortunes.filter(f => f.type === filterType));
    }
  }, [filterType, fortunes]);

  const loadFortunes = async () => {
    setLoading(true);
    try {
      const fortunesData = await firebaseService.getAllFortunes(50);
      setFortunes(fortunesData);
      setFilteredFortunes(fortunesData);
    } catch (error) {
      console.error('Load fortunes error:', error);
    } finally {
      setLoading(false);
    }
  };

  const formatDate = timestamp => {
    if (!timestamp) return 'N/A';
    const date = timestamp.toDate ? timestamp.toDate() : new Date(timestamp);
    return date.toLocaleDateString('tr-TR');
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
      <div className="fortunes-container">
        <div className="loading">Yükleniyor...</div>
      </div>
    );
  }

  return (
    <div className="fortunes-container">
      <div className="fortunes-header">
        <div>
          <h1 className="fortunes-title">Fal Kayıtları</h1>
          <p className="fortunes-subtitle">{filteredFortunes.length} fal kaydı</p>
        </div>
        <button className="refresh-btn" onClick={loadFortunes} title="Yenile">
          🔄
        </button>
      </div>

      <div className="fortunes-filters">
        <select
          className="filter-select"
          value={filterType}
          onChange={e => setFilterType(e.target.value)}
        >
          <option value="all">Tümü</option>
          <option value="tarot">Tarot</option>
          <option value="coffee">Kahve</option>
          <option value="palm">El</option>
          <option value="katina">Katina</option>
          <option value="water">Su</option>
          <option value="astrology">Astroloji</option>
          <option value="dream">Rüya</option>
          <option value="daily">Günlük</option>
        </select>
      </div>

      <div className="fortunes-list">
        {filteredFortunes.length === 0 ? (
          <div className="empty-state">
            <span className="empty-icon">🔮</span>
            <p className="empty-text">Fal kaydı bulunamadı</p>
          </div>
        ) : (
          filteredFortunes.map(fortune => (
            <div
              key={fortune.id}
              className="fortune-card"
              onClick={() => navigate(`/fortunes/${fortune.id}`)}
            >
              <div className="fortune-card-content">
                <div className="fortune-info">
                  <span className="fortune-type">
                    {getFortuneTypeName(fortune.type)}
                  </span>
                  <h3 className="fortune-title">
                    {fortune.title || 'Başlık yok'}
                  </h3>
                  <p className="fortune-meta">
                    {formatDate(fortune.createdAt)} • Karma:{' '}
                    {fortune.karmaUsed || 0}
                  </p>
                </div>
                <span className="fortune-arrow">→</span>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
};

export default FortunesScreen;

