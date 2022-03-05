import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['carousel', 'slide', 'dot'];

  debouncedResize(callback) {
    if (this.debouncer) return;

    this.debouncer = setTimeout(() => {
      callback();
      this.debouncer = null;
    }, 100);
  }

  connect() {
    this.slidesCount = this.slideTargets.length;
    this.initSlidesImages();
    if (this.slidesCount < 2) {
      this.disableCarousel();
      return;
    }
    this.computedStyles = window.getComputedStyle(this.slideTarget);
    this.prepareClones();
    this.allowTransition = true;
    this.currentSlide = 0;
    this.initCarousel();

    window.addEventListener('resize', () => {
      this.debouncedResize(this.initCarousel.bind(this));
    });
  }

  disableCarousel() {
    this.element.classList.add('disabled');
  }

  initCarousel() {
    [this.initialTransform, this.transitionDuration] = this.getTransformProperties();
    if (this.initialTransform === 'none') this.initialTransform = '';
    this.slideToCurrent();
  }

  initSlidesImages() {
    this.slideTargets.forEach((slide) => {
      if ('imageUrl' in slide.dataset) {
        setTimeout(() => {
          this.replaceSpinner(slide, slide.dataset.imageUrl);
        });
      }
    });
  }

  replaceSpinner(slide, imgSrc) {
    const img = slide.querySelector('img');
    let timeout;
    img.onerror = () => {
      clearTimeout(timeout);
      slide.classList.add('error');
      this.setSlideBackgroundImage(slide, '');
    };
    img.onload = () => {
      clearTimeout(timeout);
      this.setSlideBackgroundImage(slide, `url('${img.src}')`);
    };
    img.src = imgSrc;
    timeout = setTimeout(() => {
      if (img.complete && img.naturalHeight !== 0) {
        this.setSlideBackgroundImage(slide, `url('${img.src}')`);
      }
    }, 200);
  }

  setSlideBackgroundImage(slide, bg) {
    // eslint-disable-next-line no-param-reassign
    slide.style.backgroundImage = bg;
  }

  getTransformProperties() {
    const slide = this.slideTargets[2].cloneNode(true);
    slide.classList.add('transitioning');
    slide.style.visibility = 'hidden';
    slide.style.transform = '';
    this.carouselTarget.appendChild(slide);
    const styles = window.getComputedStyle(slide);
    const duration = parseInt(styles.getPropertyValue('transition-duration'), 10);
    const transform = styles.getPropertyValue('transform');
    this.carouselTarget.removeChild(slide);
    return [transform, duration * 1000];
  }

  onDotClick(ev) {
    ev.preventDefault();

    this.showSlide(parseInt(ev.currentTarget.dataset.photoIndex, 10));
  }

  previousSlide(ev) {
    ev.preventDefault();
    this.showSlide(this.currentSlide - 1);
  }

  nextSlide(ev) {
    ev.preventDefault();
    this.showSlide(this.currentSlide + 1);
  }

  showSlide(index) {
    if (!this.allowTransition) return;
    if (index < -1 || index >= this.slidesCount + 1) return;

    switch (index) {
      case this.slidesCount:
        this.resetPosition(-1);
        this.currentSlide = 0;
        break;
      case -1:
        this.resetPosition(this.slidesCount);
        this.currentSlide = this.slidesCount - 1;
        break;
      default:
        this.currentSlide = index;
    }

    this.slideToCurrent();
  }

  slideToCurrent() {
    const translateBy = this.calculateTranslation(this.currentSlide);
    this.slideTargets.forEach((slide) => {
      this.applyStyles(slide, translateBy);
    });
    this.activateDot();
  }

  resetPosition(toPosition) {
    const translateBy = this.calculateTranslation(toPosition);
    this.slideTargets.forEach((slide) => {
      this.applyStyles(slide, translateBy, false);
    });
  }

  activateDot() {
    if (!this.hasDotTarget) return;
    if (this.currentSlide >= this.dotTargets) return;

    this.dotTargets.forEach((dot, index) => {
      if (index === this.currentSlide) {
        dot.classList.add('active');
      } else {
        dot.classList.remove('active');
      }
    });
  }

  prepareClones() {
    const slides = this.slideTargets.length;
    const clones = [];
    clones[0] = this.slideTargets[0].cloneNode(true);
    clones[1] = this.slideTargets[1].cloneNode(true);
    clones[2] = this.slideTargets[slides - 1].cloneNode(true);
    clones[3] = this.slideTargets[slides - 2].cloneNode(true);
    this.carouselTarget.appendChild(clones[0]);
    this.carouselTarget.appendChild(clones[1]);
    this.carouselTarget.insertBefore(clones[2], this.slideTargets[0]);
    this.carouselTarget.insertBefore(clones[3], this.slideTargets[0]);
  }

  applyStyles(slide, translateBy, transition = true) {
    if (transition) {
      this.allowTransition = false;
      slide.classList.add('transitioning');
      setTimeout(this.endTransition(slide), this.transitionDuration + 100);
    }
    // eslint-disable-next-line no-param-reassign
    slide.style.transform = `${this.initialTransform} translateX(${translateBy}px)`;
  }

  endTransition(slide) {
    return () => {
      slide.classList.remove('transitioning');
      this.allowTransition = true;
    };
  }

  calculateTranslation(position) {
    let slideSize = parseInt(this.computedStyles.getPropertyValue('margin-right'), 10);
    slideSize += this.slideTarget.offsetWidth;
    return slideSize * -position;
  }
}
