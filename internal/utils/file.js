const fs = require('fs');

const listFiles = (dir, ext, done) => {
  let results = [];
  fs.readdir(dir, (err, list) => {
    if (err) return done(err);
    let pending = list.length;
    if (!pending) return done(null, results);
    list.forEach(function(file) {
      file = dir + '/' + file;
      fs.stat(file, (err, stat) => {
        if (stat && stat.isDirectory()) {
          listFiles(file, ext, (err, res) => {
            results = results.concat(res);
            if (!--pending) done(null, results);
          });
        } else {
          if (file.endsWith('.' + ext)) {
            results.push(file);
          }
          if (!--pending) done(null, results);
        }
      });
    });
  });
};

module.exports = {
  listFiles,
};
