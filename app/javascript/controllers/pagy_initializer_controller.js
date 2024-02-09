import { Controller } from "@hotwired/stimulus"
import Pagy from "pagy-module"

export default class extends Controller {
  connect() {
    console.log("Connected")
    Pagy.init(this.element)
  }
}