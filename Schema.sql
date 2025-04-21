CREATE TYPE users_role_enum AS ENUM ('rider', 'driver');
CREATE TYPE drivers_status_enum AS ENUM ('online', 'offline', 'busy', 'suspended');
CREATE TYPE riderequests_status_enum AS ENUM ('pending', 'matched', 'cancelled');
CREATE TYPE riderequests_ride_type_enum AS ENUM ('economy', 'premium', 'family');
CREATE TYPE rides_status_enum AS ENUM ('requested', 'accepted', 'in_progress', 'completed', 'cancelled');
CREATE TYPE paymentdetails_payment_status_enum AS ENUM ('pending', 'completed', 'failed');
CREATE TYPE paymentdetails_payment_method_enum AS ENUM ('credit_card', 'debit_card', 'cash');
CREATE TYPE ridehistory_role_enum AS ENUM ('rider', 'driver');
CREATE TYPE ridehistory_action_enum AS ENUM ('requested', 'accepted', 'completed', 'cancelled');
CREATE TYPE vehicletypes_type_name_enum AS ENUM ('economy', 'premium', 'family');

-- Users Table (Base table)
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact_number VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    role users_role_enum NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Riders Table (Extends Users)
CREATE TABLE riders (
    rider_id INT PRIMARY KEY REFERENCES users(user_id) ON DELETE CASCADE,
    payment_method VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Drivers Table (Extends Users)
CREATE TABLE drivers (
    driver_id INT PRIMARY KEY REFERENCES users(user_id) ON DELETE CASCADE,
    status drivers_status_enum DEFAULT 'offline',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Vehicles Table
CREATE TABLE vehicles (
    vehicle_id SERIAL PRIMARY KEY,
    driver_id INT REFERENCES drivers(driver_id) ON DELETE CASCADE,
    make VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    color VARCHAR(50) NOT NULL,
    plate_number VARCHAR(20) UNIQUE NOT NULL,
    license_info VARCHAR(100) NOT NULL,
    type vehicletypes_type_name_enum NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Locations Table
CREATE TABLE locations (
    location_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    latitude DECIMAL(9,6) NOT NULL,
    longitude DECIMAL(9,6) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Ride Requests Table
CREATE TABLE ride_requests (
    request_id SERIAL PRIMARY KEY,
    rider_id INT REFERENCES riders(rider_id) ON DELETE CASCADE,
    pickup_location_id INT REFERENCES locations(location_id) ON DELETE CASCADE,
    dropoff_location_id INT REFERENCES locations(location_id) ON DELETE CASCADE,
    status riderequests_status_enum DEFAULT 'pending',
    ride_type riderequests_ride_type_enum NOT NULL,
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Rides Table
CREATE TABLE rides (
    ride_id SERIAL PRIMARY KEY,
    rider_id INT REFERENCES riders(rider_id) ON DELETE CASCADE,
    driver_id INT REFERENCES drivers(driver_id) ON DELETE SET NULL,
    pickup_location_id INT REFERENCES locations(location_id) ON DELETE CASCADE,
    dropoff_location_id INT REFERENCES locations(location_id) ON DELETE CASCADE,
    status rides_status_enum DEFAULT 'requested',
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    distance DECIMAL(5,2) DEFAULT 0.00,
    duration INT DEFAULT 0,
    price DECIMAL(10,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Payment Details Table
CREATE TABLE payment_details (
    payment_id SERIAL PRIMARY KEY,
    ride_id INT REFERENCES rides(ride_id) ON DELETE CASCADE,
    status paymentdetails_payment_status_enum DEFAULT 'pending',
    method paymentdetails_payment_method_enum NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Ride History Table
CREATE TABLE ride_history (
    history_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    ride_id INT REFERENCES rides(ride_id) ON DELETE CASCADE,
    role ridehistory_role_enum NOT NULL,
    action ridehistory_action_enum NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Ratings Table
CREATE TABLE ratings (
    rating_id SERIAL PRIMARY KEY,
    ride_id INT REFERENCES rides(ride_id) ON DELETE CASCADE,
    rated_by INT REFERENCES users(user_id) ON DELETE CASCADE,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    feedback TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Surge Pricing Table
CREATE TABLE surge_pricing (
    surge_id SERIAL PRIMARY KEY,
    area VARCHAR(100) NOT NULL,
    multiplier DECIMAL(5,2) DEFAULT 1.00,
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP
);
