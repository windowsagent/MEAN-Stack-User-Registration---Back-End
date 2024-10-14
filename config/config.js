// check env.
var env = process.env.NODE_ENV

// fetch env. config
var config = require('./config.json');

// get the envConfig only if NODE_ENV is set and exists in the config
var envConfig = config[env] || {};
console.log(envConfig)

// add env. config values to process.env only if envConfig is not empty
if (Object.keys(envConfig).length > 0) {
  Object.keys(envConfig).forEach(key => {
    process.env[key] = envConfig[key];
  });
} else {
  // If envConfig is empty (i.e. NODE_ENV isn't set), ensure default values are taken from process.env
  process.env.MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/defaultdb';
}

// Export any config-related variables if needed (optional)
module.exports = {
  mongoURI: process.env.MONGO_URI
};
