/*
 * Insurance Claims Project - Supabase Setup Script
 * ------------------------------------------------
 * This script handles the end-to-end setup for the database:
 * 1. Creates normalised tables (vehicles, policyholders).
 * 2. Transforms and inserts data from the staging table.
 * 3. Creates analytical views for the dashboard.
 * 4. Applies Row Level Security (RLS) policies.
 *
 * PRE-REQUISITE: Import the CSV file into 'stage_claims_raw' table first.
 */

-- ========================================================
-- 1. DATABASE SCHEMA & TABLE CREATION
-- ========================================================

-- Create Vehicles Table (Technical Details)
CREATE TABLE IF NOT EXISTS vehicles (
    vehicle_id       TEXT PRIMARY KEY,
    model            TEXT,
    fuel_type        TEXT,
    engine_type      TEXT,
    displacement     INT,
    cylinder         INT,
    transmission_type TEXT,
    steering_type    TEXT,
    turning_radius   NUMERIC(5,2),
    vehicle_length   INT,
    width            INT,
    gross_weight     INT,
    max_power        TEXT,
    max_torque       TEXT,
    airbags          INT,
    is_esc           BOOLEAN,
    is_tpms          BOOLEAN,
    is_parking_sensors       BOOLEAN,
    is_parking_camera        BOOLEAN,
    is_front_fog_lights      BOOLEAN,
    is_rear_window_wiper     BOOLEAN,
    is_rear_window_washer    BOOLEAN,
    is_rear_window_defogger  BOOLEAN,
    is_brake_assist          BOOLEAN,
    is_power_door_locks      BOOLEAN,
    is_central_locking       BOOLEAN,
    is_power_steering        BOOLEAN,
    is_driver_seat_height_adjustable    BOOLEAN,
    is_day_night_rear_view_mirror       BOOLEAN,
    is_ecw                   BOOLEAN,
    is_speed_alert           BOOLEAN,
    ncap_rating      SMALLINT,
    vehicle_age      NUMERIC(4,1),
    rear_brakes_type TEXT
);

-- Create Policyholders Table (Customer Demographics)
CREATE TABLE IF NOT EXISTS policyholders (
    policyholder_id TEXT PRIMARY KEY,
    customer_age    INT NOT NULL,
    region_code     TEXT NOT NULL,
    region_density  INT,
    segment         TEXT,
    claim_status    BOOLEAN NOT NULL
);

-- ========================================================
-- 2. ETL PROCESS (Extract, Transform, Load)
-- ========================================================

-- Populate Vehicles Table from Staging
INSERT INTO vehicles (
    vehicle_id, model, fuel_type, engine_type, displacement, cylinder,
    transmission_type, steering_type, turning_radius, vehicle_length, width, gross_weight,
    max_power, max_torque, airbags, is_esc, is_tpms, is_parking_sensors, is_parking_camera,
    is_front_fog_lights, is_rear_window_wiper, is_rear_window_washer, is_rear_window_defogger,
    is_brake_assist, is_power_door_locks, is_central_locking, is_power_steering,
    is_driver_seat_height_adjustable, is_day_night_rear_view_mirror, is_ecw, is_speed_alert,
    ncap_rating, vehicle_age, rear_brakes_type
)
SELECT
    policy_id, model, fuel_type, engine_type, displacement, cylinder,
    transmission_type, steering_type, turning_radius, vehicle_length, width, gross_weight,
    max_power, max_torque, airbags, is_esc::boolean, is_tpms::boolean, is_parking_sensors::boolean, is_parking_camera::boolean,
    is_front_fog_lights::boolean, is_rear_window_wiper::boolean, is_rear_window_washer::boolean, is_rear_window_defogger::boolean,
    is_brake_assist::boolean, is_power_door_locks::boolean, is_central_locking::boolean, is_power_steering::boolean,
    is_driver_seat_height_adjustable::boolean, is_day_night_rear_view_mirror::boolean, is_ecw::boolean, is_speed_alert::boolean,
    ncap_rating::integer, vehicle_age::numeric, rear_brakes_type
FROM stage_claims_raw
ON CONFLICT (vehicle_id) DO NOTHING; -- Prevents errors if run multiple times

-- Populate Policyholders Table from Staging
INSERT INTO policyholders (policyholder_id, customer_age, region_code, region_density, segment, claim_status)
SELECT
    policy_id,
    customer_age,
    region_code,
    region_density,
    segment,
    claim_status::boolean
FROM stage_claims_raw
ON CONFLICT (policyholder_id) DO NOTHING;

-- ========================================================
-- 3. ANALYTICAL VIEWS (For Dashboard API)
-- ========================================================

-- View 1: Claims by Region
CREATE OR REPLACE VIEW view_claims_by_region AS
SELECT
  p.region_code,
  COUNT(*) AS total_policies,
  COUNT(*) FILTER (WHERE p.claim_status) AS total_claims,
  ROUND(100.0 * COUNT(*) FILTER (WHERE p.claim_status) / NULLIF(COUNT(*),0), 2) AS claim_rate_pct
