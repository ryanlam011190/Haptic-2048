const express = require('express');
const router = express.Router();
const { check, validationResult, matchedData } = require('express-validator');

const csrf = require('csurf');
const csrfProtection = csrf({ cookie: true });

const multer = require('multer');
const upload = multer({ storage: multer.memoryStorage() });

router.get('/', (req, res) => {
  res.render('index');
});

// router.get('/contact', csrfProtection, (req, res) => {
//   res.render('contact', {
//     data: {},
//     errors: {},
//     csrfToken: req.csrfToken()
//   });
// });

router.get('/haptics_configuration', csrfProtection, (req, res) => {
  res.render('haptics_configuration', {
    data: {},
    errors: {},
    csrfToken: req.csrfToken()
  });
});

// router.post('/contact', upload.single('photo'), csrfProtection, [
//   check('message')
//     .isLength({ min: 1 })
//     .withMessage('Message is required')
//     .trim(),
//   check('email')
//     .isEmail()
//     .withMessage('That email doesn‘t look right')
//     .bail()
//     .trim()
//     .normalizeEmail(),
// ], (req, res) => {
//   const errors = validationResult(req);
//   if (!errors.isEmpty()) {
//     return res.render('contact', {
//       data: req.body,
//       errors: errors.mapped(),
//       csrfToken: req.csrfToken()
//     });
//   }
//
//   const data = matchedData(req);
//   console.log('Sanitized: ', data);
//   //console.log('Gesture: ', req.body.gesture)
//   if (req.file) {
//     console.log('Uploaded: ', req.file);
//   }
//
//   req.flash('success', 'Thanks for the message! I‘ll be in touch :)');
//   res.redirect('/');
// });

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
  console.log(req.body.email);
  console.log(req.body.instructions);
  console.log(req.body.gesture)
  if (req.file) {
    console.log('Uploaded: ', req.file);
  }

  req.flash('success', 'Thanks for the haptics configuration!');
  //insert generated participant code in message
  res.redirect('/');
});



module.exports = router;
