-- Force Sports Database Schema (Modular)

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Core Users Table (Auth & Common Info)
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    password TEXT, -- Nullable for Google Sign-In
    name TEXT NOT NULL,
    roles TEXT[] DEFAULT '{PLAYER}',
    active_role TEXT DEFAULT 'player',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Player Profiles Table
CREATE TABLE IF NOT EXISTS player_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    phone_number TEXT,
    profile_pic TEXT,
    aadhar_number TEXT,
    aadhar_pic TEXT,
    date_of_birth DATE,
    gender TEXT,
    blood_group TEXT,
    emergency_contact_number TEXT,
    has_health_issues BOOLEAN DEFAULT false,
    health_issue_details TEXT,
    playing_position TEXT,
    is_profile_complete BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Organizer Profiles Table
CREATE TABLE IF NOT EXISTS organizer_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    owner_id UUID REFERENCES users(id) ON DELETE SET NULL,
    phone_number TEXT,
    address TEXT,
    aadhar_number TEXT,
    aadhar_pic TEXT,
    pan_number TEXT,
    pan_pic TEXT,
    bank_name TEXT,
    account_number TEXT,
    ifsc_code TEXT,
    access_duration TEXT,
    is_profile_complete BOOLEAN DEFAULT true,
    profile_pic TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
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
    organizer_id UUID REFERENCES users(id), -- Points to the User ID of the organizer
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
