import van from "https://cdn.jsdelivr.net/gh/vanjs-org/van/public/van-1.2.8.min.js"
const {div, span, input} = van.tags

export class Craftology {
  constructor(params = {}) {
    this.playspace = params.playspace
    this.library = params.library
    this.trash = params.trash
    this.search = params.search
    this.elements = params.elements || []
    this.claimID = this.getClaimID()
    this.selectedElements = []
    this.selectedElementsData = []
    
    let elementJson = localStorage.getItem("craftology-elements")
    if (elementJson) {
      try {
        let savedElements = JSON.parse(elementJson)
        this.elements = savedElements
      } catch {}
    }

    for (const index in this.elements) {
      const element = this.elements[index]
      this.addToLibrary(element)
    }

    // Drag and Drop for Playspace
    this.playspace.addEventListener("dragover", event => event.preventDefault())
    this.playspace.addEventListener("drop", event => this.handlePlayspaceDrop(event, this))
    this.playspace.addEventListener("click", event => {
      if (this.selectedElements.length <= 0 || this.selectedElementsData.length <= 0) { return }
      let element = this.selectedElements[0]
      let data = this.selectedElementsData[0]
      
      event.preventDefault()

      if (element.dataset.type === "library") {
        element = this.playspaceElement(data)
        this.playspace.append(element)
      }
      
      let rect = element.getBoundingClientRect()
      let xPos = event.offsetX - (rect.width / 2)
      let yPos = event.offsetY - (rect.height / 2)

      element.style.top = `${yPos}px`
      element.style.left = `${xPos}px`

      this.handleElementsDeselect()
    })
    this.playspace.style.position = "relative"
    this.playspace.style.overflow = "clip"

    // Drag and Drop for Library
    this.trash.addEventListener("dragover", event => event.preventDefault())
    this.trash.addEventListener("drop", event => this.handleLibraryDrop(event))

    this.playspace.insertBefore(
      div(
        {id: "element-curtain", class: "relative overflow-hidden"}
      ), this.playspace.firstChild
    )

    this.playspace.append(this.trashIcon())
    this.setupSearch(this.search)
  }

  getClaimID() {
    let claim = localStorage.getItem("craftology-claim-id")
    if (claim) { return claim }

    claim = generateUUID()
    localStorage.setItem("craftology-claim-id", claim)
    return claim
  }

  trashIcon() {
    let output = div(
      {
        class: "absolute bottom-4 right-4 select-none cursor-pointer rounded-lg border border-gray-400 p-2 px-4 bg-white",
        title: "Delete element. Double-click to wipe board."
      },
      span({class: "pointer-events-none font-emoji"}, "🗑️")
    )
    
    output.addEventListener("dragenter", event => {
      output.classList.remove("border", "border-gray-400")
      output.classList.add("border-2", "border-red-400")
    })
    output.addEventListener("dragover", event => { event.preventDefault() })
    output.addEventListener("dragleave", event => {
      output.classList.add("border", "border-gray-400")
      output.classList.remove("border-2", "border-red-400")
    })

    output.addEventListener("drop", event => {
      event.stopPropagation()
      output.classList.add("border", "border-gray-400")
      output.classList.remove("border-2", "border-red-400")
    })

    output.addEventListener("click", event => {
      event.stopPropagation()
      if (event.shiftKey) {
        return this.wipeBoard()
      }
      this.selectedElements.forEach(element => {
        if (element.dataset.type === "playspace") {
          element.remove()
        }
      })
      this.handleElementsDeselect()
    })

    output.addEventListener("dblclick", this.wipeBoard)

    return output
  }

  setupSearch(search) {
    search.addEventListener("input", event => {
      console.log(event)
      this.filterLibrary(event.target.value)
    })
  }

  wipeBoard() {
    const collection = document.querySelectorAll('[data-type="playspace"]');

    for (const elem of collection) {
      elem.remove();
    }
  }

