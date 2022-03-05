import Rails from '../../vendor/rails';
import emitEvent from '../../utils/emit-event';

const ERROR_CLASS = 'has-errors';

class Form {
  constructor(element) {
    this.element = element;
    this.validationUrl = this.element.dataset.validationUrl;
  }

  async findFirstInvalidTab(tabsToValidate) {
    if (!this.validationUrl || tabsToValidate.length === 0) return true;

    [this.currentTab] = tabsToValidate;
    this.tabsToValidate = tabsToValidate;
    let validationEv;
    try {
      validationEv = await this.validateForm();
    } catch (ev) {
      validationEv = ev;
    }
    this.element.validationInProgress = false;
    const firstInvalidTab = this.onComplete(validationEv.detail[0]);
    this.dispatchCompletedEvent();
    return firstInvalidTab;
  }

  dispatchCompletedEvent() {
    emitEvent(this.element, 'validation:complete');
  }

  /**
   * Replaces the form's action and submits it.
   *
   * @returns {Promise<Event>} Resolved if record is valid, rejected otherwise
   */
  validateForm() {
    return new Promise((resolve, reject) => {
      this.attachBeforeSendEvent();
      this.attachAjaxEvents(resolve, reject);
      this.element.validationInProgress = true;
      Rails.fire(this.element, 'submit');
    });
  }

  /**
   * Attaches to SINGLE occurrence of ajax events that indicate if the record is valid or not.
   * Calls resolve or reject accordingly
   *
   * @param resolve
   * @param reject
   */
  attachAjaxEvents(resolve, reject) {
    let success;
    let error;
    const removeAjaxComplete = () => {
      this.element.removeEventListener('ajax:success', success);
      this.element.removeEventListener('ajax:error', error);
    };
    error = (ev) => {
      ev.preventDefault();
      reject(ev);
      removeAjaxComplete();
    };
    success = (ev) => {
      ev.preventDefault();
      resolve(ev);
      removeAjaxComplete();
    };
    this.element.addEventListener('ajax:error', error);
    this.element.addEventListener('ajax:success', success);
  }

  /**
   * Replace form.action directly in XMLHttpRequest
   * This is due to a fact we don't want the record to be persisted, so we must use different endpoint
   */
  attachBeforeSendEvent() {
    const beforeSend = (ev) => {
      const options = ev.detail[1];
      ev.detail[0].open(options.type, this.validationUrl);
      ev.detail[0].setRequestHeader('Accept', options.accept);
      this.element.removeEventListener('ajax:beforeSend', beforeSend);
    };
    this.element.addEventListener('ajax:beforeSend', beforeSend);
  }

  /**
   * Catches the document object from validation response, iterates over all tabs between current and target.
   * Returns first invalid tab index or index of target.
   *
   * @param responseDocument
   * @returns {integer} firstInvalidTab index
   */
  onComplete(responseDocument) {
    let firstInvalidTab = 0;
    const anyInvalid = this.tabsToValidate.some((tab, index) => {
      firstInvalidTab = index;

      return !this.validateTab(tab, responseDocument);
    });

    return anyInvalid ? firstInvalidTab : this.tabsToValidate.length;
  }

  /**
   * Checks if `tab` does not contain any fields with errors on the `responseDocument`
   *
   * @param tab
   * @param responseDocument
   * @returns {boolean}
   */
  validateTab(tab, responseDocument) {
    const tabId = tab.getAttribute('id');
    const responseTab = responseDocument.querySelector(`#${tabId}`);
    if (!responseTab) return false; // it is not valid if something is wrong with the response

    const fieldsWithErrors = responseTab.querySelectorAll(`.${ERROR_CLASS}`);

    if (fieldsWithErrors.length > 0) {
      // eslint-disable-next-line no-param-reassign
      tab.innerHTML = responseTab.innerHTML;
      return false;
    }
    const currentTabErrors = this.currentTab.querySelectorAll(`.${ERROR_CLASS}`);
    currentTabErrors.forEach((field) => field.classList.remove(ERROR_CLASS));

    return true;
  }
}

export default (formNode) => {
  return new Form(formNode);
};
