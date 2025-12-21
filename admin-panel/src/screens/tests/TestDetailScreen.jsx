/**
 * Test Detail Screen - Admin Panel (Web)
 */

import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import firebaseService from '../../services/firebase.service';
import './TestDetailScreen.css';

const TestDetailScreen = () => {
  const { userId, collectionType, testId } = useParams();
  const navigate = useNavigate();
  const [test, setTest] = useState(null);
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadTest();
  }, [userId, collectionType, testId]);

  const loadTest = async () => {
    setLoading(true);
    try {
      const testData = await firebaseService.getTestResult(userId, collectionType, testId);
      setTest(testData);

      // Kullanıcı bilgilerini çek
      try {
        const userData = await firebaseService.getUserById(userId);
        setUser(userData);
      } catch (error) {
        console.warn('User not found:', error);
      }
    } catch (error) {
      alert('Test bilgileri yüklenemedi');
      navigate('/tests');
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = () => {
    if (!window.confirm('Bu test sonucunu silmek istediğinize emin misiniz?')) {
      return;
    }

    firebaseService
      .deleteTestResult(userId, collectionType, testId)
      .then(() => {
        alert('Test sonucu silindi');
        navigate('/tests');
      })
      .catch(error => {
        alert('Test sonucu silinemedi');
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

  const getTestTypeName = type => {
    const types = {
      love: 'Aşk Testi',
      relationship: 'İlişki Testi',
      destiny: 'Kader Testi',
      personality: 'Kişilik Testi',
      quiz: 'Quiz Testi',
    };
    return types[type] || type;
  };

  if (loading) {
    return (
      <div className="test-detail-container">
        <div className="loading">Yükleniyor...</div>
      </div>
    );
  }

  if (!test) {
    return null;
  }

  return (
    <div className="test-detail-container">
      <div className="test-detail-header">
        <button className="back-btn" onClick={() => navigate('/tests')}>
          ← Geri
        </button>
        <div className="test-header-content">
          <h1 className="test-detail-title">
            {getTestTypeName(test.kind || test.type)}
          </h1>
          <button className="delete-btn" onClick={handleDelete}>
            🗑️ Sil
          </button>
        </div>
      </div>

      {user && (
        <div className="test-detail-section">
          <h2 className="section-title">Kullanıcı Bilgileri</h2>
          <div className="user-info-card">
            <div className="user-avatar">👤</div>
            <div className="user-info">
              <h3 className="user-name">{user.name || 'İsimsiz'}</h3>
              <p className="user-email">{user.email || 'Email yok'}</p>
              <p className="user-id">ID: {user.id}</p>
            </div>
          </div>
        </div>
      )}

      <div className="test-detail-section">
        <h2 className="section-title">Test Bilgileri</h2>
        <div className="info-grid">
          <div className="info-item">
            <span className="info-label">Test Türü:</span>
            <span className="info-value">{getTestTypeName(test.kind || test.type)}</span>
          </div>
          <div className="info-item">
            <span className="info-label">Oluşturulma:</span>
            <span className="info-value">{formatDate(test.createdAt)}</span>
          </div>
          {test.collectionType && (
            <div className="info-item">
              <span className="info-label">Koleksiyon:</span>
              <span className="info-value">
                {test.collectionType === 'quiz_test_results' ? 'Quiz Testi' : 'Normal Test'}
              </span>
            </div>
          )}
        </div>
      </div>

      {test.result && (
        <div className="test-detail-section">
          <h2 className="section-title">Test Sonucu</h2>
          <div className="test-result-content">
            {typeof test.result === 'object' ? (
              <pre className="test-result-json">
                {JSON.stringify(test.result, null, 2)}
              </pre>
            ) : (
              <p className="test-result-text">{test.result}</p>
            )}
          </div>
        </div>
      )}

      {test.answers && (
        <div className="test-detail-section">
          <h2 className="section-title">Cevaplar</h2>
          <div className="test-result-content">
            {typeof test.answers === 'object' ? (
              <pre className="test-result-json">
                {JSON.stringify(test.answers, null, 2)}
              </pre>
            ) : (
              <p className="test-result-text">{test.answers}</p>
            )}
          </div>
        </div>
      )}

      {test.score !== undefined && (
        <div className="test-detail-section">
          <h2 className="section-title">Skor</h2>
          <div className="score-display">
            <span className="score-value">{test.score}</span>
            {test.maxScore && (
              <span className="score-max">/ {test.maxScore}</span>
            )}
          </div>
        </div>
      )}

      <div className="test-detail-section">
        <h2 className="section-title">Ham Veri</h2>
        <div className="test-result-content">
          <pre className="test-result-json">
            {JSON.stringify(test, null, 2)}
          </pre>
        </div>
      </div>
    </div>
  );
};

export default TestDetailScreen;

