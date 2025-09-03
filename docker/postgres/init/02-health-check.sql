-- Health check queries for database monitoring
-- These can be used by monitoring tools or health check endpoints

-- Create health check function
CREATE OR REPLACE FUNCTION app.health_check()
RETURNS TABLE (
    status VARCHAR(10),
    database_name VARCHAR(255),
    version TEXT,
    uptime INTERVAL,
    active_connections INTEGER,
    database_size TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        'healthy'::VARCHAR(10) AS status,
        current_database()::VARCHAR(255) AS database_name,
        version() AS version,
        current_timestamp - pg_postmaster_start_time() AS uptime,
        (SELECT count(*) FROM pg_stat_activity)::INTEGER AS active_connections,
        pg_size_pretty(pg_database_size(current_database())) AS database_size;
END;
$$ LANGUAGE plpgsql;

-- Create simple connectivity check
CREATE OR REPLACE FUNCTION app.ping()
RETURNS TEXT AS $$
BEGIN
    RETURN 'pong';
END;
$$ LANGUAGE plpgsql;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION app.health_check() TO PUBLIC;
GRANT EXECUTE ON FUNCTION app.ping() TO PUBLIC;