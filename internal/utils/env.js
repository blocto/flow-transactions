const config = require('../../config.json');

const ENV_TESTNET = 'testnet';
const ENV_MAINNET = 'mainnet';

const replaceContractAddresses = (script, env = ENV) => {
  if (!script) {
    return script;
  }

  let processedScript = script;

  Object.keys(config).forEach(key => {
    processedScript = processedScript.replace(key, config[key][env]);
  });

  return processedScript
};

module.exports = {
  ENV_TESTNET,
  ENV_MAINNET,
  replaceContractAddresses,
};
