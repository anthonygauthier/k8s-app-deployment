const { default: axios } = require('axios');
const app = require('../index.js')

app();

describe('App endpoints test', () => {
    it('should return a 200 status code', done => {
        axios('http://localhost:3000/')
            .then(res => {
                expect(res.statusCode).toBe(200)
                done();
            })
    });
});
