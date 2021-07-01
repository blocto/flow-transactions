const fs = require('fs');
const { sha3, sha256 } = require('./utils/hash');

const transaction = fs
  .readFileSync(process.argv[2])
  .toString();

console.log(sha3(transaction));
console.log(sha256(transaction))
