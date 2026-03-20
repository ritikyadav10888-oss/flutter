const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { supabase } = require('../db');
const authMiddleware = require('../middleware/auth');
const { OAuth2Client } = require('google-auth-library');
const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);
const router = express.Router();

// Google Sign-In
router.post('/google', async (req, res) => {
  const { idToken } = req.body;

  try {
    const ticket = await client.verifyIdToken({
      idToken,
      audience: process.env.GOOGLE_CLIENT_ID,
    });
    console.log('Google Payload verified for:', email);
    
    // Check if user exists
    let { data: user, error: fetchError } = await supabase
      .from('users')
      .select('*')
      .eq('email', email)
      .single();

    if (fetchError && fetchError.code !== 'PGRST116') {
      console.error('Fetch User Error during Google Sign-In:', fetchError);
      throw fetchError;
    }

    if (!user) {
      console.log('Creating new Google user:', email);
      // Create new user
      const { data: newUser, error: insertError } = await supabase
        .from('users')
        .insert([
          { 
            email, 
            name, 
            roles: ['player'], 
            active_role: 'player'
          }
        ])
        .select()
        .single();
      
      if (insertError) {
        console.error('Insert User Error during Google Sign-In:', insertError);
        throw insertError;
      }
      user = newUser;

      // Create corresponding player profile for new Google user
      const { error: profileError } = await supabase.from('player_profiles').insert([{ 
        user_id: user.id, 
        profile_pic: picture 
      }]);
      
      if (profileError) {
        console.error('Create Player Profile Error during Google Sign-In:', profileError);
      }
    }

    // Fetch profile based on active role
    let profile = null;
    const roleTable = user.active_role === 'organizer' ? 'organizer_profiles' : 'player_profiles';
    const { data: userProfile, error: profileFetchError } = await supabase
      .from(roleTable)
      .select('*')
      .eq('user_id', user.id)
      .single();
    
    if (profileFetchError && profileFetchError.code !== 'PGRST116') {
      console.error('Fetch Profile Error during Google Sign-In:', profileFetchError);
    }
    profile = userProfile;

    const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, { expiresIn: '7d' });
    res.json({ token, user, profile });
  } catch (err) {
    console.error('Google Sign-In Failure:', err.message);
    res.status(401).json({ error: 'Google Sign-In failed', details: err.message });
  }
});

// Register a new user
router.post('/register', async (req, res) => {
  const { email, password, name, role } = req.body;
  const normalizedRole = (role || 'player').toLowerCase();

  try {
    // Check if user exists
    const { data: existingUser, error: checkError } = await supabase
      .from('users')
      .select('id')
      .eq('email', email)
      .single();

    if (existingUser) {
      return res.status(400).json({ error: 'User already exists' });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Insert user into core table
    const { data: user, error: insertError } = await supabase
      .from('users')
      .insert([
        { 
          email, 
          password: hashedPassword, 
          name, 
          roles: [normalizedRole], 
          active_role: normalizedRole 
        }
      ])
      .select()
      .single();

    if (insertError) {
      console.error('Insert User Error:', insertError);
      throw insertError;
    }

    // Create corresponding profile
    const table = normalizedRole === 'organizer' ? 'organizer_profiles' : 'player_profiles';
    const { error: profileError } = await supabase.from(table).insert([{ user_id: user.id }]);
    
    if (profileError) {
      console.error('Create Profile Error:', profileError);
      throw profileError;
    }

    // Fetch the profile we just created to return it
    const { data: profile } = await supabase.from(table).select('*').eq('user_id', user.id).single();

    // Create token
    const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, { expiresIn: '7d' });

    res.json({ token, user, profile });
  } catch (err) {
    console.error('Registration Error:', err);
    res.status(500).json({ error: 'Server error', details: err.message });
  }
});

// Login user
router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    const { data: user, error: fetchError } = await supabase
      .from('users')
      .select('*')
      .eq('email', email)
      .single();

    if (fetchError || !user) {
      return res.status(400).json({ error: 'Invalid credentials' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ error: 'Invalid credentials' });
    }

    // Fetch profile based on active role
    let profile = null;
    const roleTable = user.active_role === 'organizer' ? 'organizer_profiles' : 'player_profiles';
    const { data: userProfile } = await supabase.from(roleTable).select('*').eq('user_id', user.id).single();
    profile = userProfile;

    const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, { expiresIn: '7d' });

    // Exclude password
    delete user.password;

    res.json({ token, user, profile });
  } catch (err) {
    console.error('Login Error:', err);
    res.status(500).json({ error: 'Server error', details: err.message });
  }
});

