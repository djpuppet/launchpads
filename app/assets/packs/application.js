import './stylesheets.scss';
import '../javascripts';

const images = require.context('images', true);
const imageLoader = (name) => images(name, true); // eslint-disable-line no-unused-vars

// require('trix');
// require('@rails/actiontext');
