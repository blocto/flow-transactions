const fs = require('fs');
const { sha3, sha256 } = require('./utils/hash');

const {
  listFiles
} = require('./utils/file')

const dir = './build'
listFiles(dir, 'cdc', (err, list) => {
  list.forEach((path) => {
    const transaction = fs
      .readFileSync(path)
      .toString();

    const scriptSha3 = sha3(transaction);
    const scriptSha256 = sha256(transaction);

    fs.writeFileSync(path.replace('.cdc', '.sha3'), scriptSha3);
    fs.writeFileSync(path.replace('.cdc', '.sha256'), scriptSha256);
  });
});
