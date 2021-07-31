var timer;
var promise;
var play = false;

function delayTo(end) {
  return new Promise(function (resolve) {
    const n = end - performance.now();
    timer = setTimeout(resolve, n - 30);
    while (performance.now() < n);
  });
}

async function timerStart(intervalMilliSeconds) {
  if (play == false) {
    return promise = new Promise(async function (resolve) {
      play = true;
      var end = performance.now();
      while (play) {
        end += parseFloat(intervalMilliSeconds);
        await delayTo(end - 200);
        if (play) {
          postMessage(end);
          await delayTo(end);
        }
      }
    });
  }
}

async function timerStop() {
  play = false;
  clearInterval(timer);
  await promise;
  promise = null;
}

onmessage = async function (e) {
  var command = e.data['command'];
  var intervalMilliSeconds = e.data['intervalMilliSeconds'];

  switch (command) {
    case 'start':
      await timerStart(intervalMilliSeconds);
      break;

    case 'stop':
      if (play == true) {
        await timerStop();
      }
      break;

    case 'reset':
      if (play == true) {
        await timerStop();
        await timerStart(intervalMilliSeconds);
      }
      break;
  }
};