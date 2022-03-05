import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['errorsTemplate', 'errors', 'formFields', 'messageContainer'];

  signInError(ev) {
    const error = ev.detail[0] && ev.detail[0].error ? ev.detail[0].error : 'Error';
    this.clearErrors();
    this.showError(error);
  }

  signUpError(ev) {
    const result = ev.detail[0];
    this.clearErrors();
    result.errors.forEach((error) => this.showError(error));
  }

  signUpSuccess(ev) {
    const messages = ev.detail[0];
    const allMessages = Object.values(messages).reduce((acc, message) => `${acc}<br>${message}`);
    this.showMessage(allMessages);
  }

  showMessage(message) {
    this.formFieldsTarget.classList.add('hidden');
    this.messageContainerTarget.parentNode.classList.remove('hidden');
    this.messageContainerTarget.innerHTML = message;
  }

  showError(message) {
    const template = this.errorsTemplateTarget.content.cloneNode(true);
    template.querySelector("[data-target='auth.errors']").innerHTML += `${message}<br>`;
    this.formFieldsTarget.insertBefore(template, this.errorsTemplateTarget);
  }

  clearErrors() {
    this.errorsTargets.forEach((container) => this.formFieldsTarget.removeChild(container));
  }
}
