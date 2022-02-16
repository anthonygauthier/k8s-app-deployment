import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
    duration: '1m',
    vus: 1,
};

export default function() {
    const res = http.get(`http://${__ENV.API_URL}/automation`);
    
    check(res, {
        'status code 200':                  (r) => r.status === 200,
        'body contains correct message':    (r) => r.body.includes("Automate all the things!"),
    });
}