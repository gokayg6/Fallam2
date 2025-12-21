/**
 * Fortune Detail Screen - Admin Panel (Web)
 */

import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import firebaseService from '../../services/firebase.service';
import './FortuneDetailScreen.css';

const FortuneDetailScreen = () => {
  const { fortuneId } = useParams();
  const navigate = useNavigate();
  const [fortune, setFortune] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadFortune();
  }, [fortuneId]);

  const loadFortune = async () => {
    setLoading(true);
    try {
      const fortuneData = await firebaseService.getFortuneById(fortuneId);
      setFortune(fortuneData);
    } catch (error) {
      alert('Fal bilgileri yüklenemedi');
      navigate('/fortunes');
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = () => {
    if (!confirm('Bu fal kaydını silmek istediğinize emin misiniz?')) {
      return;
    }

    firebaseService
      .deleteFortune(fortuneId)
      .then(() => {
        alert('Fal kaydı silindi');
        navigate('/fortunes');
      })
      .catch(error => {
        alert('Fal kaydı silinemedi');
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
      <div className="fortune-detail-container">
        <div className="loading">Yükleniyor...</div>
      </div>
    );
  }

  if (!fortune) {
    return null;
  }

  return (
    <div className="fortune-detail-container">
      <div className="fortune-detail-header">
        <span className="fortune-detail-type">
          {getFortuneTypeName(fortune.type)}
        </span>
        <h1 className="fortune-detail-title">
          {fortune.title || 'Başlık yok'}
        </h1>
      </div>

      <div className="fortune-detail-section">
        <h2 className="section-title">Bilgiler</h2>
        <div className="info-grid">
          <InfoRow label="Kullanıcı ID" value={fortune.userId || 'N/A'} />
          <InfoRow label="Oluşturulma" value={formatDate(fortune.createdAt)} />
          <InfoRow label="Karma Kullanımı" value={fortune.karmaUsed || 0} />
          <InfoRow
            label="Premium"
            value={fortune.isPremium ? 'Evet' : 'Hayır'}
          />
        </div>
      </div>

      {fortune.interpretation && (
        <div className="fortune-detail-section">
          <h2 className="section-title">Yorum</h2>
          <p className="interpretation-text">{fortune.interpretation}</p>
        </div>
      )}

      {fortune.question && (
        <div className="fortune-detail-section">
          <h2 className="section-title">Soru</h2>
          <p className="question-text">{fortune.question}</p>
        </div>
      )}

      <div className="fortune-detail-actions">
        <button className="delete-button" onClick={handleDelete}>
          🗑️ Falı Sil
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

export default FortuneDetailScreen;