  elementIcon(data) {
    return div(
      {
        class: "flex justify-center rounded-lg border border-gray-400 p-2 select-none cursor-pointer bg-white text-nowrap whitespace-nowrap",
        title: data.description, draggable: true,
        "data-type": data?.type, "data-name": data.name
      },
      span({class: "pointer-events-none font-emoji"}, data.icon),
      span({ class: "pointer-events-none ml-2 capitalize"}, data.name)
    )
  }
  
  playspaceElement(data) {
    data.id = "id" + Math.random().toString(16).slice(2)
    data.type = "playspace"
    let output = this.elementIcon(data)
    output.id = data.id
    output.style.position = "absolute"

    if (data?.discovered_by?.self) {
      output.append(
        span({class: "absolute mt-10 text-xs"}, "First Discovery!")
      )
    }
  
    output.addEventListener("dragstart", event => {
      let rect = output.getBoundingClientRect()
  
      data.offset = {x: event.clientX - rect.left, y: event.clientY - rect.top}
  
      event.dataTransfer.setData("text/plain", JSON.stringify(data))
      event.dataTransfer.dropEffect = "copy"

      this.handleElementsDeselect()
    })
  
    output.addEventListener("dragenter", event => {
      output.classList.remove("border", "border-gray-400")
      output.classList.add("border-2", "border-emerald-400")
    })
    output.addEventListener("dragover", event => { event.preventDefault() })
    output.addEventListener("dragleave", event => {
      output.classList.add("border", "border-gray-400")
      output.classList.remove("border-2", "border-emerald-400")
    })

    output.addEventListener("drop", event => {
      event.stopPropagation()
      let targetData = JSON.parse(event.dataTransfer.getData('text/plain'))
      this.combineElements(output.getBoundingClientRect(), data.name, targetData.name)
  
      let target = document.getElementById(targetData.id)
      if (data.type === "playspace" && target) {
        target.remove()
      }
      event.target.remove()
  
    })
  
    output.addEventListener("dragend", event => {
      if (event.ctrlKey || event.shiftKey) { return }
      output.remove()
    })

    output.addEventListener("click", event => {this.handleElementSelect(event, data)})
  
    return output
  }
  
  libraryElement(data) {
    data.type = "library"
    let output = this.elementIcon(data)
    
    output.addEventListener("dragstart", event => {
      let rect = output.getBoundingClientRect()
      
      data.offset = {x: event.clientX - rect.left, y: event.clientY - rect.top}

      event.dataTransfer.setData("text/plain", JSON.stringify(data))
      event.dataTransfer.dropEffect = "copy"
    })

    output.addEventListener("click", event => {this.handleElementSelect(event, data)})
    output.addEventListener("dblclick", event => {
      let rect = this.randomPlayspaceRect()
      this.addToPlayspace(rect, data)
      this.handleElementsDeselect()
    })
  
    return output
  }

  handleElementSelect(event, data) {
    event.stopPropagation()

    this.selectedElements.push(event.target)
    this.selectedElementsData.push(data)
    event.target.classList.add("bg-amber-100")
    event.target.classList.remove("bg-white")

    if (this.selectedElements.length >= 2) {
      let left = this.selectedElements[0]
      let right = this.selectedElements[1]
      if (left === right) { return this.handleElementsDeselect() }
      
      let rect = this.randomPlayspaceRect()

      let playspaceElement

      this.selectedElements.forEach(element => {
        if (element.dataset.type === "playspace") {
          playspaceElement = element
        }
      })

      if (playspaceElement) { rect = playspaceElement.getBoundingClientRect() }
      this.combineElements(rect, this.selectedElements[0].dataset.name, this.selectedElements[1].dataset.name)

      this.selectedElements.forEach(element => {
        if (element.dataset.type === "playspace") {
          element.remove()
        }
      })
      this.handleElementsDeselect()
    }
  }

  randomPlayspaceRect() {
    const padding = 24

    let playspaceRect = this.playspace.getBoundingClientRect()
    return {
      top: getRandomArbitrary(padding, playspaceRect.height - padding),
      left: getRandomArbitrary(padding, playspaceRect.width - padding)
    }
  }

  handleElementsDeselect() {
    this.selectedElements.forEach(element => {
      element.classList.remove("bg-amber-100")
      element.classList.add("bg-white")
    })
    this.selectedElements = []
    this.selectedElementsData = []
  }
  
