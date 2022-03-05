export default (element, parent) => {
  if (!element) return false;

  let node = element;
  while (node.parentNode !== null) {
    if (node === parent) {
      return true;
    }
    node = node.parentNode;
  }

  return false;
};
