const fs = require('fs');

const {
  replaceContractAddresses,
  ENV_MAINNET,
  ENV_TESTNET,
} = require('./utils/env');

const {
  listFiles
} = require('./utils/file')

const dir = './transactions'
listFiles(dir, 'cdc', (err, list) => {
  list.forEach((path) => {
    const transaction = fs
      .readFileSync(path)
      .toString();

    const index = path.lastIndexOf("/");
    const project = path.substring(0, index).replace(new RegExp(`^(${dir}/)`, 'g'), '');
    const file = path.substring(index + 1, path.length);

    // mainnet
    try {
      const mainnetScript = replaceContractAddresses(transaction, ENV_MAINNET);
      fs.promises.mkdir(`./build/${project}`, { recursive: true })
        .then(() => {
          fs.writeFileSync(`./build/${project}/${file.replace('.cdc', '.mainnet.cdc')}`, mainnetScript);
        })
        .catch(console.error);
    } catch (_) {
      // ignore
    }

    // testnet
    try {
      const testnetScript = replaceContractAddresses(transaction, ENV_TESTNET);
      fs.promises.mkdir(`./build/${project}`, { recursive: true })
        .then(() => {
          fs.writeFileSync(`./build/${project}/${file.replace('.cdc', '.testnet.cdc')}`, testnetScript);
        })
        .catch(console.error);
    } catch (_) {
      // ignore
    }
  });
});
