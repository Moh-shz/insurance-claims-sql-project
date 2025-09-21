-- Policies, Claims, and Claim Rate by Region
SELECT
  p.region_code,
  COUNT(*)                                         AS total_policies,
  COUNT(*) FILTER (WHERE p.claim_status)           AS total_claims,
  ROUND(100.0 * COUNT(*) FILTER (WHERE p.claim_status) / NULLIF(COUNT(*),0), 2) AS claim_rate_pct
FROM insurance.policyholders p
GROUP BY p.region_code
ORDER BY claim_rate_pct DESC NULLS LAST, total_claims DESC;

-- Policies, Claims, and Claim Rate by Age Group 
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
  FROM insurance.policyholders p
  JOIN insurance.vehicles v
    ON v.vehicle_id = p.policyholder_id
)
SELECT
  age_band,
  COUNT(*)                                       AS total_policies,
  COUNT(*) FILTER (WHERE claim_status)           AS total_claims,
  ROUND(100.0 * COUNT(*) FILTER (WHERE claim_status) / NULLIF(COUNT(*),0), 2) AS claim_rate_pct
FROM age_buckets
GROUP BY age_band
ORDER BY
  CASE age_band
    WHEN 'Under 35' THEN 1
    WHEN '35-44' THEN 2
    WHEN '45-54' THEN 3
    WHEN '55-64' THEN 4
    ELSE 5
  END;

-- Policies, Claims, and Claim Rate by Safety Features (ESC, Parking Sensors)
SELECT
  v.is_esc,
  v.is_parking_sensors,
  COUNT(*)                                       AS total_policies,
  COUNT(*) FILTER (WHERE p.claim_status)         AS total_claims,
  ROUND(100.0 * COUNT(*) FILTER (WHERE p.claim_status) / NULLIF(COUNT(*),0), 2) AS claim_rate_pct
FROM insurance.policyholders p
JOIN insurance.vehicles v
  ON v.vehicle_id = p.policyholder_id
GROUP BY v.is_esc, v.is_parking_sensors
ORDER BY v.is_esc DESC, v.is_parking_sensors DESC;

-- Policies, Claims, and Claim Rate by Vehicle Model (sorted by total claims)
SELECT
  v.model,
  COUNT(*)                                 AS total_policies,
  COUNT(*) FILTER (WHERE p.claim_status)   AS total_claims,
  ROUND(100.0 * COUNT(*) FILTER (WHERE p.claim_status) / NULLIF(COUNT(*),0), 2) AS claim_rate_pct
FROM insurance.policyholders p
JOIN insurance.vehicles v
  ON v.vehicle_id = p.policyholder_id
GROUP BY v.model
ORDER BY total_claims DESC, claim_rate_pct DESC;

-- Policies, Claims, and Claim Rate by Age × Region × Fuel Type
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
  FROM insurance.policyholders p
  JOIN insurance.vehicles v
    ON v.vehicle_id = p.policyholder_id
)
SELECT
  age_band,
  region_code,
  fuel_type,
  COUNT(*)                                       AS total_policies,
  COUNT(*) FILTER (WHERE claim_status)           AS total_claims,
  ROUND(100.0 * COUNT(*) FILTER (WHERE claim_status) / NULLIF(COUNT(*),0), 2) AS claim_rate_pct
FROM base
GROUP BY age_band, region_code, fuel_type
ORDER BY claim_rate_pct DESC NULLS LAST, total_policies DESC;