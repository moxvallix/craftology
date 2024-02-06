import van from "https://cdn.jsdelivr.net/gh/vanjs-org/van/public/van-1.2.8.min.js"
const {div, span} = van.tags

export class Craftology {
  constructor(params = {}) {
    this.playspace = params.playspace
    this.library = params.library
    this.trash = params.trash
    this.elements = params.elements || []
    this.claimID = this.getClaimID()

    for (const index in this.elements) {
      const element = this.elements[index]
      van.add(this.library, this.libraryElement(element))
    }

    // Drag and Drop for Playspace
    this.playspace.addEventListener("dragover", event => event.preventDefault())
    this.playspace.addEventListener("drop", event => this.handlePlayspaceDrop(event, this))
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
  }

  getClaimID() {
    let claim = localStorage.getItem("craftology-claim-id")
    if (claim) { return claim }

    claim = self.crypto.randomUUID()
    localStorage.setItem("craftology-claim-id", claim)
    return claim
  }

  elementIcon(data) {
    return div(
      {
        class: "rounded-lg border border-gray-400 p-2 select-none cursor-pointer bg-white text-nowrap whitespace-nowrap",
        title: data.description, draggable: true
      },
      span({class: "pointer-events-none"}, data.icon),
      span({ class: "pointer-events-none ml-2 capitalize"}, data.name)
    )
  }
  
  playspaceElement(data) {
    data.id = "id" + Math.random().toString(16).slice(2)
    let output = this.elementIcon(data)
    output.id = data.id
    output.style.position = "absolute"
  
    output.addEventListener("dragstart", event => {
      let rect = output.getBoundingClientRect()
  
      data.type = "playspace"
      data.offset = {x: event.clientX - rect.left, y: event.clientY - rect.top}
  
      event.dataTransfer.setData("text/plain", JSON.stringify(data))
      event.dataTransfer.dropEffect = "copy"
      output.parentNode.removeChild(output)
      document.getElementById("element-curtain").append(output)
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
        target.parentNode.removeChild(target)
      }
      event.target.parentNode.removeChild(event.target)
  
    })
  
    output.addEventListener("dragend", event => {
      document.getElementById("element-curtain").removeChild(output)
    })
  
    return output
  }
  
  libraryElement(data) {
    let output = this.elementIcon(data)
    
    output.addEventListener("dragstart", event => {
      let rect = output.getBoundingClientRect()
      
      data.type = "library"
      data.offset = {x: event.clientX - rect.left, y: event.clientY - rect.top}
  
      event.dataTransfer.setData("text/plain", JSON.stringify(data))
      event.dataTransfer.dropEffect = "copy"
    })
  
    return output
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
    let pending = this.elementIcon({name: "Pending", icon: "⌛", description: "Crafting in progress..."})
    pending.removeAttribute("draggable")
    pending.style.display = "none"
    pending.style.position = "absolute"
    pending.style.top = `${rect.top}px`
    pending.style.left = `${rect.left}px`

    setTimeout(() => {
      pending.style.display = ""
    }, 100)

    this.playspace.append(pending)
  
    this.craftElement(left, right).then(data => {
      this.playspace.removeChild(pending)
      let newElement = this.playspaceElement(data)
      newElement.style.top = `${rect.top}px`
      newElement.style.left = `${rect.left}px`
      this.playspace.append(newElement)
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
                let hasElement = false
                this.elements.forEach(e => {
                  if (e.name === json.name) { return hasElement = true }
                })
                if (!hasElement) {
                  this.elements.push(json)
                  this.library.append(this.libraryElement(json))
                }
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