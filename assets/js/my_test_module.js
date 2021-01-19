"use strict";

import anime from './anime/3.2.1/anime.es.js';

//const container = document.getElementById('thinger_test');
// anime({
//     targets: '.cpu',
//     keyframes: [
//       {translateY: -40},
//       {translateX: 250},
//       {translateY: 40},
//       {translateX: 0},
//       {translateY: 0}
//     ],
//     duration: 4000,
//     // easing: 'easeOutElastic(1, .8)',
//     delay: anime.stagger(100),
//     loop: true
// });

var frameTl = anime.timeline({
  easing: 'easeInQuad',
  duration: 500,
  direction: 'alternate',
  loop: true,
  delay: anime.stagger(250),
})

frameTl.add({
  targets: '#naive_threaded .waiting_thread',
  backgroundColor: '#000',
  // borderColor: '#000',
  duration: 0,
  translateX: anime.stagger(10),
  translateY: anime.stagger(7),
})
frameTl.add({
  targets: '#naive_threaded .waiting_thread .f1',
  duration: 0,
  opacity: 1,
})
frameTl.add({
  targets: '#naive_threaded .waiting_thread .f2',
  duration: 0,
  opacity: 1,
})
frameTl.add({
  targets: '#naive_threaded .waiting_thread .f3',
  duration: 0,
  opacity: 1,
})
frameTl.add({
  targets: '#naive_threaded .waiting_thread .f4',
  // backgroundColor: '#000',
  // borderColor: '#000',
  duration: 0,
  opacity: 1,
})
frameTl.add({
  targets: '#naive_threaded .cpu .running_thread .f1',
  opacity: 1,
});
frameTl.add({
  targets: '#naive_threaded .cpu .running_thread .f2',
  opacity: 1,
});
frameTl.add({
  targets: '#naive_threaded .cpu .running_thread .f3',
  opacity: 1,
});
frameTl.add({
  targets: '#naive_threaded .cpu .running_thread .f4',
  opacity: 1,
});
frameTl.add({
  targets: '#naive_threaded .running_thread',
  backgroundColor: '#000',
  // borderColor: '#000',
  translateX: anime.stagger([360, 150]),
  translateY: anime.stagger(10),
  duration: 1000,
  easing: 'easeInCubic'
})
frameTl.add({
  targets: '#naive_threaded .waiting_thread',
  backgroundColor: '#fff',
  //borderColor: '#000',
  translateX: anime.stagger([-340, -110]),
  translateY: 0,
  duration: 1000,
  opacity: 1,
   easing: 'easeInCubic'
}, '-=1000');
frameTl.add({
  targets: '#naive_threaded .waiting_thread .f4',
  opacity: 0,
});
frameTl.add({
  targets: '#naive_threaded .waiting_thread .f3',
  opacity: 0,
});
frameTl.add({
  targets: '#naive_threaded .waiting_thread .f2',
  opacity: 0,
});
frameTl.add({
  targets: '#naive_threaded .waiting_thread .f1',
  opacity: 0,
});