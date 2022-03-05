// eslint-disable-next-line consistent-return
(function templatePolyfill(d) {
  if ('content' in d.createElement('template')) {
    return false;
  }

  const qPlates = d.getElementsByTagName('template');
  const plateLen = qPlates.length;
  let elPlate;
  let qContent;
  let docContent;

  // eslint-disable-next-line no-plusplus
  for (let x = 0; x < plateLen; ++x) {
    elPlate = qPlates[x];
    qContent = elPlate.childNodes;
    docContent = d.createDocumentFragment();

    while (qContent[0]) {
      docContent.appendChild(qContent[0]);
    }

    elPlate.content = docContent;
  }
})(document);
