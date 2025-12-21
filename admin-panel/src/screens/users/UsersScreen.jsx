/**
 * Users Screen - Admin Panel (Web)
 */

import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import firebaseService from '../../services/firebase.service';
import './UsersScreen.css';

const UsersScreen = () => {
  const [users, setUsers] = useState([]);
  const [filteredUsers, setFilteredUsers] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterType, setFilterType] = useState('all'); // 'all', 'premium', 'free'
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    loadUsers();
  }, []);

  useEffect(() => {
    let filtered = users;

    // Filtreleme
    if (filterType === 'premium') {
      filtered = filtered.filter(user => user.isPremium === true);
    } else if (filterType === 'free') {
      filtered = filtered.filter(user => !user.isPremium || user.isPremium === false);
    }

    // Arama
    if (searchTerm) {
      filtered = filtered.filter(
        user =>
          user.name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
          user.email?.toLowerCase().includes(searchTerm.toLowerCase()),
      );
    }

    setFilteredUsers(filtered);
  }, [searchTerm, filterType, users]);

  const loadUsers = async () => {
    setLoading(true);
    try {
      const usersData = await firebaseService.getAllUsers(50);
      setUsers(usersData);
      setFilteredUsers(usersData);
    } catch (error) {
      console.error('Load users error:', error);
    } finally {
      setLoading(false);
    }
  };

  const formatDate = timestamp => {
    if (!timestamp) return 'N/A';
    const date = timestamp.toDate ? timestamp.toDate() : new Date(timestamp);
    return date.toLocaleDateString('tr-TR');
  };

  if (loading) {
    return (
      <div className="users-container">
        <div className="loading">Yükleniyor...</div>
      </div>
    );
  }

  return (
    <div className="users-container">
      <div className="users-header">
        <h1 className="users-title">Kullanıcılar</h1>
        <div className="users-controls">
          <div className="filter-buttons">
            <button
              className={`filter-button ${filterType === 'all' ? 'active' : ''}`}
              onClick={() => setFilterType('all')}
            >
              Tümü ({users.length})
            </button>
            <button
              className={`filter-button ${filterType === 'premium' ? 'active' : ''}`}
              onClick={() => setFilterType('premium')}
            >
              Premium ({users.filter(u => u.isPremium).length})
            </button>
            <button
              className={`filter-button ${filterType === 'free' ? 'active' : ''}`}
              onClick={() => setFilterType('free')}
            >
              Ücretsiz ({users.filter(u => !u.isPremium).length})
            </button>
          </div>
          <input
            type="text"
            className="search-input"
            placeholder="Kullanıcı ara..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
      </div>

      <div className="users-list">
        {filteredUsers.length === 0 ? (
          <div className="empty-state">
            <span className="empty-icon">👥</span>
            <p className="empty-text">Kullanıcı bulunamadı</p>
          </div>
        ) : (
          filteredUsers.map(user => (
            <div
              key={user.id}
              className="user-card"
              onClick={() => navigate(`/users/${user.id}`)}
            >
              <div className="user-card-content">
                <div className="user-info">
                  <h3 className="user-name">{user.name || 'İsimsiz'}</h3>
                  <p className="user-email">{user.email || 'Email yok'}</p>
                  <p className="user-meta">
                    Karma: {user.karma || 0} • {user.isPremium ? 'Premium' : 'Ücretsiz'}
                  </p>
                </div>
                <span className="user-arrow">→</span>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
};

export default UsersScreen;

