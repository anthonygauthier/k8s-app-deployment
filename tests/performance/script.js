import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
    duration: '1m',
    vus: 1,
};

function testCase() {
    let res = http.get(`https://${process.env.API_URL}/automation`);

    if(res.error_code) {
        sleep(5)
        testCase();
    }
    
    check(res, {
        'status code 200':                  (r) => r.status === 200,
        'body contains correct message':    (r) => r.body.includes("Automate all the things!"),
    });
}

export default testCase()