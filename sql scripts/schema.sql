CREATE SCHEMA IF NOT EXISTS insurance;

-- Create staging table for raw claims data
CREATE TABLE IF NOT EXISTS insurance.stage_claims_raw (
    policy_id               TEXT PRIMARY KEY,
    subscription_length     NUMERIC,
    vehicle_age             NUMERIC,
    customer_age            INT,
    region_code             TEXT,
    region_density          INT,
    segment                 TEXT,
    model                   TEXT,
    fuel_type               TEXT,
    max_torque              TEXT,
    max_power               TEXT,
    engine_type             TEXT,
    airbags                 INT,
    is_esc                  BOOLEAN,
	is_adjustable_steering	BOOLEAN,
    is_tpms					BOOLEAN,
    is_parking_sensors		BOOLEAN,
    is_parking_camera		BOOLEAN,
    rear_brakes_type		TEXT,
    displacement			INT,
    cylinder				INT,
    transmission_type		TEXT,
    steering_type			TEXT,
    turning_radius			NUMERIC,
    vehicle_length			INT,
    width					INT,
    gross_weight			INT,
    is_front_fog_lights		BOOLEAN,
    is_rear_window_wiper	BOOLEAN,
    is_rear_window_washer	BOOLEAN,
    is_rear_window_defogger	BOOLEAN,
    is_brake_assist			BOOLEAN,
    is_power_door_locks		BOOLEAN,
    is_central_locking		BOOLEAN,
    is_power_steering		BOOLEAN,
    is_driver_seat_height_adjustable 	BOOLEAN,
    is_day_night_rear_view_mirror		BOOLEAN,
    is_ecw					BOOLEAN,
    is_speed_alert			BOOLEAN,
    ncap_rating				INT,
    claim_status			BOOLEAN NOT NULL
);

-- To verify that data is loaded correctly, you can run:
-- SELECT * FROM insurance.stage_claims_raw LIMIT 10;