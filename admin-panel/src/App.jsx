/**
 * App Entry Point - Admin Panel (Web)
 */

import React, { useEffect, useState } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import firebaseService from './services/firebase.service';

// Screens
import LoginScreen from './screens/auth/LoginScreen.jsx';
import DashboardScreen from './screens/dashboard/DashboardScreen.jsx';
import UsersScreen from './screens/users/UsersScreen.jsx';
import UserDetailScreen from './screens/users/UserDetailScreen.jsx';
import FortunesScreen from './screens/fortunes/FortunesScreen.jsx';
import FortuneDetailScreen from './screens/fortunes/FortuneDetailScreen.jsx';
import TestsScreen from './screens/tests/TestsScreen.jsx';
import TestDetailScreen from './screens/tests/TestDetailScreen.jsx';
import ChatsScreen from './screens/chats/ChatsScreen.jsx';
import ChatDetailScreen from './screens/chats/ChatDetailScreen.jsx';
import MatchesScreen from './screens/matches/MatchesScreen.jsx';
import MatchDetailScreen from './screens/matches/MatchDetailScreen.jsx';
import AdminsScreen from './screens/admins/AdminsScreen.jsx';
import StatisticsScreen from './screens/statistics/StatisticsScreen.jsx';
import Layout from './components/Layout.jsx';

const App = () => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsubscribe = firebaseService.onAuthStateChanged(user => {
      setUser(user);
      setLoading(false);
    });

    return unsubscribe;
  }, []);

  if (loading) {
    return (
      <div style={{
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        height: '100vh',
        backgroundColor: '#0A0F2C',
      }}>
        <div style={{ color: '#D26AFF', fontSize: '18px' }}>Yükleniyor...</div>
      </div>
    );
  }

  return (
    <Router
      future={{
        v7_startTransition: true,
        v7_relativeSplatPath: true,
      }}
    >
      <Routes>
        <Route
          path="/login"
          element={user ? <Navigate to="/" replace /> : <LoginScreen />}
        />
        <Route
          path="/"
          element={
            user ? (
              <Layout>
                <DashboardScreen />
              </Layout>
            ) : (
              <Navigate to="/login" replace />
            )
          }
        />
        <Route
          path="/users"
          element={
            user ? (
              <Layout>
                <UsersScreen />
              </Layout>
            ) : (
              <Navigate to="/login" replace />
            )
          }
        />
        <Route
          path="/users/:userId"
          element={
            user ? (
              <Layout>
                <UserDetailScreen />
              </Layout>
            ) : (
              <Navigate to="/login" replace />
            )
          }
        />
        <Route
          path="/fortunes"
          element={
            user ? (
              <Layout>
                <FortunesScreen />
              </Layout>
            ) : (
              <Navigate to="/login" replace />
            )
          }
        />
        <Route
          path="/fortunes/:fortuneId"
          element={
            user ? (
              <Layout>
                <FortuneDetailScreen />
              </Layout>
            ) : (
              <Navigate to="/login" replace />
            )
          }
        />
        <Route
          path="/tests"
          element={
            user ? (
              <Layout>
                <TestsScreen />
              </Layout>
            ) : (
              <Navigate to="/login" replace />
            )
          }
        />
        <Route
          path="/tests/:userId/:collectionType/:testId"
          element={
            user ? (
              <Layout>
                <TestDetailScreen />
              </Layout>
            ) : (
              <Navigate to="/login" replace />
            )
          }
        />
        <Route
          path="/chats"
          element={
            user ? (
              <Layout>
                <ChatsScreen />
              </Layout>
            ) : (
              <Navigate to="/login" replace />
            )
          }
        />
        <Route
          path="/chats/:chatId"
          element={
            user ? (
              <Layout>
                <ChatDetailScreen />
              </Layout>
            ) : (
              <Navigate to="/login" replace />
            )
          }
        />
        <Route
          path="/matches"
          element={
            user ? (
              <Layout>
                <MatchesScreen />
              </Layout>
            ) : (
              <Navigate to="/login" replace />
            )
          }
        />
        <Route
          path="/matches/:matchId"
          element={
            user ? (
              <Layout>
                <MatchDetailScreen />
              </Layout>
            ) : (
              <Navigate to="/login" replace />
            )
          }
        />
        <Route
          path="/admins"
          element={
            user ? (
              <Layout>
                <AdminsScreen />
              </Layout>
            ) : (
              <Navigate to="/login" replace />
            )
          }
        />
        <Route
          path="/statistics"
          element={
            user ? (
              <Layout>
                <StatisticsScreen />
              </Layout>
            ) : (
              <Navigate to="/login" replace />
            )
          }
        />
      </Routes>
    </Router>
  );
};

export default App;

