import { useEffect, useState } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';

interface MerchantRequest {
  id: string;
  business_name: string;
  address: string;
  registration_number: string;
  document_url: string;
  status: string;
  user: {
    id: string;
    phone_number: string;
  };
}

export default function Dashboard() {
  const [requests, setRequests] = useState<MerchantRequest[]>([]);
  const navigate = useNavigate();

  const token = localStorage.getItem('admin_token');

  useEffect(() => {
    if (!token) {
      navigate('/login');
      return;
    }
    fetchRequests();
  }, [token, navigate]);

  const fetchRequests = async () => {
    try {
      const res = await axios.get('http://localhost:3000/api/v1/merchants/requests', {
        headers: { Authorization: `Bearer ${token}` }
      });
      setRequests(res.data);
    } catch (err) {
      if (axios.isAxiosError(err) && err.response?.status === 401) {
        localStorage.removeItem('admin_token');
        navigate('/login');
      }
    }
  };

  const handleAction = async (id: string, action: 'approve' | 'reject') => {
    try {
      await axios.post(`http://localhost:3000/api/v1/merchants/requests/${id}/${action}`, {}, {
        headers: { Authorization: `Bearer ${token}` }
      });
      fetchRequests();
    } catch (err) {
      alert(`Failed to ${action} request`);
    }
  };

  const handleLogout = () => {
    localStorage.removeItem('admin_token');
    navigate('/login');
  };

  return (
    <div className="app-container">
      <aside className="sidebar">
        <div className="sidebar-title">Anti-Gaspi Admin</div>
        <a href="#" className="nav-link active">Merchant Onboarding</a>
        <a href="#" className="nav-link">Reports & Disputes</a>
        <a href="#" className="nav-link">Users</a>
        <div style={{ flex: 1 }}></div>
        <button onClick={handleLogout} className="btn btn-outline">Logout</button>
      </aside>
      
      <main className="main-content">
        <header className="page-header">
          <h1 className="page-title">Merchant Applications</h1>
        </header>

        <div className="card">
          <div className="table-container">
            <table>
              <thead>
                <tr>
                  <th>Business Name</th>
                  <th>Applicant Phone</th>
                  <th>Location</th>
                  <th>Reg. Number</th>
                  <th>Status</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {requests.length === 0 ? (
                  <tr>
                    <td colSpan={6} style={{ textAlign: 'center', padding: '2rem', color: 'var(--text-muted)' }}>
                      No pending applications found.
                    </td>
                  </tr>
                ) : (
                  requests.map(req => (
                    <tr key={req.id}>
                      <td style={{ fontWeight: 500 }}>{req.business_name}</td>
                      <td>{req.user.phone_number}</td>
                      <td>{req.address}</td>
                      <td>{req.registration_number || 'N/A'}</td>
                      <td>
                        <span className={`badge badge-${req.status}`}>
                          {req.status}
                        </span>
                      </td>
                      <td>
                        <div style={{ display: 'flex', gap: '0.5rem' }}>
                          <button 
                            className="btn btn-success"
                            onClick={() => handleAction(req.id, 'approve')}
                            disabled={req.status !== 'pending'}
                          >
                            Approve
                          </button>
                          <button 
                            className="btn btn-danger"
                            onClick={() => handleAction(req.id, 'reject')}
                            disabled={req.status !== 'pending'}
                          >
                            Reject
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      </main>
    </div>
  );
}
