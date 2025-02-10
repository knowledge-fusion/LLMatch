-- Table for storing user information
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table for storing device information
CREATE TABLE devices (
    device_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    device_name VARCHAR(100) NOT NULL,
    device_type VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table for storing activity data
CREATE TABLE activities (
    activity_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    device_id INTEGER REFERENCES devices(device_id),
    activity_type VARCHAR(50) NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    calories_burned INTEGER,
    steps INTEGER,
    distance FLOAT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table for storing heart rate data
CREATE TABLE heart_rate (
    heart_rate_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    device_id INTEGER REFERENCES devices(device_id),
    timestamp TIMESTAMP NOT NULL,
    heart_rate INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table for storing sleep data
CREATE TABLE sleep (
    sleep_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    device_id INTEGER REFERENCES devices(device_id),
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    sleep_duration INTEGER,  -- duration in minutes
    sleep_quality VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table for storing body measurements
CREATE TABLE body_measurements (
    measurement_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    device_id INTEGER REFERENCES devices(device_id),
    timestamp TIMESTAMP NOT NULL,
    weight FLOAT,  -- weight in kilograms
    height FLOAT,  -- height in centimeters
    bmi FLOAT,  -- body mass index
    body_fat_percentage FLOAT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table for storing nutrition data
CREATE TABLE nutrition (
    nutrition_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    device_id INTEGER REFERENCES devices(device_id),
    timestamp TIMESTAMP NOT NULL,
    calories_consumed INTEGER,
    protein FLOAT,  -- in grams
    fat FLOAT,  -- in grams
    carbohydrates FLOAT,  -- in grams
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table for storing user goals
CREATE TABLE goals (
    goal_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    goal_type VARCHAR(50) NOT NULL,
    target_value INTEGER NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table for storing user achievements
CREATE TABLE achievements (
    achievement_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    achievement_type VARCHAR(50) NOT NULL,
    value INTEGER NOT NULL,
    achieved_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add comments to users table
COMMENT ON TABLE users IS 'Table for storing user information';
COMMENT ON COLUMN users.user_id IS 'Primary key, unique identifier for each user';
COMMENT ON COLUMN users.username IS 'Unique username for the user';
COMMENT ON COLUMN users.email IS 'Unique email address for the user';
COMMENT ON COLUMN users.password_hash IS 'Hashed password for user authentication';
COMMENT ON COLUMN users.created_at IS 'Timestamp when the user account was created';

-- Add comments to devices table
COMMENT ON TABLE devices IS 'Table for storing device information';
COMMENT ON COLUMN devices.device_id IS 'Primary key, unique identifier for each device';
COMMENT ON COLUMN devices.user_id IS 'Foreign key, references user_id in users table';
COMMENT ON COLUMN devices.device_name IS 'Name of the device';
COMMENT ON COLUMN devices.device_type IS 'Type of the device (e.g., watch, tracker)';
COMMENT ON COLUMN devices.created_at IS 'Timestamp when the device was registered';

-- Add comments to activities table
COMMENT ON TABLE activities IS 'Table for storing activity data';
COMMENT ON COLUMN activities.activity_id IS 'Primary key, unique identifier for each activity';
COMMENT ON COLUMN activities.user_id IS 'Foreign key, references user_id in users table';
COMMENT ON COLUMN activities.device_id IS 'Foreign key, references device_id in devices table';
COMMENT ON COLUMN activities.activity_type IS 'Type of activity (e.g., running, cycling)';
COMMENT ON COLUMN activities.start_time IS 'Timestamp when the activity started';
COMMENT ON COLUMN activities.end_time IS 'Timestamp when the activity ended';
COMMENT ON COLUMN activities.calories_burned IS 'Calories burned during the activity';
COMMENT ON COLUMN activities.steps IS 'Number of steps taken during the activity';
COMMENT ON COLUMN activities.distance IS 'Distance covered during the activity in kilometers';
COMMENT ON COLUMN activities.created_at IS 'Timestamp when the activity was recorded';

-- Add comments to heart_rate table
COMMENT ON TABLE heart_rate IS 'Table for storing heart rate data';
COMMENT ON COLUMN heart_rate.heart_rate_id IS 'Primary key, unique identifier for each heart rate record';
COMMENT ON COLUMN heart_rate.user_id IS 'Foreign key, references user_id in users table';
COMMENT ON COLUMN heart_rate.device_id IS 'Foreign key, references device_id in devices table';
COMMENT ON COLUMN heart_rate.timestamp IS 'Timestamp when the heart rate was recorded';
COMMENT ON COLUMN heart_rate.heart_rate IS 'Heart rate in beats per minute';
COMMENT ON COLUMN heart_rate.created_at IS 'Timestamp when the heart rate record was created';

-- Add comments to sleep table
COMMENT ON TABLE sleep IS 'Table for storing sleep data';
COMMENT ON COLUMN sleep.sleep_id IS 'Primary key, unique identifier for each sleep record';
COMMENT ON COLUMN sleep.user_id IS 'Foreign key, references user_id in users table';
COMMENT ON COLUMN sleep.device_id IS 'Foreign key, references device_id in devices table';
COMMENT ON COLUMN sleep.start_time IS 'Timestamp when the sleep started';
COMMENT ON COLUMN sleep.end_time IS 'Timestamp when the sleep ended';
COMMENT ON COLUMN sleep.sleep_duration IS 'Duration of sleep in minutes';
COMMENT ON COLUMN sleep.sleep_quality IS 'Quality of sleep (e.g., light, deep, REM)';
COMMENT ON COLUMN sleep.created_at IS 'Timestamp when the sleep record was created';

-- Add comments to body_measurements table
COMMENT ON TABLE body_measurements IS 'Table for storing body measurements';
COMMENT ON COLUMN body_measurements.measurement_id IS 'Primary key, unique identifier for each body measurement record';
COMMENT ON COLUMN body_measurements.user_id IS 'Foreign key, references user_id in users table';
COMMENT ON COLUMN body_measurements.device_id IS 'Foreign key, references device_id in devices table';
COMMENT ON COLUMN body_measurements.timestamp IS 'Timestamp when the body measurement was recorded';
COMMENT ON COLUMN body_measurements.weight IS 'Weight in kilograms';
COMMENT ON COLUMN body_measurements.height IS 'Height in centimeters';
COMMENT ON COLUMN body_measurements.bmi IS 'Body mass index';
COMMENT ON COLUMN body_measurements.body_fat_percentage IS 'Body fat percentage';
COMMENT ON COLUMN body_measurements.created_at IS 'Timestamp when the body measurement record was created';

-- Add comments to nutrition table
COMMENT ON TABLE nutrition IS 'Table for storing nutrition data';
COMMENT ON COLUMN nutrition.nutrition_id IS 'Primary key, unique identifier for each nutrition record';
COMMENT ON COLUMN nutrition.user_id IS 'Foreign key, references user_id in users table';
COMMENT ON COLUMN nutrition.device_id IS 'Foreign key, references device_id in devices table';
COMMENT ON COLUMN nutrition.timestamp IS 'Timestamp when the nutrition data was recorded';
COMMENT ON COLUMN nutrition.calories_consumed IS 'Calories consumed';
COMMENT ON COLUMN nutrition.protein IS 'Protein consumed in grams';
COMMENT ON COLUMN nutrition.fat IS 'Fat consumed in grams';
COMMENT ON COLUMN nutrition.carbohydrates IS 'Carbohydrates consumed in grams';
COMMENT ON COLUMN nutrition.created_at IS 'Timestamp when the nutrition record was created';

-- Add comments to goals table
COMMENT ON TABLE goals IS 'Table for storing user goals';
COMMENT ON COLUMN goals.goal_id IS 'Primary key, unique identifier for each goal';
COMMENT ON COLUMN goals.user_id IS 'Foreign key, references user_id in users table';
COMMENT ON COLUMN goals.goal_type IS 'Type of goal (e.g., steps, calories)';
COMMENT ON COLUMN goals.target_value IS 'Target value for the goal';
COMMENT ON COLUMN goals.start_date IS 'Start date for the goal';
COMMENT ON COLUMN goals.end_date IS 'End date for the goal';
COMMENT ON COLUMN goals.created_at IS 'Timestamp when the goal was created';

-- Add comments to achievements table
COMMENT ON TABLE achievements IS 'Table for storing user achievements';
COMMENT ON COLUMN achievements.achievement_id IS 'Primary key, unique identifier for each achievement';
COMMENT ON COLUMN achievements.user_id IS 'Foreign key, references user_id in users table';
COMMENT ON COLUMN achievements.achievement_type IS 'Type of achievement (e.g., daily steps, weekly calories)';
COMMENT ON COLUMN achievements.value IS 'Value achieved';
COMMENT ON COLUMN achievements.achieved_at IS 'Timestamp when the achievement was reached';
COMMENT ON COLUMN achievements.created_at IS 'Timestamp when the achievement record was created';