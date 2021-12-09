const config = require('../../config.json');

const ENV_TESTNET = 'testnet';
const ENV_MAINNET = 'mainnet';

const replaceContractAddresses = (script, env = ENV) => {
  if (!script) {
    return script;
  }

  let processedScript = script;

  Object.keys(config).forEach(key => {
    const replacedKey = config[key][env]
    if (!replacedKey) {
      throw new Error("undefined address")
    }
    const keyRegex = new RegExp(key, 'g');
    processedScript = processedScript.replace(keyRegex, replacedKey).trim();
  });

  return processedScript
};

module.exports = {
  ENV_TESTNET,
  ENV_MAINNET,
  replaceContractAddresses,
};
