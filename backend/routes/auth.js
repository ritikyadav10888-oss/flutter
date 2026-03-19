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
    const payload = ticket.getPayload();
    const { email, name, sub: googleId, picture } = payload;

    // Check if user exists
    let { data: user, error: fetchError } = await supabase
      .from('users')
      .select('*')
      .eq('email', email)
      .single();

    if (fetchError && fetchError.code !== 'PGRST116') { // PGRST116 is code for no rows found
      throw fetchError;
    }

    if (!user) {
      // Create new user
      const { data: newUser, error: insertError } = await supabase
        .from('users')
        .insert([
          { 
            email, 
            name, 
            roles: ['PLAYER'], 
            active_role: 'player', 
            profile_pic: picture, 
            is_profile_complete: false 
          }
        ])
        .select()
        .single();
      
      if (insertError) throw insertError;
      user = newUser;
    } else if (!user.profile_pic) {
      // Update profile pic if missing
      const { error: updateError } = await supabase
        .from('users')
        .update({ profile_pic: picture })
        .eq('id', user.id);
      
      if (updateError) throw updateError;
    }

    const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, { expiresIn: '7d' });
    res.json({ token, user });
  } catch (err) {
    console.error('Google Sign-In Error:', err.message);
    res.status(401).json({ error: 'Invalid Google token' });
  }
});

// Register a new user
router.post('/register', async (req, res) => {
  const { email, password, name, role } = req.body;

  try {
    // Check if user exists
    const { data: existingUser } = await supabase
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

    // Insert user into database
    const { data: user, error: insertError } = await supabase
      .from('users')
      .insert([
        { 
          email, 
          password: hashedPassword, 
          name, 
          roles: [role || 'PLAYER'], 
          active_role: role || 'player' 
        }
      ])
      .select('id, email, name, roles, active_role')
      .single();

    if (insertError) throw insertError;

    // Create token
    const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, { expiresIn: '7d' });

    res.json({ token, user });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
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

    const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, { expiresIn: '7d' });

    // Exclude password from response
    delete user.password;

    res.json({ token, user });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

// Get current user data
router.get('/me', authMiddleware, async (req, res) => {
  try {
    const { data: user, error } = await supabase
      .from('users')
      .select('id, email, name, roles, active_role, is_profile_complete, phone_number, profile_pic, aadhar_number, aadhar_pic')
      .eq('id', req.user.id)
      .single();

    if (error) throw error;
    res.json(user);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

// Get all organizers for an owner
router.get('/organizers', authMiddleware, async (req, res) => {
  try {
    const { data: organizers, error } = await supabase
      .from('users')
      .select('id, email, name, roles, active_role, phone_number, profile_pic, address, aadhar_number')
      .eq('owner_id', req.user.id)
      .contains('roles', ['ORGANIZER']);

    if (error) throw error;
    res.json(organizers);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
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

    const { data: user, error: insertError } = await supabase
      .from('users')
      .insert([
        { 
          email, 
          password: hashedPassword, 
          name, 
          roles: ['ORGANIZER'], 
          active_role: 'organizer', 
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
          is_profile_complete: true, 
          profile_pic: profilePic 
        }
      ])
      .select('id, email, name, roles, active_role')
      .single();

    if (insertError) throw insertError;
    res.json(user);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

// Update a user (any user can update themselves, or owner can update their organizers)
router.patch('/users/:id', authMiddleware, async (req, res) => {
  const userId = req.params.id;
  const updates = req.body;

  try {
    // Check authorization: self or owner of organizer
    if (req.user.id !== userId) {
      const { data: targetUser } = await supabase
        .from('users')
        .select('owner_id')
        .eq('id', userId)
        .single();
        
      if (!targetUser || targetUser.owner_id !== req.user.id) {
        return res.status(403).json({ error: 'Permission denied' });
      }
    }

    const { data: user, error: updateError } = await supabase
      .from('users')
      .update(updates)
      .eq('id', userId)
      .select('id, email, name, roles, active_role')
      .single();

    if (updateError) throw updateError;
    res.json(user);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

module.exports = router;
