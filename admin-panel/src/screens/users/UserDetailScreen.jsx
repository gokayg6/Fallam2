/**
 * User Detail Screen - Admin Panel (Web)
 */

import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Timestamp } from 'firebase/firestore';
import firebaseService from '../../services/firebase.service';
import './UserDetailScreen.css';

const UserDetailScreen = () => {
  const { userId } = useParams();
  const navigate = useNavigate();
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [karmaAmount, setKarmaAmount] = useState('');
  const [karmaReason, setKarmaReason] = useState('');
  const [isEditing, setIsEditing] = useState(false);
  const [editData, setEditData] = useState({
    name: '',
    email: '',
    zodiacSign: '',
    birthDate: '',
    isPremium: false,
  });

  useEffect(() => {
    loadUser();
  }, [userId]);

  const loadUser = async () => {
    setLoading(true);
    try {
      const userData = await firebaseService.getUserById(userId);
      setUser(userData);
      setEditData({
        name: userData.name || '',
        email: userData.email || '',
        zodiacSign: userData.zodiacSign || '',
        birthDate: userData.birthDate ? formatDateForInput(userData.birthDate) : '',
        isPremium: userData.isPremium || false,
      });
    } catch (error) {
      alert('Kullanıcı bilgileri yüklenemedi');
      navigate('/users');
    } finally {
      setLoading(false);
    }
  };

  const formatDateForInput = (timestamp) => {
    if (!timestamp) return '';
    const date = timestamp.toDate ? timestamp.toDate() : new Date(timestamp);
    return date.toISOString().split('T')[0];
  };

  const handleSaveEdit = async () => {
    if (!confirm('Kullanıcı bilgileri güncellenecek. Devam edilsin mi?')) {
      return;
    }

    try {
      const updateData = {
        name: editData.name,
        email: editData.email,
        zodiacSign: editData.zodiacSign || null,
        isPremium: editData.isPremium,
      };

      if (editData.birthDate) {
        updateData.birthDate = Timestamp.fromDate(new Date(editData.birthDate));
      }

      await firebaseService.updateUser(userId, updateData);
      alert('Kullanıcı bilgileri güncellendi');
      setIsEditing(false);
      loadUser();
    } catch (error) {
      alert('Kullanıcı bilgileri güncellenemedi: ' + error.message);
    }
  };

  const handleUpdateKarma = async () => {
    if (!karmaAmount) {
      alert('Lütfen karma miktarı giriniz');
      return;
    }

    const amount = parseInt(karmaAmount, 10);
    if (isNaN(amount)) {
      alert('Geçerli bir sayı giriniz');
      return;
    }

    if (
      !confirm(
        `${amount > 0 ? '+' : ''}${amount} karma ${user.name} kullanıcısına eklenecek. Devam edilsin mi?`,
      )
    ) {
      return;
    }

    try {
      await firebaseService.updateUserKarma(
        userId,
        amount,
        karmaReason || 'Admin tarafından güncellendi',
      );
      alert('Karma puanı güncellendi');
      setKarmaAmount('');
      setKarmaReason('');
      loadUser();
    } catch (error) {
      alert('Karma güncellenemedi');
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

  if (loading) {
    return (
      <div className="user-detail-container">
        <div className="loading">Yükleniyor...</div>
      </div>
    );
  }

  if (!user) {
    return null;
  }

  return (
    <div className="user-detail-container">
      <div className="user-detail-header">
        <div className="user-header-content">
          <div className="user-avatar">👤</div>
          <div className="user-header-info">
            <h1 className="user-detail-name">{user.name || 'İsimsiz'}</h1>
            <p className="user-detail-email">{user.email || 'Email yok'}</p>
          </div>
        </div>
      </div>

      <div className="user-detail-section">
        <div className="section-header">
          <h2 className="section-title">Genel Bilgiler</h2>
          <button
            className="edit-button"
            onClick={() => {
              if (isEditing) {
                setIsEditing(false);
                setEditData({
                  name: user.name || '',
                  email: user.email || '',
                  zodiacSign: user.zodiacSign || '',
                  birthDate: user.birthDate ? formatDateForInput(user.birthDate) : '',
                  isPremium: user.isPremium || false,
                });
              } else {
                setIsEditing(true);
              }
            }}
          >
            {isEditing ? 'İptal' : 'Düzenle'}
          </button>
        </div>
        {isEditing ? (
          <div className="edit-form">
            <div className="edit-field">
              <label className="edit-label">İsim</label>
              <input
                type="text"
                className="edit-input"
                value={editData.name}
                onChange={(e) => setEditData({ ...editData, name: e.target.value })}
              />
            </div>
            <div className="edit-field">
              <label className="edit-label">Email</label>
              <input
                type="email"
                className="edit-input"
                value={editData.email}
                onChange={(e) => setEditData({ ...editData, email: e.target.value })}
              />
            </div>
            <div className="edit-field">
              <label className="edit-label">Burç</label>
              <input
                type="text"
                className="edit-input"
                value={editData.zodiacSign}
                onChange={(e) => setEditData({ ...editData, zodiacSign: e.target.value })}
                placeholder="Örn: Koç, Boğa..."
              />
            </div>
            <div className="edit-field">
              <label className="edit-label">Doğum Tarihi</label>
              <input
                type="date"
                className="edit-input"
                value={editData.birthDate}
                onChange={(e) => setEditData({ ...editData, birthDate: e.target.value })}
              />
            </div>
            <div className="edit-field">
              <label className="edit-label">
                <input
                  type="checkbox"
                  checked={editData.isPremium}
                  onChange={(e) => setEditData({ ...editData, isPremium: e.target.checked })}
                />
                <span style={{ marginLeft: '8px' }}>Premium Kullanıcı</span>
              </label>
            </div>
            <button className="save-button" onClick={handleSaveEdit}>
              Kaydet
            </button>
          </div>
        ) : (
          <div className="info-grid">
            <InfoRow label="Karma" value={user.karma || 0} />
            <InfoRow label="Premium" value={user.isPremium ? 'Evet' : 'Hayır'} />
            <InfoRow label="Burç" value={user.zodiacSign || 'Belirtilmemiş'} />
            <InfoRow label="Doğum Tarihi" value={formatDate(user.birthDate)} />
            <InfoRow label="Kayıt Tarihi" value={formatDate(user.createdAt)} />
            <InfoRow label="Son Giriş" value={formatDate(user.lastLoginAt)} />
          </div>
        )}
      </div>

      <div className="user-detail-section">
        <h2 className="section-title">İstatistikler</h2>
        <div className="info-grid">
          <InfoRow label="Toplam Fal" value={user.totalFortunes || 0} />
          <InfoRow label="Toplam Test" value={user.totalTests || 0} />
          <InfoRow
            label="Günlük Fal Kullanımı"
            value={user.dailyFortunesUsed || 0}
          />
        </div>
      </div>

      <div className="user-detail-section">
        <h2 className="section-title">Karma Yönetimi</h2>
        <div className="karma-form">
          <input
            type="number"
            className="karma-input"
            placeholder="Karma miktarı (+/-)"
            value={karmaAmount}
            onChange={(e) => setKarmaAmount(e.target.value)}
          />
          <textarea
            className="karma-textarea"
            placeholder="Sebep (opsiyonel)"
            value={karmaReason}
            onChange={(e) => setKarmaReason(e.target.value)}
            rows={3}
          />
          <button className="karma-button" onClick={handleUpdateKarma}>
            Karma Güncelle
          </button>
        </div>
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

export default UserDetailScreen;

