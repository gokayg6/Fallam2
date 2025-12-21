/**
 * Tests Screen - Admin Panel (Web)
 */

import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import firebaseService from '../../services/firebase.service';
import './TestsScreen.css';

const TestsScreen = () => {
  const [tests, setTests] = useState([]);
  const [filteredTests, setFilteredTests] = useState([]);
  const [filterType, setFilterType] = useState('all');
  const [userNames, setUserNames] = useState({}); // userId -> name mapping
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    loadTests();
  }, []);

  const loadTests = async () => {
    setLoading(true);
    try {
      const testsData = await firebaseService.getAllTestResults(50);
      
      // Tüm unique user ID'leri topla
      const userIds = new Set();
      (testsData || []).forEach(test => {
        if (test.userId) {
          userIds.add(test.userId);
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
            console.warn(`User ${userId} not found:`, error);
            namesMap[userId] = userId.substring(0, 8) + '...';
          }
        })
      );

      setUserNames(namesMap);
      setTests(testsData || []);
      setFilteredTests(testsData || []);
    } catch (error) {
      console.error('Load tests error:', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (filterType === 'all') {
      setFilteredTests(tests);
    } else {
      setFilteredTests(tests.filter(t => (t.kind || t.type) === filterType));
    }
  }, [filterType, tests]);

  const formatDate = timestamp => {
    if (!timestamp) return 'N/A';
    const date = timestamp.toDate ? timestamp.toDate() : new Date(timestamp);
    return date.toLocaleDateString('tr-TR');
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
      <div className="tests-container">
        <div className="loading">Yükleniyor...</div>
      </div>
    );
  }

  return (
    <div className="tests-container">
      <div className="tests-header">
        <div>
          <h1 className="tests-title">Test Sonuçları</h1>
          <p className="tests-subtitle">{filteredTests.length} test sonucu</p>
        </div>
        <button className="refresh-btn" onClick={loadTests} title="Yenile">
          🔄
        </button>
      </div>

      <div className="tests-filters">
        <select
          className="filter-select"
          value={filterType}
          onChange={e => setFilterType(e.target.value)}
        >
          <option value="all">Tümü</option>
          <option value="love">Aşk Testi</option>
          <option value="relationship">İlişki Testi</option>
          <option value="destiny">Kader Testi</option>
          <option value="personality">Kişilik Testi</option>
          <option value="quiz">Quiz Testi</option>
        </select>
      </div>

      <div className="tests-list">
        {filteredTests.length === 0 ? (
          <div className="empty-state">
            <span className="empty-icon">📝</span>
            <p className="empty-text">Test sonucu bulunamadı</p>
          </div>
        ) : (
          filteredTests.map(test => (
            <div 
              key={test.id} 
              className="test-card"
              onClick={() => navigate(`/tests/${test.userId}/${test.collectionType}/${test.id}`)}
            >
              <div className="test-card-content">
                <div className="test-info">
                  <h3 className="test-type">
                    {getTestTypeName(test.kind || test.type)}
                  </h3>
                  <p className="test-meta">
                    Kullanıcı: {userNames[test.userId] || test.userId?.substring(0, 8) + '...'} •{' '}
                    {formatDate(test.createdAt)}
                  </p>
                </div>
                <span className="test-arrow">→</span>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
};

export default TestsScreen;

