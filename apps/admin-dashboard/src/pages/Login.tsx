import { useState } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';

export default function Login() {
  const [phoneNumber, setPhoneNumber] = useState('');
  const [otp, setOtp] = useState('');
  const [step, setStep] = useState(1);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const handleRequestOtp = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await axios.post('http://localhost:3000/api/v1/auth/otp/request', {
        phone_number: phoneNumber,
      });
      setStep(2);
      setError('');
    } catch (err) {
      setError('Failed to request OTP');
    }
  };

  const handleVerifyOtp = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const res = await axios.post('http://localhost:3000/api/v1/auth/otp/verify', {
        phone_number: phoneNumber,
        code: otp,
      });
      
      const token = res.data.access_token;
      
      // Get profile to check role
      const profileRes = await axios.get('http://localhost:3000/api/v1/users/me', {
        headers: { Authorization: `Bearer ${token}` }
      });

      if (profileRes.data.role !== 'admin') {
        setError('Access denied: You must be an admin.');
        return;
      }

      localStorage.setItem('admin_token', token);
      navigate('/');
    } catch (err) {
      setError('Invalid OTP or connection error');
    }
  };

  return (
    <div className="login-container">
      <div className="login-card">
        <h1 style={{ textAlign: 'center', marginBottom: '2rem', color: 'var(--primary)' }}>Anti-Gaspi DZ Admin</h1>
        {error && <div style={{ color: 'var(--danger)', marginBottom: '1rem', textAlign: 'center' }}>{error}</div>}
        
        {step === 1 ? (
          <form onSubmit={handleRequestOtp}>
            <div className="form-group">
              <label className="form-label">Phone Number</label>
              <input
                type="text"
                className="form-control"
                value={phoneNumber}
                onChange={(e) => setPhoneNumber(e.target.value)}
                placeholder="+213XXXXXXXXX"
                required
              />
            </div>
            <button type="submit" className="btn btn-primary" style={{ width: '100%' }}>
              Request OTP
            </button>
          </form>
        ) : (
          <form onSubmit={handleVerifyOtp}>
            <div className="form-group">
              <label className="form-label">OTP Code</label>
              <input
                type="text"
                className="form-control"
                value={otp}
                onChange={(e) => setOtp(e.target.value)}
                placeholder="123456"
                required
              />
            </div>
            <button type="submit" className="btn btn-primary" style={{ width: '100%' }}>
              Verify OTP
            </button>
          </form>
        )}
      </div>
    </div>
  );
}