FROM policyholders p
GROUP BY p.region_code;

-- View 2: Claims by Age Group
CREATE OR REPLACE VIEW view_claims_by_age_group AS
WITH age_buckets AS (
  SELECT
    CASE
      WHEN p.customer_age < 35 THEN 'Under 35'
      WHEN p.customer_age BETWEEN 35 AND 44 THEN '35-44'
      WHEN p.customer_age BETWEEN 45 AND 54 THEN '45-54'
      WHEN p.customer_age BETWEEN 55 AND 64 THEN '55-64'
      ELSE '65+'
    END AS age_band,
    p.claim_status
  FROM policyholders p
)
SELECT
  age_band,
  COUNT(*) AS total_policies,
  COUNT(*) FILTER (WHERE claim_status) AS total_claims,
  ROUND(100.0 * COUNT(*) FILTER (WHERE claim_status) / NULLIF(COUNT(*),0), 2) AS claim_rate_pct
FROM age_buckets
GROUP BY age_band;

-- View 3: Claims by Safety Features
CREATE OR REPLACE VIEW view_claims_by_safety AS
SELECT
  v.is_esc,
  v.is_parking_sensors,
  COUNT(*) AS total_policies,
  COUNT(*) FILTER (WHERE p.claim_status) AS total_claims,
  ROUND(100.0 * COUNT(*) FILTER (WHERE p.claim_status) / NULLIF(COUNT(*),0), 2) AS claim_rate_pct
FROM policyholders p
JOIN vehicles v ON v.vehicle_id = p.policyholder_id
GROUP BY v.is_esc, v.is_parking_sensors;

-- View 4: Claims by Vehicle Model
CREATE OR REPLACE VIEW view_claims_by_model AS
SELECT
  v.model,
  COUNT(*) AS total_policies,
  COUNT(*) FILTER (WHERE p.claim_status) AS total_claims,
  ROUND(100.0 * COUNT(*) FILTER (WHERE p.claim_status) / NULLIF(COUNT(*),0), 2) AS claim_rate_pct
FROM policyholders p
JOIN vehicles v ON v.vehicle_id = p.policyholder_id
GROUP BY v.model;

-- View 5: Claims by Age, Region, and Fuel
CREATE OR REPLACE VIEW view_claims_by_age_region_fuel AS
WITH base AS (
  SELECT
    CASE
      WHEN p.customer_age < 35 THEN 'Under 35'
      WHEN p.customer_age BETWEEN 35 AND 44 THEN '35-44'
      WHEN p.customer_age BETWEEN 45 AND 54 THEN '45-54'
      WHEN p.customer_age BETWEEN 55 AND 64 THEN '55-64'
      ELSE '65+'
    END AS age_band,
    p.region_code,
    v.fuel_type,
    p.claim_status
  FROM policyholders p
  JOIN vehicles v ON v.vehicle_id = p.policyholder_id
)
SELECT
  age_band,
  region_code,
  fuel_type,
  COUNT(*) AS total_policies,
  COUNT(*) FILTER (WHERE claim_status) AS total_claims,
  ROUND(100.0 * COUNT(*) FILTER (WHERE claim_status) / NULLIF(COUNT(*),0), 2) AS claim_rate_pct
FROM base
GROUP BY age_band, region_code, fuel_type;

-- View 6: Claims by NCAP Rating
CREATE OR REPLACE VIEW view_claims_by_ncap AS
SELECT
  p.policyholder_id AS policy_id,
  v.ncap_rating,
  p.claim_status::INT
FROM policyholders p
JOIN vehicles v ON p.policyholder_id = v.vehicle_id;

-- ========================================================
-- 4. SECURITY & ROW LEVEL SECURITY (RLS)
-- ========================================================

-- Enable RLS on all tables
ALTER TABLE stage_claims_raw ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE policyholders ENABLE ROW LEVEL SECURITY;

-- Create Policies (Public Read Access for main tables only)
DROP POLICY IF EXISTS "Enable read access for all users" ON vehicles;
DROP POLICY IF EXISTS "Enable read access for all users" ON policyholders;

CREATE POLICY "Enable read access for all users" ON vehicles FOR SELECT USING (true);
CREATE POLICY "Enable read access for all users" ON policyholders FOR SELECT USING (true);

-- Note: No policy is created for 'stage_claims_raw', effectively locking it down.

-- Set Views to use Security Invoker
ALTER VIEW view_claims_by_region SET (security_invoker = true);
ALTER VIEW view_claims_by_age_group SET (security_invoker = true);
ALTER VIEW view_claims_by_safety SET (security_invoker = true);
ALTER VIEW view_claims_by_model SET (security_invoker = true);
ALTER VIEW view_claims_by_age_region_fuel SET (security_invoker = true);
ALTER VIEW view_claims_by_ncap SET (security_invoker = true);
