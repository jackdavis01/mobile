const MultithreadedFindSolutionsController = {
  mtFSW : [],
  mtFindSolutionsWorker : [],
  mtFindSolutionsWorkerEntryPoint : 'js/multithreadedfindsolutionsthread.js',
  nThreads : 2,

  async startMultithreadedWorkersInBackground(nThreads0, waitms0, bRelease) {
    this.nThreads = nThreads0
    if ("undefined" !== typeof(Worker)) {
      for (let iPort = 0; iPort < this.nThreads; iPort++) {
        if (undefined != this.mtFSW[iPort]) {
          this.mtFSW[iPort].terminate()
          this.mtFindSolutionsWorker[iPort] = undefined
          this.mtFSW[iPort] = undefined
          console.log('Js Mt Message: Worker reset')
        }
        this.mtFindSolutionsWorker[iPort] =
            new Worker(this.mtFindSolutionsWorkerEntryPoint + '?bRelease=' + bRelease);
        this.mtFSW[iPort] = this.mtFindSolutionsWorker[iPort];

        console.log('Js Mt Message: Worker started: ' + iPort)
        console.log('Js Mt Message: Worker: ' + JSON.stringify(this.mtFindSolutionsWorker[iPort]))

        this.mtFindSolutionsWorker[iPort].postMessage({"type": "init", "content": [this.nThreads, iPort, waitms0]})

        this.mtFindSolutionsWorker[iPort].onmessage = (msgEvent) => {
          sendMultithreadedMessage2Dart([iPort, msgEvent.data])
        }

        console.log('Js Mt Message: Worker onmessage initiated, iPort: ' + iPort)

        this.mtFindSolutionsWorker[iPort].onerror = (err) => {
          console.log('Js Mt Message: Err from Worker: ' + iPort + ', ' + JSON.stringify(err))
        }

        console.log('Js Mt Message: Worker onerror initiated, iPort: ' + iPort)
      }
    } else {
      alert('Js Mt Message: Sorry! No Web Worker support in this browser..')
    }
    console.log('Js Mt Message: startWorker end')
  },

  receiveMsgFromDartMethod(iPort, waitms) {
    this.mtFindSolutionsWorker[iPort].postMessage({"type": "msg", "content": [waitms]})
  },

  stopMultithreadedWorkersInBackground() {
    for (let i = 0; i < this.nThreads; i++) {
      this.mtFindSolutionsWorker[i].terminate();
    }
  },

  pause() {
    for (let i = 0; i < this.nThreads; i++) {
      this.mtFindSolutionsWorker[i].postMessage({"type": "control", "content": 'pause'})
    }
  },

  resume() {
    for (let i = 0; i < this.nThreads; i++) {
      this.mtFindSolutionsWorker[i].postMessage({"type": "control", "content": 'resume'})
    }
  }
}

function receiveMultithreadedMsgFromDart(iPort, waitms) {
  MultithreadedFindSolutionsController.receiveMsgFromDartMethod(iPort, waitms)
}

function startMultithreadedWorkers(nThreads, waitms, bRelease0) {
  if (bRelease0) { console.log = function () {} }
  console.log('Js Mt Message: startMultithreadedWorkers, nThreads: ' + nThreads + ', waitms: ' + waitms)
  MultithreadedFindSolutionsController.startMultithreadedWorkersInBackground(nThreads, waitms, bRelease0)
}

function stopMultithreadedWorkers() {
  console.log('Js Mt Message: stopMultithreadedWorkers')
  MultithreadedFindSolutionsController.stopMultithreadedWorkersInBackground()
}

function pauseMultithreadedWorkers() {
  console.log('Js Mt Message: pauseMultithreadedWorkers')
  MultithreadedFindSolutionsController.pause()
}

function resumeMultithreadedWorkers() {
  console.log('Js Mt Message: resumeMultithreadedWorkers')
  MultithreadedFindSolutionsController.resume()
}
