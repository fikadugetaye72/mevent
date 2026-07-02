import React from 'react';
import { Settings as SettingsIcon } from 'lucide-react';

const Settings: React.FC = () => {
  return (
    <div className="glass-panel animate-fade-in" style={{ padding: '3rem', textAlign: 'center', color: 'var(--text-secondary)' }}>
      <SettingsIcon size={64} style={{ color: 'var(--text-muted)', marginBottom: '1rem' }} />
      <h2>System Configurations</h2>
      <p style={{ marginTop: '0.5rem' }}>Configure event types, background cron scheduling, and upload file size constraints. (Feature coming soon)</p>
    </div>
  );
};

export default Settings;
