-- Database initialization script for FastAPI application
-- This script runs automatically when the PostgreSQL container starts

-- Create extensions if they don't exist
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create schemas
CREATE SCHEMA IF NOT EXISTS app;

-- Set default search path
SET search_path TO app, public;

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION app.trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create users table
CREATE TABLE IF NOT EXISTS app.users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    full_name VARCHAR(255),
    hashed_password VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    is_superuser BOOLEAN DEFAULT false,
    is_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP WITH TIME ZONE,
    CONSTRAINT email_valid CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$')
);

-- Create index on email for faster lookups
CREATE INDEX IF NOT EXISTS idx_users_email ON app.users(email);
CREATE INDEX IF NOT EXISTS idx_users_username ON app.users(username);
CREATE INDEX IF NOT EXISTS idx_users_is_active ON app.users(is_active) WHERE is_active = true;

-- Add updated_at trigger to users table
DROP TRIGGER IF EXISTS set_timestamp ON app.users;
CREATE TRIGGER set_timestamp
    BEFORE UPDATE ON app.users
    FOR EACH ROW
    EXECUTE FUNCTION app.trigger_set_timestamp();

-- Create sessions table for user sessions
CREATE TABLE IF NOT EXISTS app.sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
    token VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    ip_address INET,
    user_agent TEXT
);

-- Create index on sessions
CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON app.sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_token ON app.sessions(token);
CREATE INDEX IF NOT EXISTS idx_sessions_expires_at ON app.sessions(expires_at);

-- Add updated_at trigger to sessions table
DROP TRIGGER IF EXISTS set_timestamp ON app.sessions;
CREATE TRIGGER set_timestamp
    BEFORE UPDATE ON app.sessions
    FOR EACH ROW
    EXECUTE FUNCTION app.trigger_set_timestamp();

-- Create items table (example domain model)
CREATE TABLE IF NOT EXISTS app.items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2),
    tax DECIMAL(10, 2),
    owner_id UUID NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create index on items
CREATE INDEX IF NOT EXISTS idx_items_owner_id ON app.items(owner_id);
CREATE INDEX IF NOT EXISTS idx_items_is_active ON app.items(is_active) WHERE is_active = true;

-- Add updated_at trigger to items table
DROP TRIGGER IF EXISTS set_timestamp ON app.items;
CREATE TRIGGER set_timestamp
    BEFORE UPDATE ON app.items
    FOR EACH ROW
    EXECUTE FUNCTION app.trigger_set_timestamp();

-- Create audit log table
CREATE TABLE IF NOT EXISTS app.audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES app.users(id) ON DELETE SET NULL,
    action VARCHAR(50) NOT NULL,
    entity_type VARCHAR(50),
    entity_id UUID,
    changes JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create index on audit logs
CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id ON app.audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_entity ON app.audit_logs(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON app.audit_logs(created_at);

-- Create feature flags table
CREATE TABLE IF NOT EXISTS app.feature_flags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    enabled BOOLEAN DEFAULT false,
    rollout_percentage INTEGER DEFAULT 0 CHECK (rollout_percentage >= 0 AND rollout_percentage <= 100),
    user_whitelist TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Add updated_at trigger to feature flags table
DROP TRIGGER IF EXISTS set_timestamp ON app.feature_flags;
CREATE TRIGGER set_timestamp
    BEFORE UPDATE ON app.feature_flags
    FOR EACH ROW
    EXECUTE FUNCTION app.trigger_set_timestamp();

-- Insert default feature flags
INSERT INTO app.feature_flags (name, description, enabled, rollout_percentage)
VALUES 
    ('user_registration', 'Enable user registration', true, 100),
    ('api_docs', 'Enable API documentation', true, 100),
    ('rate_limiting', 'Enable rate limiting', false, 0),
    ('admin_panel', 'Enable admin panel', false, 0),
    ('metrics', 'Enable metrics collection', false, 0)
ON CONFLICT (name) DO NOTHING;

-- Create a default admin user (password: admin123 - CHANGE IN PRODUCTION!)
-- Password is hashed using bcrypt with salt rounds = 12
INSERT INTO app.users (email, username, full_name, hashed_password, is_active, is_superuser, is_verified)
VALUES (
    'admin@example.com',
    'admin',
    'System Administrator',
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY3pz5G6JXGKzIm',  -- admin123
    true,
    true,
    true
) ON CONFLICT (email) DO NOTHING;

-- Grant permissions to the database user
GRANT USAGE ON SCHEMA app TO CURRENT_USER;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA app TO CURRENT_USER;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA app TO CURRENT_USER;

-- Create read-only role for reporting (optional)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'readonly') THEN
        CREATE ROLE readonly;
    END IF;
END $$;

GRANT USAGE ON SCHEMA app TO readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA app TO readonly;

-- Output confirmation
DO $$
BEGIN
    RAISE NOTICE 'Database initialization completed successfully';
    RAISE NOTICE 'Default admin user created: admin@example.com / admin123';
    RAISE NOTICE 'Remember to change the default password in production!';
END $$;