const params = new URLSearchParams(location.search);
const bRelease = 'true' === params.get("bRelease");
if (bRelease) { console.log = function () {} }

console.log('Worker Message: Loaded, bRelease: ', bRelease)

function delayed(ms) {
  return new Promise(resolve => setTimeout(resolve, ms))
}

let _stepCounter = 0
let _bCheckQueensNoAttack = false
let _solutionCounter = 0
let _iWaitms = 0
let _bResumeAfterSolution = false
let _bPause = false
const _iWaitParam = 370000
let _nowPrevious = Date.now()
let _iWaitDelay = 4993

async function _findSolutionWorkerEntryPoint() {

  console.log('Worker Message: start')

  importScripts('stepandcheck.js');   

  console.log('Worker Message: importScript ended')

  onmessage = (msgEvent) => {
    if ('number' === typeof msgEvent.data) {
      _iWaitms = msgEvent.data
      _bResumeAfterSolution = true
    } else if('string' === typeof msgEvent.data) {
      if ('pause' == msgEvent.data) {
        _bPause = true
      } else if ('resume' == msgEvent.data) {
        _bPause = false
        loopStep()
      }
    }
    if (!_bPause) _sendFindSolutionState()
  };

  console.log('Worker Message: onmessage activated')

  loopStep()
}

async function loopStep() {
  while (_stepCounter < ((8 ** 8) - 1) && !_bPause) {
    await nextStep()
  } 
  if (_stepCounter >= (8 ** 8) - 1) {
    console.log('Worker Message: loop ended')
    _sendFindSolutionState()
    postMessage(null)
    close()
  }
}

async function nextStep() {
  await _stepDisplay()
  if (0 == (_stepCounter % _iWaitDelay)) {
    await delayed(0)
    let now = Date.now()
    _iWaitDelay = Math.floor(_iWaitParam / (now - _nowPrevious + 1)) + 17
    _nowPrevious = now
  }
}

function _sendFindSolutionState() {
  postMessage([JSON.stringify(Array.from(liPos)), _stepCounter, _solutionCounter, _bCheckQueensNoAttack])
}

async function _stepDisplay() {
  step()
  _stepCounter++
  _bCheckQueensNoAttack = checkQueensNoAttack()
  if (_bCheckQueensNoAttack) {
    _solutionCounter++
    if (0 < _iWaitms) {
      for (let i = 0; i < 100; i++) {
        await delayed(_iWaitms * 0.01)
        if (_bResumeAfterSolution) break
      }
    }
    _bResumeAfterSolution = false
  }
}

_findSolutionWorkerEntryPoint()
