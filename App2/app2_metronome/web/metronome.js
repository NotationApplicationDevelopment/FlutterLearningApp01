function delay(n){
  return new Promise(function(resolve){
      setTimeout(resolve,n);
  });
}

var play = false;

onmessage = async function(e) {
  play = !play;
  while(play){
    await delay(250);
    postMessage('bye');
  }
};