  handlePlayspaceDrop(event) {
    event.preventDefault()
    let data = JSON.parse(event.dataTransfer.getData('text/plain'))
    if (data.type === "library" || data.type === "playspace") {
      let element = this.playspaceElement(data)
      element.style.top = `${event.offsetY - data.offset.y}px`
      element.style.left = `${event.offsetX - data.offset.x}px`
      van.add(this.playspace, element)
    }
  }
  
  handleLibraryDrop(event) {
    event.preventDefault()
    let data = JSON.parse(event.dataTransfer.getData('text/plain'))
    if (data.type === "playspace") {
      delete document.getElementById(data.id)
    }
  }
  
  combineElements(rect, left, right) {
    let pending = this.elementIcon({name: "Crafting...", icon: "⌛", description: "Crafting in progress..."})
    pending.removeAttribute("draggable")
    pending.style.display = "none"
    pending.style.position = "absolute"
    pending.style.top = `${rect.top}px`
    pending.style.left = `${rect.left}px`
    pending.classList.add("heartbeat", "cursor-default")

    setTimeout(() => {
      pending.style.display = ""
    }, 100)

    this.playspace.append(pending)
  
    this.craftElement(left, right).then(data => {
      pending.remove()
      this.addToPlayspace(rect, data)
    })
  }

  addToPlayspace(rect, data) {
    let newElement = this.playspaceElement(data)
    newElement.style.top = `${rect.top}px`
    newElement.style.left = `${rect.left}px`
    this.playspace.append(newElement)
    return newElement
  }

  addToLibrary(data) {
    let newElement = this.libraryElement(data)
    this.library.append(newElement)
    return newElement
  }

  saveElement(data) {
    let hasElement = false
    this.elements.forEach(e => {
      if (e.name === data.name) { return hasElement = true }
    })
    if (!hasElement) {
      this.elements.push(data)
      localStorage.setItem("craftology-elements", JSON.stringify(this.elements))
      this.addToLibrary(data)
    }
  }

  filterLibrary(filter) {
    const pattern = filter.split(" ").map(escapeRegExp).join(".*")
    const re = new RegExp(pattern, "i")
    const children = Array.from(this.library.children)

    children.forEach(element => {
      let match = element.dataset.name.match(re)
      console.log(element.dataset.type)
      if (match) {
        element.classList.remove("hidden")
      } else {
        element.classList.add("hidden")
      }
    })
  }
  
  craftElement(left, right) {
    return new Promise((resolve, _) => {
      const request = (retries, retryCount = 0) => {
        // Make the HTTP request
        fetch(`/api/craft?left=${encodeURI(left)}&right=${encodeURI(right)}&uuid=${this.claimID}`).then((res) => {
          res.json()
          .then(json => {
            if (json.pending === true && retries > 0) {
              let timeOut = 200 * retryCount
              setTimeout(() => {
                request(--retries, ++retryCount)
              }, timeOut)
            } else {
              if (!json.pending) {
                this.saveElement(json)
                resolve(json)
              } else {
                resolve({name: "error", icon: "🚫", description: "The result of a failed experiment... Better luck next time!"})
              }
            }
          })
        })
      };
      request(25);
    })
  }
}

function generateUUID() {
  let
    d = new Date().getTime(),
    d2 = ((typeof performance !== 'undefined') && performance.now && (performance.now() * 1000)) || 0;
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, c => {
    let r = Math.random() * 16;
    if (d > 0) {
      r = (d + r) % 16 | 0;
      d = Math.floor(d / 16);
    } else {
      r = (d2 + r) % 16 | 0;
      d2 = Math.floor(d2 / 16);
    }
    return (c == 'x' ? r : (r & 0x7 | 0x8)).toString(16);
  });
};

function getRandomArbitrary(min, max) {
  return Math.random() * (max - min) + min;
}

// https://stackoverflow.com/questions/3446170/escape-string-for-use-in-javascript-regex#6969486
function escapeRegExp(string) {
  return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'); // $& means the whole matched string
}