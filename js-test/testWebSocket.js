import { Client } from '@stomp/stompjs';
import WebSocket from 'ws';

const getToken = async () => {
  const credentials = {
    email: 'admin@kite.com',
    password: 'password',
  };

  const res = await fetch('http://localhost:8080/kite/api/v1/auth/login', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(credentials),
  });

  const data = await res.json();

  return data.jwtToken;
};

const start = async () => {
  const token = await getToken();
  console.log('Token retrieved successfully!');

  const stompClient = new Client({
    brokerURL: 'ws://localhost:8080/kite/api/v1/ws-connect',
    webSocketFactory: () => new WebSocket('ws://localhost:8080/kite/api/v1/ws-connect'),

    connectHeaders: {
      Authorization: `Bearer ${token}`,
    },

    debug: (str) => console.log('[STOMP]:', str),
    reconnectDelay: 5000,
  });

  stompClient.onConnect = (frame) => {
    console.log('\n====================================');
    console.log('Connected to STOMP Broker!');
    console.log('====================================\n');

    const subscriptionTopic = '/topic/conversations';

    stompClient.subscribe(subscriptionTopic, (message) => {
      console.log('[RECEIVED MESSAGE]:', JSON.parse(message.body));
    });

    console.log(`Subscribed to ${subscriptionTopic}`);

    const recipientId = '22222222-2222-2222-2222-222222222222';

    console.log(`Publishing to /app/direct/${recipientId}...`);
    stompClient.publish({
    destination: `/app/direct/${recipientId}`,
  });
  };

  stompClient.onStompError = (frame) => {
    console.error('STOMP Error:', frame.headers['message']);
    console.error('Details:', frame.body);
  };

  stompClient.activate();
};

start().catch(console.error);
