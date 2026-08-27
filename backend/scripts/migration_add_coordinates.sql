-- Enable PostGIS extension (requires superuser or appropriate privileges)
CREATE EXTENSION IF NOT EXISTS postgis;

-- Add raw decimal coordinate columns
ALTER TABLE markets ADD COLUMN IF NOT EXISTS latitude FLOAT;
ALTER TABLE markets ADD COLUMN IF NOT EXISTS longitude FLOAT;

-- Add spatial Geography column (SRID 4326 is WGS 84, standard for GPS)
ALTER TABLE markets ADD COLUMN IF NOT EXISTS location geography(Point, 4326);

-- Create a GiST index on the location column for fast spatial proximity queries
CREATE INDEX IF NOT EXISTS idx_markets_location ON markets USING GIST (location);
