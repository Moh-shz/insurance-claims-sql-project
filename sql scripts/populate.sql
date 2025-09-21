-- Drop existing tables if they exist and recreate base tables for vehicles and policyholders
DROP TABLE IF EXISTS insurance.policyholders;
DROP TABLE IF EXISTS insurance.vehicles;

CREATE TABLE insurance.vehicles (
    vehicle_id      TEXT PRIMARY KEY,
    model           TEXT,
    fuel_type       TEXT,
    engine_type     TEXT,
    displacement    INT,
    cylinder        INT,
    transmission_type TEXT,
    steering_type   TEXT,
    turning_radius  NUMERIC(5,2),
    vehicle_length  INT,
    width           INT,
    gross_weight    INT,
    max_power       TEXT,
    max_torque      TEXT,
    airbags         INT,
	is_esc                  BOOLEAN,
    is_tpms                 BOOLEAN,
    is_parking_sensors      BOOLEAN,
    is_parking_camera       BOOLEAN,
	is_front_fog_lights		BOOLEAN,
    is_rear_window_wiper	BOOLEAN,
    is_rear_window_washer	BOOLEAN,
    is_rear_window_defogger	BOOLEAN,
    is_brake_assist         BOOLEAN,
    is_power_door_locks     BOOLEAN,
    is_central_locking      BOOLEAN,
    is_power_steering       BOOLEAN,
    is_driver_seat_height_adjustable 	BOOLEAN,
    is_day_night_rear_view_mirror     	BOOLEAN,
    is_ecw                  BOOLEAN,
    is_speed_alert          BOOLEAN,
    ncap_rating     	SMALLINT,
    vehicle_age     	NUMERIC(4,1),
    rear_brakes_type 	TEXT
);

CREATE TABLE insurance.policyholders (
    policyholder_id TEXT PRIMARY KEY,
    customer_age    INT NOT NULL,
    region_code     TEXT NOT NULL,
    region_density  INT,
    segment         TEXT,
	claim_status	BOOLEAN NOT NULL
);

-- Populate vehicles and policyholders tables from staging table
INSERT INTO insurance.vehicles (
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
    max_power, max_torque, airbags, is_esc, is_tpms, is_parking_sensors, is_parking_camera,
	is_front_fog_lights, is_rear_window_wiper, is_rear_window_washer, is_rear_window_defogger,
    is_brake_assist, is_power_door_locks, is_central_locking, is_power_steering,
	is_driver_seat_height_adjustable, is_day_night_rear_view_mirror, is_ecw, is_speed_alert,
    ncap_rating, vehicle_age, rear_brakes_type
FROM insurance.stage_claims_raw;

INSERT INTO insurance.policyholders (policyholder_id, customer_age, region_code, region_density, segment, claim_status)
SELECT
    policy_id,
    customer_age,
    region_code,
    region_density,
    segment,
	claim_status
FROM insurance.stage_claims_raw;

SELECT * FROM insurance.policyholders LIMIT 10;
SELECT * FROM insurance.vehicles LIMIT 10;