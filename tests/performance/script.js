import http from 'k6/http';
import { check } from 'k6';

export default function() {
    let res = http.get(`https://${process.env.API_URL}.com/login/`);
    check(res, {
        'status code 200':                  (r) => r.status === 200,
        'body contains correct message':    (r) => r.body.includes("Automate all the things!"),
    });
}