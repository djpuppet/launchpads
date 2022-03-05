import './utils/template-polyfill';
import 'whatwg-fetch';
import 'formdata-polyfill';
import 'core-js/features/url';
import 'core-js/features/url-search-params';
import { Pagy } from './vendor/pagy.js.erb';
import Rails from './vendor/rails';
import Turbolinks from './vendor/turbolinks';
import './vendor/smoothscroll';

import './controllers';

Rails.start();
Turbolinks.start();

document.addEventListener('turbolinks:load', () => {
  Rails.refreshCSRFTokens();
  Pagy.init();
});
