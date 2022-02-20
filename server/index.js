// const express = require('express');
// const fetch = require('node-fetch');
// const redis = require('redis');
//
// // import express from "express";
// // import * as fetch from "node-fetch";
// // import redis from "redis";
// import { setConfigDAL, getConfigDAL } from "./dal.js";
//
//
//
// const PORT = process.env.PORT || 5000;
// const REDIS_PORT = process.env.REDIS_PORT || 6379;
//
// const client = redis.createClient(REDIS_PORT);
// client.connect();
// client.on("connect", () => {
//     console.log("Connected to Redis...");
// });
//
// const app = express();
// app.use(express.json());
// app.use((req, res, next) => {
//     res.set('Cache-Control', 'no-store');
//     next();
// });
//
// async function setConfig(req, res, next) {
//     const { config_id, config_body } = req.body;
//
//     try {
//         let wrapper = await setConfigDAL(client, config_id, config_body);
//         console.log(wrapper);
//         res.status(200);
//         res.send("OK");
//     } catch(err) {
//         console.log(err);
//         throw err;
//     }
// }
//
// async function getConfig(req, res, next) {
//     const { config_id } = req.body;
//
//     try {
//         let reply = await getConfigDAL(client, config_id);
//         console.log(reply);
//         res.status(200);
//         res.send(reply);
//     } catch(err) {
//         console.log(err);
//         throw err;
//     }
// }
//
// app.post('/config/setConfig', setConfig);
// app.get('/config/getConfig', getConfig);
//
// app.listen(PORT, () => {
//     console.log(`Server listening on ${PORT}`);
// });

//start here
// server.js
const path = require('path');
const express = require('express');
const layout = require('express-layout');
const bodyParser = require('body-parser');
const cookieParser = require('cookie-parser');
const session = require('express-session');
const flash = require('express-flash');
const helmet = require('helmet');

const routes = require('./routes');
const app = express();

app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');

const middlewares = [
  helmet(),
  layout(),
  express.static(path.join(__dirname, 'public')),
  bodyParser.urlencoded({ extended: true }),
  cookieParser(),
  session({
    secret: 'super-secret-key',
    key: 'super-secret-cookie',
    resave: false,
    saveUninitialized: false,
    cookie: { maxAge: 60000 }
  }),
  flash(),
];
app.use(middlewares);

app.use('/', routes);

app.use((req, res, next) => {
  res.status(404).send("Sorry can't find that!");
});

app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send('Something broke!');
});

app.listen(3000, () => {
  console.log('App running at http://localhost:3000');
});
