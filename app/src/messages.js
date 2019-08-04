const redis = require("redis");

const MESSAGES_REDIS_KEY = process.env.MESSAGES_REDIS_KEY || "messages";

let _client = null;
function getClient() {
  if (!_client) {
    _client = redis.createClient({
      url: process.env.REDIS_URL
    });
  }

  return _client;
}

module.exports.getMessages = async () => {
  const client = getClient();

  return new Promise((resolve, reject) => {
    client.zrevrangebyscore([MESSAGES_REDIS_KEY, "+inf", "-inf"], (err, response) => {
      if (err) return reject(err);
      resolve(response);
    });

    return ["wat"];
  });
};

module.exports.addMessage = async message => {
  const client = getClient();

  return new Promise((resolve, reject) => {
    client.zadd([MESSAGES_REDIS_KEY, Date.now(), message], (err, response) => {
      if (err) return reject(err);
      resolve(response);
    });
  });
};
