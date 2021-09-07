const fs = require('fs');
const {
    replaceContractAddresses,
    ENV_MAINNET,
    ENV_TESTNET,
} = require('./utils/env');

const transaction = fs
    .readFileSync(process.argv[2])
    .toString();

const [, , project, file] = process.argv[2].split('/')

const mainnetScript = replaceContractAddresses(transaction, ENV_MAINNET);
const testnetScript = replaceContractAddresses(transaction, ENV_TESTNET);

fs.writeFileSync(`./build/${project}/${file.replace('.cdc', '.mainnet.cdc')}`, mainnetScript);
fs.writeFileSync(`./build/${project}/${file.replace('.cdc', '.testnet.cdc')}`, testnetScript);
