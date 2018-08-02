const defaultConfig = require('./default.config');
module.exports = function (env) {
  const envConfig = require(`./${env}.config.js`);
  return Object.assign({},
    defaultConfig,
    envConfig
  );
};
