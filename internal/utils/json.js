
const recursivelyOrderKeys = (unordered) => {
  // If it's an array - recursively order any
  // dictionary items within the array
  if (Array.isArray(unordered)) {
    unordered.forEach((item, index) => {
      unordered[index] = recursivelyOrderKeys(item);
    });
    return unordered;
  }

  // If it's an object - let's order the keys
  if (typeof unordered === 'object') {
    var ordered = {};
    Object.keys(unordered).sort().forEach((key) => {
      ordered[key] = recursivelyOrderKeys(unordered[key]);
    });
    return ordered;
  }

  return unordered;
};

module.exports = {
  listFiles,
};