/**
 * Layout Component - Admin Panel (Web)
 */

import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import firebaseService from '../services/firebase.service';
import './Layout.css';

const Layout = ({ children }) => {
  const location = useLocation();

  const handleLogout = async () => {
    try {
      await firebaseService.signOut();
      window.location.href = '/login';
    } catch (error) {
      console.error('Logout error:', error);
    }
  };

  const isActive = path => location.pathname === path;

  return (
    <div className="layout">
      <aside className="sidebar">
        <div className="sidebar-header">
          <h2>Falla Admin</h2>
        </div>
        <nav className="sidebar-nav">
          <Link
            to="/"
            className={`nav-item ${isActive('/') ? 'active' : ''}`}
          >
            <span className="nav-icon">📊</span>
            <span>Dashboard</span>
          </Link>
          <Link
            to="/users"
            className={`nav-item ${isActive('/users') ? 'active' : ''}`}
          >
            <span className="nav-icon">👥</span>
            <span>Kullanıcılar</span>
          </Link>
          <Link
            to="/fortunes"
            className={`nav-item ${isActive('/fortunes') ? 'active' : ''}`}
          >
            <span className="nav-icon">🔮</span>
            <span>Fallar</span>
          </Link>
          <Link
            to="/tests"
            className={`nav-item ${isActive('/tests') ? 'active' : ''}`}
          >
            <span className="nav-icon">📝</span>
            <span>Testler</span>
          </Link>
          <Link
            to="/chats"
            className={`nav-item ${isActive('/chats') ? 'active' : ''}`}
          >
            <span className="nav-icon">💬</span>
            <span>Sohbetler</span>
          </Link>
          <Link
            to="/matches"
            className={`nav-item ${isActive('/matches') ? 'active' : ''}`}
          >
            <span className="nav-icon">💕</span>
            <span>Eşleşmeler</span>
          </Link>
          <Link
            to="/admins"
            className={`nav-item ${isActive('/admins') ? 'active' : ''}`}
          >
            <span className="nav-icon">👑</span>
            <span>Admin'ler</span>
          </Link>
          <Link
            to="/statistics"
            className={`nav-item ${isActive('/statistics') ? 'active' : ''}`}
          >
            <span className="nav-icon">📈</span>
            <span>İstatistikler</span>
          </Link>
        </nav>
        <div className="sidebar-footer">
          <button onClick={handleLogout} className="logout-btn">
            Çıkış Yap
          </button>
        </div>
      </aside>
      <main className="main-content">{children}</main>
    </div>
  );
};

export default Layout;

