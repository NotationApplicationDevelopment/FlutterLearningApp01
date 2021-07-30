var timer;
var promise;
var play = false;

function delay(n) {
  const startTime = performance.now();
  const m = Number(n) * 0.001;
  return new Promise(function (resolve) {
    timer = setTimeout(resolve, n / 1000 - 30);
    while ((performance.now() - startTime) < m);
  });
}

async function timerStart(intervalMicroseconds) {
  return promise = new Promise(async function (resolve) {
    if (play == false) {
      play = true;
      while (play) {
        await delay(intervalMicroseconds);
        if (play) {
          postMessage('js:callback');
        }
      }
    }
  });
}

async function timerStop() {
  cleared = false;
  play = false;
  clearInterval(timer);
  await promise;
  promise = null;
}

onmessage = async function (e) {
  var command = e.data['command'];
  var intervalMicroseconds = e.data['intervalMicroseconds'];

  switch (command) {
    case 'start':
      await timerStart(intervalMicroseconds);
      break;

    case 'stop':
      if (play == true) {
        await timerStop();
      }
      break;

    case 'reset':
      if (play == true) {
        await timerStop();
        await timerStart(intervalMicroseconds);
      }
      break;
  }
};