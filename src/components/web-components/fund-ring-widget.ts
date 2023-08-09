import type { SvelteComponent } from 'svelte'

import WidgetSessionProvider from '$components/FundRingWidget/WidgetSessionProvider.svelte'
import css from '$components/FundRingWidget/widget.css'

customElements.define(
  'fund-ring-widget',
  class extends HTMLElement {
    _element: SvelteComponent

    constructor() {
      super()

      // Create the shadow root.
      const shadowRoot = this.attachShadow({ mode: 'open' })

      shadowRoot.innerHTML = `<style media="screen">${css}</style>`

      // Instantiate the Svelte Component
      this._element = new WidgetSessionProvider({
        // Tell it that it lives in the shadow root
        target: shadowRoot,
        // Pass any props
        props: {
          // This is the place where you do any conversion between
          // the native string attributes and the types you expect
          // in your svelte components
          contractAddress: this.getAttribute('contractAddress'),
          title: this.getAttribute('title') ?? 'Help fund us!',
          bodyCopy:
            this.getAttribute('bodyCopy') ??
            'If you rely upon Fund Ring’s efforts to keep your project going, please consider supporting our funding goal. Every little bit helps.'
        }
      })
    }
    disconnectedCallback(): void {
      // Destroy the Svelte component when this web component gets
      // disconnected. If this web component is expected to be moved
      // in the DOM, then you need to use `connectedCallback()` and
      // set it up again if necessary.
      this._element?.$destroy()
    }
  }
)
