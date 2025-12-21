/**
 * Admins Screen - Admin Panel (Web)
 */

import React, { useState, useEffect } from 'react';
import firebaseService from '../../services/firebase.service';
import './AdminsScreen.css';

const AdminsScreen = () => {
  const [admins, setAdmins] = useState([]);
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showAddForm, setShowAddForm] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedUserId, setSelectedUserId] = useState('');

  useEffect(() => {
    loadAdmins();
    loadUsers();
  }, []);

  const loadAdmins = async () => {
    setLoading(true);
    try {
      const adminsData = await firebaseService.getAllAdmins();
      setAdmins(adminsData || []);
    } catch (error) {
      console.error('Load admins error:', error);
      alert("Admin'ler yüklenirken bir hata oluştu");
    } finally {
      setLoading(false);
    }
  };

  const loadUsers = async () => {
    try {
      const usersData = await firebaseService.getAllUsers(100);
      setUsers(usersData || []);
    } catch (error) {
      console.error('Load users error:', error);
    }
  };

  const handleAddAdmin = async () => {
    if (!selectedUserId) {
      alert('Lütfen bir kullanıcı seçin');
      return;
    }

    const user = users.find(u => u.id === selectedUserId);
    if (!user) {
      alert('Kullanıcı bulunamadı');
      return;
    }

    if (!window.confirm(`${user.name || user.email} kullanıcısını admin yapmak istediğinize emin misiniz?`)) {
      return;
    }

    try {
      await firebaseService.addAdmin(selectedUserId, user.email);
      alert('Admin eklendi');
      setShowAddForm(false);
      setSelectedUserId('');
      loadAdmins();
    } catch (error) {
      alert('Admin eklenirken bir hata oluştu');
      console.error(error);
    }
  };

  const handleRemoveAdmin = async (adminId, adminEmail) => {
    if (!window.confirm(`${adminEmail} admin yetkisini kaldırmak istediğinize emin misiniz?`)) {
      return;
    }

    try {
      await firebaseService.removeAdmin(adminId);
      alert('Admin yetkisi kaldırıldı');
      loadAdmins();
    } catch (error) {
      alert('Admin yetkisi kaldırılırken bir hata oluştu');
      console.error(error);
    }
  };

  const formatDate = timestamp => {
    if (!timestamp) return 'N/A';
    const date = timestamp.toDate ? timestamp.toDate() : new Date(timestamp);
    return date.toLocaleDateString('tr-TR', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    });
  };

  const filteredUsers = users.filter(user => {
    if (!searchTerm) return true;
    const search = searchTerm.toLowerCase();
    return (
      user.name?.toLowerCase().includes(search) ||
      user.email?.toLowerCase().includes(search) ||
      user.id.toLowerCase().includes(search)
    );
  });

  const availableUsers = filteredUsers.filter(
    user => !admins.some(admin => admin.id === user.id)
  );

  if (loading) {
    return (
      <div className="admins-container">
        <div className="loading">Yükleniyor...</div>
      </div>
    );
  }

  return (
    <div className="admins-container">
      <div className="admins-header">
        <div>
          <h1 className="admins-title">Admin Yönetimi</h1>
          <p className="admins-subtitle">{admins.length} admin</p>
        </div>
        <button
          className="add-admin-btn"
          onClick={() => setShowAddForm(!showAddForm)}
        >
          {showAddForm ? '✕ İptal' : '+ Admin Ekle'}
        </button>
      </div>

      {showAddForm && (
        <div className="add-admin-form">
          <h3 className="form-title">Yeni Admin Ekle</h3>
          <input
            type="text"
            className="search-input"
            placeholder="Kullanıcı ara..."
            value={searchTerm}
            onChange={e => setSearchTerm(e.target.value)}
          />
          <select
            className="user-select"
            value={selectedUserId}
            onChange={e => setSelectedUserId(e.target.value)}
          >
            <option value="">Kullanıcı seçin...</option>
            {availableUsers.map(user => (
              <option key={user.id} value={user.id}>
                {user.name || 'İsimsiz'} ({user.email || 'Email yok'})
              </option>
            ))}
          </select>
          <button className="submit-btn" onClick={handleAddAdmin}>
            Admin Ekle
          </button>
        </div>
      )}

      <div className="admins-list">
        {admins.length === 0 ? (
          <div className="empty-state">
            <span className="empty-icon">👑</span>
            <p className="empty-text">Admin bulunamadı</p>
          </div>
        ) : (
          admins.map(admin => (
            <div key={admin.id} className="admin-card">
              <div className="admin-card-content">
                <div className="admin-info">
                  <div className="admin-header-row">
                    <h3 className="admin-email">{admin.email || 'Email yok'}</h3>
                    {admin.isFirstAdmin && (
                      <span className="first-admin-badge">İlk Admin</span>
                    )}
                  </div>
                  <p className="admin-meta">
                    ID: {admin.id.substring(0, 16)}...
                  </p>
                  <p className="admin-meta">
                    Oluşturulma: {formatDate(admin.createdAt)}
                  </p>
                </div>
                {!admin.isFirstAdmin && (
                  <button
                    className="remove-btn"
                    onClick={() => handleRemoveAdmin(admin.id, admin.email)}
                    title="Admin Yetkisini Kaldır"
                  >
                    🗑️
                  </button>
                )}
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
};

export default AdminsScreen;

