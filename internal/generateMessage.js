const fs = require('fs');

const {
  listFiles
} = require('./utils/file')

function parseString(str) {
  return str.replace(/\\r/g, '\r').replace(/\\n/g, '\n').replace(/\\t/g, '\t')
}

const dir = './build'
const exts = ['mainnet.sha3', 'mainnet.sha256', 'testnet.sha3', 'testnet.sha256']
exts.forEach((ext) => {
  listFiles(dir, ext, (err, list) => {
    const hashConfig = {}
    list.forEach((path) => {
      const hash = fs
        .readFileSync(path)
        .toString();
  
      const index = path.lastIndexOf("/");
      const project = path.substring(0, index).replace(new RegExp(`^(${dir}/)`, 'g'), '');
      const file = path.substring(index + 1, path.length);
  
      const configPath = `./transactions/${project}/${file.replace(`.${ext}`, '.json')}`;
      const config = fs
        .readFileSync(configPath)
        .toString();
      hashConfig[hash] = JSON.parse(config);
    });
    const result = JSON.stringify(hashConfig, undefined, 2);
    fs.writeFileSync(`${dir}/messages.${ext}.json`, result);
  });
})