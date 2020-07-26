import request from 'supertest';
import server from './index';

test('server ', async () => {
  const response = await request(server)
    .get('/')
    .expect('Content-Type', 'text/plain')
    .expect(200);
  expect(response.text).toBe('Hello World');
});
