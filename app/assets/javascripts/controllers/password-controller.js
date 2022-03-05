import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['errors', 'errorsTemplate', 'formFields', 'messageContainer'];

  formError(ev) {
    const errors = ev.detail[0] && ev.detail[0].errors ? ev.detail[0].errors : 'Error changing password';
    this.clearErrors();
    errors.forEach((error) => this.showError(error));
  }

  formSuccess() {
    this.showMessage('Your password has been changed');
  }

  showMessage(message) {
    this.formFieldsTarget.classList.add('hidden');
    this.messageContainerTarget.parentNode.classList.remove('hidden');
    this.messageContainerTarget.innerHTML = message;
  }

  showError(message) {
    const template = this.errorsTemplateTarget.content.cloneNode(true);
    template.querySelector("[data-target='password.errors']").innerHTML += `${message}<br>`;
    this.formFieldsTarget.insertBefore(template, this.errorsTemplateTarget);
  }

  clearErrors() {
    this.errorsTargets.forEach((container) => this.formFieldsTarget.removeChild(container));
  }
}
