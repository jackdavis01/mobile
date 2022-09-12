class MultithreadedFindSolutionsController {
  _mtFSW = []
  _mtFindSolutionsWorker = []
  _mtFindSolutionsWorkerEntryPoint = 'js/multithreadedfindsolutionsthread.js'
  _nThreads = 2;

  async startMultithreadedWorkersInBackground(nThreads0, waitms0) {
    this._nThreads = nThreads0
    if ("undefined" !== typeof(Worker)) {
      for (let iPort = 0; iPort < this._nThreads; iPort++) {
        if (undefined != this._mtFSW[iPort]) {
          this._mtFSW[iPort].terminate()
          this._mtFindSolutionsWorker[iPort] = undefined
          this._mtFSW[iPort] = undefined
          console.log('Js Mt Message: Worker reset')
        }
        this._mtFindSolutionsWorker[iPort] =
            new Worker(this._mtFindSolutionsWorkerEntryPoint);
        this._mtFSW[iPort] = this._mtFindSolutionsWorker[iPort];

        console.log('Js Mt Message: Worker started: ' + iPort)
        console.log('Js Mt Message: Worker: ' + JSON.stringify(this._mtFindSolutionsWorker[iPort]))

        this._mtFindSolutionsWorker[iPort].postMessage({"type": "init", "content": [this._nThreads, iPort, waitms0]})

        this._mtFindSolutionsWorker[iPort].onmessage = (msgEvent) => {
          sendMultithreadedMessage2Dart([iPort, msgEvent.data])
        }

        console.log('Js Mt Message: Worker onmessage initiated, iPort: ' + iPort)

        this._mtFindSolutionsWorker[iPort].onerror = (err) => {
          console.log('Js Mt Message: Err from Worker: ' + iPort + ', ' + JSON.stringify(err))
        }

        console.log('Js Mt Message: Worker onerror initiated, iPort: ' + iPort)
      }
    } else {
      alert('Js Mt Message: Sorry! No Web Worker support in this browser..')
    }
    console.log('Js Mt Message: startWorker end')
  }

  receiveMsgFromDartMethod(iPort, waitms) {
    this._mtFindSolutionsWorker[iPort].postMessage({"type": "msg", "content": [waitms]})
  }

  stopMultithreadedWorkersInBackground() {
    for (let i = 0; i < this._nThreads; i++) {
      this._mtFindSolutionsWorker[i].terminate();
    }
  }

  pause() {
    for (let i = 0; i < this._nThreads; i++) {
      this._mtFindSolutionsWorker[i].postMessage({"type": "control", "content": 'pause'})
    }
  }

  resume() {
    for (let i = 0; i < this._nThreads; i++) {
      this._mtFindSolutionsWorker[i].postMessage({"type": "control", "content": 'resume'})
    }
  }
}

const MultithreadedFindSolutionsControllerJsObject = new MultithreadedFindSolutionsController()

function receiveMultithreadedMsgFromDart(iPort, waitms) {
  MultithreadedFindSolutionsControllerJsObject.receiveMsgFromDartMethod(iPort, waitms)
}

function startMultithreadedWorkers(nThreads, waitms) {
  console.log('Js Mt Message: startMultithreadedWorker, nThreads: ' + nThreads + ', waitms: ' + waitms)
  MultithreadedFindSolutionsControllerJsObject.startMultithreadedWorkersInBackground(nThreads, waitms)
}

function stopMultithreadedWorkers() {
  console.log('Js Mt Message: stopMultithreadedWorker')
  MultithreadedFindSolutionsControllerJsObject.stopMultithreadedWorkersInBackground()
}

function pauseMultithreadedWorkers() {
  console.log('Js Mt Message: pauseMultithreadedWorker')
  MultithreadedFindSolutionsControllerJsObject.pause()
}

function resumeMultithreadedWorkers() {
  console.log('Js Mt Message: resumeMultithreadedWorker')
  MultithreadedFindSolutionsControllerJsObject.resume()
}
