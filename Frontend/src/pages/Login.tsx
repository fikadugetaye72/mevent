import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { Mail, Lock, User, LogIn } from 'lucide-react';
import api from '../services/api';
import logoImg from '../assets/logo.png';
import './Login.css';

const Login: React.FC = () => {
  const [isRegistering, setIsRegistering] = useState(false);
  const [username, setUsername] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const { login } = useAuth();
  const navigate = useNavigate();

  // Dynamically update browser tab title
  useEffect(() => {
    document.title = `${isRegistering ? 'Register' : 'Login'} | MEvent Admin`;
  }, [isRegistering]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      if (isRegistering) {
        const response = await api.post('/auth/admin/register', { username, email, password });
        login(response.data.token, response.data.user);
      } else {
        const response = await api.post('/auth/admin/login', { email, password });
        login(response.data.token, response.data.user);
        console.log('Login successful', response.data.user);
      }
      navigate('/');
    } catch (err: any) {
      console.error('Authentication error:', err);
      setError(err.response?.data?.message || 'Authentication failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="login-page">
      <div className="login-card glass-panel animate-fade-in">
        <div className="login-header">
          <div className="header-badge">
            <img src={logoImg} alt="MEvent Logo" className="login-logo-img" />
          </div>
          <h2>{isRegistering ? 'Create Admin Account' : 'MEvent Admin Space'}</h2>
          <p>{isRegistering ? 'Sign up a new administrative account' : 'Sign in to access your dashboard'}</p>
        </div>

        {error && <div className="error-alert">{error}</div>}

        <form className="login-form" onSubmit={handleSubmit}>
          {isRegistering && (
            <div className="form-group">
              <label className="form-label" htmlFor="username">Username</label>
              <div className="input-with-icon">
                <User size={18} className="input-icon" />
                <input
                  id="username"
                  type="text"
                  placeholder="admin_user"
                  className="form-control"
                  value={username}
                  onChange={(e) => setUsername(e.target.value)}
                  required
                />
              </div>
            </div>
          )}

          <div className="form-group">
            <label className="form-label" htmlFor="email">Email Address</label>
            <div className="input-with-icon">
              <Mail size={18} className="input-icon" />
              <input
                id="email"
                type="email"
                placeholder="admin@mevent.com"
                className="form-control"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
            </div>
          </div>

          <div className="form-group">
            <label className="form-label" htmlFor="password">Password</label>
            <div className="input-with-icon">
              <Lock size={18} className="input-icon" />
              <input
                id="password"
                type="password"
                placeholder="••••••••"
                className="form-control"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
            </div>
          </div>

          <button type="submit" className="btn btn-primary login-btn" disabled={loading}>
            {loading ? 'Processing...' : (
              <>
                <span>{isRegistering ? 'Create Account' : 'Login Now'}</span>
                <LogIn size={18} />
              </>
            )}
          </button>
        </form>

        <div className="login-footer">
          <button 
            className="toggle-auth-btn" 
            type="button"
            onClick={() => {
              setIsRegistering(!isRegistering);
              setError('');
            }}
          >
            {isRegistering 
              ? 'Already have an admin account? Sign In' 
              : "Need a new administrator account? Register here"}
          </button>
        </div>
      </div>
    </div>
  );
};

export default Login;
