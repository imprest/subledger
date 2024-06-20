// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import 'phoenix_html';
// Establish Phoenix Socket and LiveView configuration.
// import {Socket} from "phoenix"

// let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

// Recommended way, to include lucide icons you need for web
import { createIcons, Menu, ArrowRight, Globe } from 'lucide';

createIcons({
  icons: {
    Menu,
    ArrowRight,
    Globe
  }
});
