
(function () {
  let scheduled = false;

  function classifyBlock(block) {
    const body = block.querySelector('.body');
    const title = block.querySelector('h2');
    const eyebrow = block.querySelector('.eyebrow');

    let text = '';
    if (body) text += body.innerText || '';
    if (title) text += ' ' + (title.innerText || '');
    if (eyebrow) text += ' ' + (eyebrow.innerText || '');
    text = text.replace(/\s+/g, ' ').trim();

    const pCount = block.querySelectorAll('.body p').length;
    const charCount = text.length;
    const shouldDense = charCount >= 430 || pCount >= 5;

    // Important: only change class if its state actually needs to change.
    if (block.classList.contains('ru-dense') !== shouldDense) {
      block.classList.toggle('ru-dense', shouldDense);
    }
  }

  function applyDensity() {
    scheduled = false;
    document.querySelectorAll('.textOnly').forEach(classifyBlock);
  }

  function scheduleDensity() {
    if (scheduled) return;
    scheduled = true;
    requestAnimationFrame(applyDensity);
  }

  // Initial pass.
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', scheduleDensity, { once: true });
  } else {
    scheduleDensity();
  }

  // Observe only DOM content replacement caused by scene rendering.
  // DO NOT observe class/attribute mutations: that caused recursive callbacks
  // and could starve the autoplay scene timer.
  const mo = new MutationObserver(scheduleDensity);
  mo.observe(document.getElementById('stage') || document.body, {
    childList: true,
    subtree: true
  });
})();
