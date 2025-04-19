-- Users (Riders/Drivers)
CREATE TABLE Users (
  user_id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  phone VARCHAR(20) NOT NULL,
  user_type VARCHAR(10) CHECK (user_type IN ('rider', 'driver'))
);

-- Drivers (Extends Users)
CREATE TABLE Drivers (
  driver_id INT PRIMARY KEY REFERENCES Users(user_id),
  license_number VARCHAR(50) NOT NULL,
  status VARCHAR(20) CHECK (status IN ('online', 'busy', 'offline', 'suspended'))
);

-- Vehicles
CREATE TABLE Vehicles (
  vehicle_id SERIAL PRIMARY KEY,
  driver_id INT REFERENCES Drivers(driver_id),
  make VARCHAR(50) NOT NULL,
  model VARCHAR(50) NOT NULL,
  color VARCHAR(20),
  plate_number VARCHAR(20) UNIQUE NOT NULL,
  vehicle_type VARCHAR(10) CHECK (vehicle_type IN ('economy', 'premium', 'family'))
);

-- Surge Areas
CREATE TABLE SurgeAreas (
  surge_id SERIAL PRIMARY KEY,
  area_name VARCHAR(255),
  geom GEOMETRY(Polygon, 4326),  -- GeoJSON polygon
  multiplier DECIMAL(3,2) NOT NULL  -- e.g., 1.5x
);

-- Rides
CREATE TABLE Rides (
  ride_id SERIAL PRIMARY KEY,
  rider_id INT REFERENCES Users(user_id),
  driver_id INT REFERENCES Drivers(driver_id),
  pickup_location GEOMETRY(Point, 4326) NOT NULL,
  dropoff_location GEOMETRY(Point, 4326) NOT NULL,
  status VARCHAR(20) CHECK (status IN ('requested', 'accepted', 'in_progress', 'completed', 'cancelled')),
  base_fare DECIMAL(10,2),
  surge_multiplier DECIMAL(3,2) DEFAULT 1.0,
  total_fare DECIMAL(10,2),
  start_time TIMESTAMP,
  end_time TIMESTAMP
);

-- Indexes for Geospatial Queries
CREATE INDEX idx_pickup_location ON Rides USING GIST(pickup_location);
CREATE INDEX idx_driver_status ON Drivers(status);
