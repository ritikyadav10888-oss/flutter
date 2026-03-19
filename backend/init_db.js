const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
  ssl: {
    rejectUnauthorized: false
  }
});

const schema = `
-- Users Table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    password TEXT, -- Nullable for Google Sign-In
    name TEXT NOT NULL,
    roles TEXT[] DEFAULT '{PLAYER}',
    active_role TEXT DEFAULT 'player',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    owner_id UUID REFERENCES users(id),
    phone_number TEXT,
    address TEXT,
    is_profile_complete BOOLEAN DEFAULT false,
    profile_pic TEXT,
    aadhar_number TEXT,
    aadhar_pic TEXT,
    pan_number TEXT,
    pan_pic TEXT,
    bank_name TEXT,
    account_number TEXT,
    ifsc_code TEXT,
    access_duration TEXT
);

-- Tournaments Table
CREATE TABLE IF NOT EXISTS tournaments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    sport_type TEXT NOT NULL,
    type TEXT NOT NULL,
    entry_format TEXT NOT NULL,
    players_per_team INTEGER,
    max_teams INTEGER,
    max_participants INTEGER,
    entry_fee NUMERIC NOT NULL,
    prize_pool NUMERIC NOT NULL,
    rules TEXT[],
    terms TEXT,
    date TIMESTAMP WITH TIME ZONE NOT NULL,
    location TEXT NOT NULL,
    status TEXT DEFAULT 'OPEN',
    banner_url TEXT,
    organizer_id UUID REFERENCES users(id),
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Registrations Table
CREATE TABLE IF NOT EXISTS registrations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tournament_id UUID REFERENCES tournaments(id),
    player_id UUID REFERENCES users(id),
    team_name TEXT,
    team_members TEXT[],
    status TEXT DEFAULT 'PENDING',
    payment_status TEXT DEFAULT 'UNPAID',
    payment_id TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
`;

async function init() {
  try {
    console.log('Connecting to database...');
    await pool.query(schema);
    console.log('Database initialized successfully!');
    process.exit(0);
  } catch (err) {
    console.error('Error initializing database:', err);
    process.exit(1);
  }
}

init();
