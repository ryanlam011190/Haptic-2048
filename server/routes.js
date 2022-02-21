const express = require('express');
const router = express.Router();
const { check, validationResult, matchedData } = require('express-validator');

const csrf = require('csurf');
const csrfProtection = csrf({ cookie: true });
const axios = require('axios');

const multer = require('multer');
const upload = multer({ storage: multer.memoryStorage() });

router.get('/', (req, res) => {
  res.render('index');
});

router.get('/haptics_configuration', csrfProtection, (req, res) => {
  res.render('haptics_configuration', {
    data: {},
    errors: {},
    csrfToken: req.csrfToken()
  });
});

router.post('/haptics_configuration', upload.single('haptics_file'), csrfProtection, [
  check('instructions')
    .isLength({ min: 1 })
    .withMessage('Instructions are required')
    .trim(),
  check('email')
    .isEmail()
    .withMessage('That email doesn‘t look right')
    .bail()
    .trim()
    .normalizeEmail()
], (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.render('haptics_configuration', {
      data: req.body,
      errors: errors.mapped(),
      csrfToken: req.csrfToken()
    });
  }

  const data = matchedData(req);

  try {
    axios.post("https://haptics-test.herokuapp.com/config/setConfig", {
      "config_id": req.body.email,
      "config_body": {
        "gesture": req.body.gesture,
        "instructions": req.body.instructions,
        "haptic_file": req.file
      }
    });
    req.flash('success', 'Thanks for the haptics configuration!');
  } catch {
    req.flash('error', 'Please try again.');
  }

  //insert generated participant code in message
  res.redirect('/');
});



module.exports = router;
