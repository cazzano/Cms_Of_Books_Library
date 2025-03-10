import { createRouter, createWebHistory } from "vue-router";
import Home from "./components/Home.vue";
import About from "./components/About.vue"; // Import About page
import Book from "./components/Book.vue";
import Static from "./components/Static.vue";
import UploadPic from "./components/UploadPic.vue";
import UploadDn from "./components/UploadDn.vue";
import File_Server from "./components/File_Server.vue";
import Database from "./components/Database.vue";

const routes = [
  { path: "/", component: Home },
  { path: "/about", component: About }, // Add About route
  { path: "/book", component: Book },
  { path: "/static", component: Static },
  { path: "/pictures", component: UploadPic },
  { path: "/documents", component: UploadDn },
  { path: "/file_server", component: File_Server },
  { path: "/database", component: Database },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