// Get current user data
router.get('/me', authMiddleware, async (req, res) => {
  try {
    const { data: user, error } = await supabase
      .from('users')
      .select('*')
      .eq('id', req.user.id)
      .single();

    if (error) throw error;

    // Fetch profile based on active role
    let profile = null;
    const roleTable = user.active_role === 'organizer' ? 'organizer_profiles' : 'player_profiles';
    const { data: userProfile } = await supabase.from(roleTable).select('*').eq('user_id', user.id).single();
    profile = userProfile;

    res.json({ ...user, profile });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: 'Server error', details: err.message });
  }
});

// Get all organizers for an owner
router.get('/organizers', authMiddleware, async (req, res) => {
  try {
    const { data: organizers, error } = await supabase
      .from('users')
      .select('id, email, name, roles, active_role, organizer_profiles(*)')
      .eq('organizer_profiles.owner_id', req.user.id);

    if (error) throw error;
    res.json(organizers);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: 'Server error', details: err.message });
  }
});

// Owner creates an Organizer account
router.post('/create-organizer', authMiddleware, async (req, res) => {
  const { email, password, name, phoneNumber, address, aadharNumber, panNumber, bankName, accountNumber, ifscCode, accessDuration, profilePic, aadharPic, panPic } = req.body;

  try {
    // Check if user is owner
    const { data: owner } = await supabase
      .from('users')
      .select('active_role')
      .eq('id', req.user.id)
      .single();

    if (!owner || owner.active_role !== 'owner') {
      return res.status(403).json({ error: 'Permission denied. Only owners can create organizers.' });
    }

    // Check if user exists
    const { data: existingUser } = await supabase
      .from('users')
      .select('id')
      .eq('email', email)
      .single();

    if (existingUser) {
      return res.status(400).json({ error: 'User with this email already exists' });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // 1. Create User
    const { data: user, error: userError } = await supabase
      .from('users')
      .insert([
        { 
          email, 
          password: hashedPassword, 
          name, 
          roles: ['ORGANIZER'], 
          active_role: 'organizer'
        }
      ])
      .select()
      .single();

    if (userError) throw userError;

    // 2. Create Organizer Profile
    const { error: profileError } = await supabase
      .from('organizer_profiles')
      .insert([
        { 
          user_id: user.id,
          owner_id: req.user.id, 
          phone_number: phoneNumber, 
          address, 
          aadhar_number: aadharNumber, 
          aadhar_pic: aadharPic, 
          pan_number: panNumber, 
          pan_pic: panPic, 
          bank_name: bankName, 
          account_number: accountNumber, 
          ifsc_code: ifscCode, 
          access_duration: accessDuration, 
          profile_pic: profilePic 
        }
      ]);

    if (profileError) throw profileError;
    
    res.json(user);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: 'Server error', details: err.message });
  }
});

// Update a user
router.patch('/users/:id', authMiddleware, async (req, res) => {
  const userId = req.params.id;
  const updates = req.body;

  try {
    const { data: targetUser, error: targetError } = await supabase
        .from('users')
        .select('active_role')
        .eq('id', userId)
        .single();
    
    if (targetError) throw targetError;

    if (req.user.id !== userId) {
      const { data: orgProfile } = await supabase
        .from('organizer_profiles')
        .select('owner_id')
        .eq('user_id', userId)
        .single();
        
      if (!orgProfile || orgProfile.owner_id !== req.user.id) {
        return res.status(403).json({ error: 'Permission denied' });
      }
    }

    const userFields = ['name'];
    const playerFields = ['phone_number', 'profile_pic', 'aadhar_number', 'aadhar_pic', 'is_profile_complete'];
    const organizerFields = ['phone_number', 'profile_pic', 'address', 'aadhar_number', 'aadhar_pic', 'pan_number', 'pan_pic', 'bank_name', 'account_number', 'ifsc_code', 'access_duration'];

    const userUpdates = {};
    const profileUpdates = {};

    Object.keys(updates).forEach(key => {
      if (userFields.includes(key)) userUpdates[key] = updates[key];
      if (targetUser.active_role === 'organizer' && organizerFields.includes(key)) profileUpdates[key] = updates[key];
      if (targetUser.active_role === 'player' && playerFields.includes(key)) profileUpdates[key] = updates[key];
    });

    if (Object.keys(userUpdates).length > 0) {
      await supabase.from('users').update(userUpdates).eq('id', userId);
    }

    if (Object.keys(profileUpdates).length > 0) {
      const table = targetUser.active_role === 'organizer' ? 'organizer_profiles' : 'player_profiles';
      await supabase.from(table).update(profileUpdates).eq('user_id', userId);
    }

    res.json({ message: 'User updated successfully' });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: 'Server error', details: err.message });
  }
});

module.exports = router;
