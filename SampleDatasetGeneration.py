from faker import Faker
import psycopg2
from datetime import datetime, timedelta
import random

fake = Faker()

# Connect to PostgreSQL
conn = psycopg2.connect(
    dbname="rideshare",
    user="postgres",
    password="123",
    host="localhost"
)
cur = conn.cursor()

# Generate 50 Riders and Drivers
for _ in range(50):
    name = fake.name()
    email = fake.email()
    phone = fake.phone_number()
    user_type = 'rider' if random.random() > 0.3 else 'driver'
    
    cur.execute(
        "INSERT INTO Users (name, email, phone, user_type) VALUES (%s, %s, %s, %s) RETURNING user_id",
        (name, email, phone, user_type)
    )
    user_id = cur.fetchone()[0]
    
    if user_type == 'driver':
        cur.execute(
            "INSERT INTO Drivers (driver_id, license_number, status) VALUES (%s, %s, %s)",
            (user_id, fake.license_plate(), random.choice(['online', 'offline']))
        )
        # Add a vehicle
        cur.execute(
            "INSERT INTO Vehicles (driver_id, make, model, color, plate_number, vehicle_type) VALUES (%s, %s, %s, %s, %s, %s)",
            (user_id, fake.company(), fake.word(), fake.color_name(), fake.license_plate(), random.choice(['economy', 'premium', 'family']))
        )

# Generate 100 Rides
for _ in range(100):
    rider_id = random.randint(1, 50)
    driver_id = random.randint(1, 25)  # Assume 25 drivers
    pickup_lon = fake.longitude()
    pickup_l_lon = fake.longitude()
    pickup_l
