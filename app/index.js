const express = require('express');

const app = express();

app.get('/automation', (req, res) => {
    res.send({
        "message": "Automate all the things!",
        "timestamp": new Date().getTime()
    })
});

app.listen(80, (err) => {
    if(err) {
        console.error(err);
    } else {
        console.log('App running on port 80');
    }
});

module.exports = app