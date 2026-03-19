const express = require('express');
const { supabase } = require('../db');
const auth = require('../middleware/auth');
const router = express.Router();

// Register for a tournament
router.post('/', auth, async (req, res) => {
  const { tournamentId, playerName, playerEmail, ownerId } = req.body;

  try {
    const { data: registration, error } = await supabase
      .from('registrations')
      .insert([
        { 
          tournament_id: tournamentId, 
          player_uid: req.user.id, 
          player_name: playerName, 
          player_email: playerEmail, 
          owner_id: ownerId 
        }
      ])
      .select()
      .single();

    if (error) throw error;
    res.json(registration);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

// Get registrations for a tournament
router.get('/tournament/:id', async (req, res) => {
  try {
    const { data: registrations, error } = await supabase
      .from('registrations')
      .select('*')
      .eq('tournament_id', req.params.id);
    
    if (error) throw error;
    res.json(registrations);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

// Get registrations for a player
router.get('/player', auth, async (req, res) => {
  try {
    const { data: registrations, error } = await supabase
      .from('registrations')
      .select('*')
      .eq('player_uid', req.user.id);
    
    if (error) throw error;
    res.json(registrations);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

module.exports = router;
