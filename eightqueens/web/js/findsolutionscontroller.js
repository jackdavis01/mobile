const FindSolutionsController = {
  fSW : undefined,
  findSolutionsWorker : undefined,
  findSolutionsWorkerEntryPoint : 'js/findsolutionsthread.js',

  async startWorkerInBackground() {
    if ("undefined" !== typeof(Worker)) {
      if (undefined != this.fSW) {
        this.fSW.terminate()
        this.findSolutionsWorker = undefined
        this.fSW = undefined
        console.log('Js Message: Worker reset')
      }
      this.findSolutionsWorker =
          new Worker(this.findSolutionsWorkerEntryPoint)
      this._fSW = this.findSolutionsWorker

      console.log('Js Message: Worker started')
      console.log('Js Message: Worker: ' + JSON.stringify(this.findSolutionsWorker))

      this.findSolutionsWorker.onmessage = (msgEvent) => {
        sendMessage2Dart(msgEvent.data)
      }

      console.log('Js Message: Worker onmessage initiated')

      this.findSolutionsWorker.onerror = (err) => {
        console.log('Js Message: Err from Worker: ' + JSON.stringify(err))
      }

      console.log('Js Message: Worker onerror initiated')

    } else {
      alert('Js Message: Sorry! No Web Worker support in this browser..')
    }
    console.log('Js Message: startWorker end')
    return
  },

  receiveMsgFromDartMethod(waitms) {
    this.findSolutionsWorker.postMessage(waitms)
  },

  stopWorkerInBackground() {
    this.findSolutionsWorker.terminate();
  },

  pause() {
    this.findSolutionsWorker.postMessage('pause')
  },

  resume() {
    this.findSolutionsWorker.postMessage('resume')
  }
}

function receiveMsgFromDart(waitms) {
  FindSolutionsController.receiveMsgFromDartMethod(waitms)
}

function startWorker() {
  console.log('Worker Message: startWorker')
  FindSolutionsController.startWorkerInBackground()
}

function stopWorker() {
  console.log('Worker Message: stopWorker')
  FindSolutionsController.stopWorkerInBackground()
}

function pauseWorker() {
  console.log('Worker Message: pauseWorker')
  FindSolutionsController.pause()
}

function resumeWorker() {
  console.log('Worker Message: resumeWorker')
  FindSolutionsController.resume()
}
