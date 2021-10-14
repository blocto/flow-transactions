const fs = require('fs');

const listFiles = function(dir, ext, done) {
  let results = [];
  fs.readdir(dir, function(err, list) {
    if (err) return done(err);
    let pending = list.length;
    if (!pending) return done(null, results);
    list.forEach(function(file) {
      file = dir + '/' + file;
      fs.stat(file, function(err, stat) {
        if (stat && stat.isDirectory()) {
          listFiles(file, ext, function(err, res) {
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
