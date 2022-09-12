console.log('Multithreaded Worker Message: First line')

async function delayed(ms) {
  return await new Promise(resolve => setTimeout(resolve, ms))
}

let _nThreads = 0
let _threadNo = 0
let _stepCounter = 0
let _nSubSteps = 0
let _bCheckQueensNoAttack = false
let _solutionCounter = 0
let _iWaitms = 0
let _bResumeAfterSolution = false
let _bPause = false
const _iWaitParam = 370000
let _nowPrevious = Date.now()
let _iWaitDelay = 4993

async function _multithreadedFindSolutionWorkerEntryPoint() {

  console.log('Multithreaded Worker Message: start')

  importScripts('stepandcheck.js');   

  console.log('Multithreaded Worker Message: importScript ended')

  onmessage = async (msgEvent) => {
    if ('init' === msgEvent.data.type) {
      _nThreads = msgEvent.data.content[0]
      _threadNo = msgEvent.data.content[1]
      _iWaitms  = msgEvent.data.content[2]
      _bResumeAfterSolution = true
      console.log('Multithreaded Worker Message: onmessage init, _threadNo: ' + _threadNo)
      await _initVariables()
      _loopStep()
    } else if('msg' === msgEvent.data.type) {
      _iWaitms      = msgEvent.data.content[0]
      _bResumeAfterSolution = true
      //console.log('Multithreaded Worker Message: onmessage msg, _threadNo: ' + _threadNo)
    } else if('control' === msgEvent.data.type) {
      if ('pause' == msgEvent.data.content) {
        _bPause = true
      } else if ('resume' == msgEvent.data.content) {
        _bPause = false
        _loopStep()
      }
    }
    if (!_bPause) _sendFindSolutionState()
  };

  console.log('Multithreaded Worker Message: onmessage activated')
}

async function _initVariables() {
  let _iLastRowStart = 1
  if (2 == _nThreads) {
    _nSubSteps = 4 * (8 ** 7) - 1
    _iLastRowStart = 4 * _threadNo + 1
  } else if (4 == _nThreads) {
    _nSubSteps = 2 * (8 ** 7) - 1
    _iLastRowStart = 2 * _threadNo + 1
  } else if (8 == _nThreads) {
    _nSubSteps = (8 ** 7) - 1
    _iLastRowStart = _threadNo + 1
  }

  liPos = [1, 1, 1, 1, 1, 1, 1, _iLastRowStart]

  await delayed(4 * _nThreads);
}

async function _loopStep() {
  while (_stepCounter < _nSubSteps && !_bPause) {
    await _nextStep()
  } 
  if (_stepCounter >= _nSubSteps) {
    console.log('Multithreaded Worker Message: loop ended')
    _sendFindSolutionState()
    postMessage(null)
    close()
  }
}

async function _nextStep() {
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

_multithreadedFindSolutionWorkerEntryPoint()
