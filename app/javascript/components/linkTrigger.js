const linkTrigger = () => {
  const button = document.querySelector('input[type=checkbox');
  const hiddenLink = document.querySelector('.hidden-link');

  button.addEventListener('change', () => {
    hiddenLink.click();
  })
  // console.log('ta mère');
}

export default linkTrigger;
