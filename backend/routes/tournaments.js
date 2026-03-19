const express = require('express');
const { supabase } = require('../db');
const auth = require('../middleware/auth');
const router = express.Router();

// Get all tournaments
router.get('/', async (req, res) => {
  try {
    const { data: tournaments, error } = await supabase
      .from('tournaments')
      .select('*')
      .order('date', { ascending: false });
    
    if (error) throw error;
    res.json(tournaments);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

// Get tournaments for a specific organizer
router.get('/organizer/:id', async (req, res) => {
  try {
    const { data: tournaments, error } = await supabase
      .from('tournaments')
      .select('*')
      .eq('organizer_id', req.params.id);
    
    if (error) throw error;
    res.json(tournaments);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

// Create a new tournament (Only for Owners)
router.post('/', auth, async (req, res) => {
  const { name, description, sportType, type, entryFormat, entryFee, prizePool, rules, terms, date, location, bannerUrl, organizerId } = req.body;

  try {
    // Check if user is owner
    const { data: user, error: userError } = await supabase
      .from('users')
      .select('active_role')
      .eq('id', req.user.id)
      .single();

    if (userError || user.active_role !== 'owner') {
      return res.status(403).json({ error: 'Permission denied. Only owners can create tournaments.' });
    }

    const { data: tournament, error: insertError } = await supabase
      .from('tournaments')
      .insert([
        { 
          name, 
          description, 
          sport_type: sportType, 
          type, 
          entry_format: entryFormat, 
          entry_fee: entryFee, 
          prize_pool: prizePool, 
          rules, 
          terms, 
          date, 
          location, 
          banner_url: bannerUrl, 
          organizer_id: organizerId, 
          created_by: req.user.id 
        }
      ])
      .select()
      .single();

    if (insertError) throw insertError;
    res.json(tournament);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

// Update a tournament
router.patch('/:id', auth, async (req, res) => {
  const updates = req.body;
  try {
    const { data: tournament, error } = await supabase
      .from('tournaments')
      .update(updates)
      .eq('id', req.params.id)
      .select()
      .single();

    if (error) throw error;
    res.json(tournament);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

// Assign an organizer to a tournament
router.patch('/:id/assign-organizer', auth, async (req, res) => {
  const { organizerId } = req.body;
  try {
    const { data: tournament, error } = await supabase
      .from('tournaments')
      .update({ organizer_id: organizerId })
      .eq('id', req.params.id)
      .select()
      .single();

    if (error) throw error;
    res.json(tournament);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

// Update tournament status
router.patch('/:id/status', auth, async (req, res) => {
  const { status } = req.body;
  try {
    const { data: tournament, error } = await supabase
      .from('tournaments')
      .update({ status })
      .eq('id', req.params.id)
      .select()
      .single();

    if (error) throw error;
    res.json(tournament);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

module.exports = router;
