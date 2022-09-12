class FindSolutionsController {
  _fSW = undefined
  _findSolutionsWorker = undefined
  _findSolutionsWorkerEntryPoint = 'js/findsolutionsthread.js'

  async startWorkerInBackground() {
    if ("undefined" !== typeof(Worker)) {
      if (undefined != this._fSW) {
        this._fSW.terminate()
        this._findSolutionsWorker = undefined
        this._fSW = undefined
        console.log('Js Message: Worker reset')
      }
      this._findSolutionsWorker =
          new Worker(this._findSolutionsWorkerEntryPoint);
      this._fSW = this._findSolutionsWorker;

      console.log('Js Message: Worker started')
      console.log('Js Message: Worker: ' + JSON.stringify(this._findSolutionsWorker))

      this._findSolutionsWorker.onmessage = (msgEvent) => {
        sendMessage2Dart(msgEvent.data)
      }

      console.log('Js Message: Worker onmessage initiated')

      this._findSolutionsWorker.onerror = (err) => {
        console.log('Js Message: Err from Worker: ' + JSON.stringify(err))
      }

      console.log('Js Message: Worker onerror initiated')

    } else {
      alert('Js Message: Sorry! No Web Worker support in this browser..')
    }
    console.log('Js Message: startWorker end')
    return
  }

  receiveMsgFromDartMethod(waitms) {
    this._findSolutionsWorker.postMessage(waitms)
  }

  stopWorkerInBackground() {
    this._findSolutionsWorker.terminate();
  }

  pause() {
    this._findSolutionsWorker.postMessage('pause')
  }

  resume() {
    this._findSolutionsWorker.postMessage('resume')
  }
}

const FindSolutionsControllerJsObject = new FindSolutionsController()

function receiveMsgFromDart(waitms) {
  FindSolutionsControllerJsObject.receiveMsgFromDartMethod(waitms)
}

function startWorker() {
  console.log('Worker Message: startWorker')
  FindSolutionsControllerJsObject.startWorkerInBackground()
}

function stopWorker() {
  console.log('Worker Message: stopWorker')
  FindSolutionsControllerJsObject.stopWorkerInBackground()
}

function pauseWorker() {
  console.log('Worker Message: pauseWorker')
  FindSolutionsControllerJsObject.pause()
}

function resumeWorker() {
  console.log('Worker Message: resumeWorker')
  FindSolutionsControllerJsObject.resume()
}
