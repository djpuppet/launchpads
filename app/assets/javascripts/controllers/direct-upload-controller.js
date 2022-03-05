import { Controller } from 'stimulus';
import { DirectUpload } from '@rails/activestorage/src/direct_upload';
import Rails from '../vendor/rails';

export default class extends Controller {
  static targets = ['files', 'file', 'input'];

  connect() {
    this.showPreview = this.showPreview.bind(this);
    this.controllers = [];
    this.directUploadUrl = this.inputTarget.dataset.directUploadUrl;
    const submitButtons = this.element.querySelectorAll('input[type="submit"]');
    this.submitButton = submitButtons[submitButtons.length - 1];
  }

  start(ev) {
    if (ev.target.validationInProgress) return;
    if (this.data.get('complete') === 'true') {
      return;
    }
    ev.stopPropagation();
    ev.preventDefault();

    this.disableInput(this.submitButton);
    this.inputTargets.forEach(this.disableInput);
    const uploads = this.controllers.map((controller) => this.startController(controller));
    Promise.all(uploads)
      .then(() => {
        this.enableInput(this.submitButton);
        this.inputTargets.forEach(this.enableInput);
        this.data.set('complete', 'true');
        Rails.fire(ev.target, 'submit');
      })
      .catch(() => {
        this.enableInput(this.submitButton);
        this.inputTargets.forEach(this.enableInput);
      });
  }

  inputChange(ev) {
    this.controllers = [
      ...this.controllers,
      ...Array.from(ev.currentTarget.files).map((file) => new DirectUpload(file, this.directUploadUrl)),
    ];
    this.data.set('complete', 'false');
    // eslint-disable-next-line no-param-reassign
    ev.currentTarget.value = '';
    this.updatePreview();
  }

  uploadError(ev) {
    ev.preventDefault();
    const item = Array.from(this.fileTargets).find((row) => row.id === ev.detail.id);

    if (!item) return;

    item.classList.add('error');
  }

  removeFile(ev) {
    ev.preventDefault();
    const fileItem = ev.currentTarget.parentNode;
    if (fileItem.uploadId) {
      this.removeControllerByIndex(this.findControllerByUploadId(fileItem.uploadId));
    } else {
      this.filesTarget.removeChild(fileItem);
    }
    this.updatePreview();
  }

  removeControllerByIndex(index) {
    if (index > -1) {
      this.controllers.splice(index, 1);
    }
  }

  findControllerByUploadId(id) {
    return this.controllers.findIndex((controller) => controller.id === id);
  }

  startController(controller) {
    return new Promise((resolve, reject) => {
      controller.create((error, blob) => {
        if (error) {
          reject(error);
        } else {
          this.setBlobId(controller.id, blob.signed_id);
          resolve(blob);
        }
      });
    });
  }

  updatePreview() {
    if (this.hasFileTarget) {
      this.fileTargets.forEach((file) => {
        if (file.querySelector(`[data-controller-id]`)) {
          this.filesTarget.removeChild(file);
        }
      });
    }
    this.controllers.forEach(this.showPreview);
  }

  showPreview(controller) {
    const item = document.createElement('li');
    item.dataset.target = 'direct-upload.file';
    item.innerHTML = '<a href="#" data-action="direct-upload#removeFile">Delete</a>';
    item.uploadId = controller.id;
    this.readFile(controller.file).then((image) => {
      item.style.backgroundImage = `url('${image}')`;
    });
    this.addHiddenInput(item, controller.id);
    this.filesTarget.appendChild(item);
  }

  readFile(file) {
    return new Promise((resolve) => {
      const reader = new FileReader();
      reader.onload = () => {
        resolve(reader.result);
      };
      reader.readAsDataURL(file);
    });
  }

  disableInput(input) {
    if (!input) return;

    // eslint-disable-next-line no-param-reassign
    input.disabled = true;
    input.parentNode.setAttribute('disabled', 'disabled');
  }

  enableInput(input) {
    if (!input) return;

    // eslint-disable-next-line no-param-reassign
    input.disabled = false;
    input.parentNode.removeAttribute('disabled');
  }

  addHiddenInput(item, controllerId) {
    const hiddenInput = document.createElement('input');
    hiddenInput.type = 'hidden';
    hiddenInput.name = this.inputTarget.name;
    hiddenInput.setAttribute('data-controller-id', controllerId);
    item.appendChild(hiddenInput);
  }

  setBlobId(controllerId, blobId) {
    const input = this.element.querySelector(`[data-controller-id="${controllerId}"]`);

    if (input) {
      input.value = blobId;
    }
  }
}
