/**
 * Login Screen - Admin Panel (Web)
 */

import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import firebaseService from '../../services/firebase.service';
import './LoginScreen.css';

const LoginScreen = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const handleLogin = async (e) => {
    e.preventDefault();
    if (!email || !password) {
      setError('Lütfen email ve şifre giriniz');
      return;
    }

    setLoading(true);
    setError('');
    try {
      await firebaseService.signInAdmin(email, password);
      navigate('/');
    } catch (err) {
      setError(err.message || 'Giriş yapılamadı');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="login-container">
      <div className="login-card">
        <h1 className="login-title">Falla Admin Panel</h1>
        <p className="login-subtitle">
          Yönetim paneline giriş yapın
        </p>

        <form onSubmit={handleLogin} className="login-form">
          {error && <div className="error-message">{error}</div>}

          <input
            type="email"
            className="login-input"
            placeholder="Email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            disabled={loading}
            required
          />

          <input
            type="password"
            className="login-input"
            placeholder="Şifre"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            disabled={loading}
            required
          />

          <button
            type="submit"
            className="login-button"
            disabled={loading}
          >
            {loading ? 'Giriş yapılıyor...' : 'Giriş Yap'}
          </button>
        </form>
      </div>
    </div>
  );
};

export default LoginScreen;

