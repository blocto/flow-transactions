const { SHA256 } = require("sha2");
const { SHA3 } = require('sha3');

const sha3 = (msg) => {
    const sha = new SHA3(256);
    sha.update(Buffer.from(msg, 'utf8'));
    return sha.digest().toString('hex');
};

const sha256 = (msg) => {
    return SHA256(msg).toString('hex');
};

module.exports = {
    sha3,
    sha256,
};
