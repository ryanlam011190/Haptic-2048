const express = require('express');
const router = express.Router();
const { check, validationResult, matchedData } = require('express-validator');

const csrf = require('csurf');
const csrfProtection = csrf({ cookie: true });
const axios = require('axios');

const multer  = require('multer');
const multers3 = require('multer-s3');
const AWS = require('aws-sdk');
const S3_BUCKET = "hapticsuseruploads";
AWS.config.region = 'us-west-1';

const s3 = new AWS.S3({
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
});

const uploadS3 = multer({
  storage: multers3({
    s3: s3,
    acl: 'public-read',
    bucket: S3_BUCKET,
    metadata: (req, file, cb) => {
      cb(null, {fieldName: file.fieldname})
    },
    key: (req, file, cb) => {
      cb(null, Date.now().toString() + '-' + file.originalname)
    }
  })
});

const nodemailer = require("nodemailer");

router.get('/', csrfProtection, (req, res) => {
  res.render('google-sign-in', {
    data: {},
    errors: {},
    csrfToken: req.csrfToken()
  });
});

router.get('/index', csrfProtection, (req, res) => {
  res.render('index', {
    data: { "email": req.query.email },
    errors: {},
    csrfToken: req.csrfToken()
  });
});

router.post('/haptics_configuration', uploadS3.array('file', 3), csrfProtection, (req, res) => {
  const data = matchedData(req);
  // console.log(req.files)
  // console.log(req.file.location);
  try {
    axios.post("https://haptics-test.herokuapp.com/config/setConfig", {
      "config_body": {
        "gesture": req.body.gesture,
        "instructions": req.body.instructions,
        "long_haptics_file": req.files[0].location,
        "short_haptics_file": req.files[1].location,
        "user_instructions_image": req.files[2].location,
        "survey_link": req.body.survey_link,
        "max_score": req.body.max_score,
      },
      "max_score": req.body.max_score,
    }).then( response => {
      console.log(req.body.email);
      console.log("CONFIG_ID = " + response.data);
      sendEmail(req.body.email, response.data + "");
    });
  } catch {
    req.flash('error', 'Please try again.');
  }
  res.redirect('/');
});

async function sendEmail(email, config_id) {
  var transporter = nodemailer.createTransport({
    service: 'gmail',
    // auth: {
    //   user: 'hapticstestplatform@gmail.com',
    //   pass: 'csci401!'
    // }
    auth: {
      type: 'OAuth2',
      user: 'hapticstestplatform@gmail.com',
      clientId: '837020197744-174sc7k0ibsbmqt5ahg1emt8pc7pu513.apps.googleusercontent.com',
      clientSecret: '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',
      refreshToken: '1//04b3ySiYrt9CWCgYIARAAGAQSNwF-L9IrmfB2O28zuF2Ab9K4Ewhbhc8gV8cepCYF7ozFGeeWL7XgV5uend5Hm3KJLSLtWM-W9hs',
      accessToken: 'ya29.A0ARrdaM8K5p9HfGieOEOSnpIw3rF5C3DioQ3A6D6k6WSO4QJg_OjNieAWwB7rNyOtk4t7W3fE6vOuq21wdtaPAx5fjrknZpMBNDxJOhLYwPOX6Y6Nwi6bLFRW231OUP4H188pbjDKt7OOBR7tbpwmpq0Ykbif',
      expires: 12345
  },
  });

  var mailOptions = {
    from: 'hapticstestplatform@gmail.com',
    to: email,
    subject: 'Config ID',
    text: "Thanks for using the haptics test platform! Your experiment id is " + config_id
  };

  transporter.sendMail(mailOptions, function(error, info){
    if (error) {
      console.log(error);
    } else {
      console.log('Email sent: ' + info.response);
    }
  });
}


module.exports = router;
