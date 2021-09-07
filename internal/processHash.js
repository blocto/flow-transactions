const fs = require('fs');
const { sha3, sha256 } = require('./utils/hash');

const transaction = fs
  .readFileSync(process.argv[2])
  .toString();

const scriptSha3 = sha3(transaction);
const scriptSha256 = sha256(transaction);

const result = `sha3   ${scriptSha3}\nsha256 ${scriptSha256}`;

fs.writeFileSync(process.argv[2].replace('.cdc', '.hash'), result);
