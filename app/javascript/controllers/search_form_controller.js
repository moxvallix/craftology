// https://www.colby.so/posts/filtering-tables-with-rails-and-hotwire
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "form", "input" ]
  
  connect() {
    if (this.inputTarget) {
      const re = new RegExp("^[a-z0-9]$", "i")

      document.addEventListener("keydown", event => {
        if (event.key.match(re)) {
          this.inputTarget.focus()
        }
      })
    }
  }

  search() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.formTarget.requestSubmit()
    }, 200)
  }

  clear() {
    this.inputTarget.value = ""
    this.search()
  }
}