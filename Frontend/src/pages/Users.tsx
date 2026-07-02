import React from 'react';
import { Users as UsersIcon } from 'lucide-react';

const Users: React.FC = () => {
  return (
    <div className="glass-panel animate-fade-in" style={{ padding: '3rem', textAlign: 'center', color: 'var(--text-secondary)' }}>
      <UsersIcon size={64} style={{ color: 'var(--text-muted)', marginBottom: '1rem' }} />
      <h2>Admins Directory</h2>
      <p style={{ marginTop: '0.5rem' }}>View, invite, or audit active system administrator profiles. (Feature coming soon)</p>
    </div>
  );
};

export default Users;
