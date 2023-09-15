import {Socket, Presence} from "phoenix"
import { writable } from "svelte/store"

console.log(window.userToken)
const socket = new Socket("/socket", {params: {token: window.userToken}})
socket.connect()

export const channel = socket.channel("subledger:lobby", {})
channel.join()
  .receive("ok", (resp: unknown) => {
    appState.set({connected: true}),
    console.log("Joined successfully", resp)
  })
  .receive("error", (resp: unknown) => {
    appState.set({connected: false}),
    console.log("Unable to join", resp)
  })


export const presence = new Presence(channel);

// APP State
export const appState = writable({ connected: false })
export default socket