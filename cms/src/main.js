import './main.css';
import { createApp } from 'vue';
import App from './App.vue';
import router from './routes'; // Import router

const app = createApp(App);
app.use(router);
app.mount('#app');

