<template>
  <div class="min-h-screen flex flex-col bg-base-100 text-base-content">
    <!-- Navbar with cupcake styling -->
    <div class="navbar bg-base-100 border-b border-base-300 shadow-sm sticky top-0 z-10">
      <div class="container mx-auto">
        <div class="flex-1">
          <a class="btn btn-ghost text-xl text-primary">
            <span class="text-2xl mr-2">🧁</span> Cupcake App
          </a>
        </div>
        <div class="flex-none">
          <ul class="menu menu-horizontal px-1 gap-2">
            <li><router-link to="/" class="btn btn-sm btn-primary">Home</router-link></li>
            <li><router-link to="/book" class="btn btn-sm btn-primary">Book</router-link></li>
            <li><router-link to="/static" class="btn btn-sm btn-primary">Static</router-link></li>
            <li><router-link to="/documents" class="btn btn-sm btn-primary">Documents</router-link></li>
            <li><router-link to="/pictures" class="btn btn-sm btn-primary">Pictures</router-link></li>
            <li><router-link to="/file_server" class="btn btn-sm btn-primary">File Backup</router-link></li>
            <li><router-link to="/database" class="btn btn-sm btn-primary">Database</router-link></li>
            <li><router-link to="/about" class="btn btn-sm btn-secondary">About</router-link></li>
            <li><a class="btn btn-sm btn-outline btn-accent">Contact</a></li>
          </ul>
        </div>
      </div>
    </div>

    <!-- Main content area -->
    <div class="flex-grow container mx-auto px-4 py-8">
      <router-view></router-view>
    </div>

    <!-- Footer with cupcake styling -->
    <footer class="footer footer-center p-10 bg-base-200 text-base-content rounded">
      <div class="grid grid-flow-col gap-4">
        <a class="link link-hover">About us</a> 
        <a class="link link-hover">Contact</a> 
        <a class="link link-hover">Services</a> 
        <a class="link link-hover">Privacy</a>
      </div> 
      <div>
        <div class="grid grid-flow-col gap-4">
          <a><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" class="fill-current"><path d="M24 4.557c-.883.392-1.832.656-2.828.775 1.017-.609 1.798-1.574 2.165-2.724-.951.564-2.005.974-3.127 1.195-.897-.957-2.178-1.555-3.594-1.555-3.179 0-5.515 2.966-4.797 6.045-4.091-.205-7.719-2.165-10.148-5.144-1.29 2.213-.669 5.108 1.523 6.574-.806-.026-1.566-.247-2.229-.616-.054 2.281 1.581 4.415 3.949 4.89-.693.188-1.452.232-2.224.084.626 1.956 2.444 3.379 4.6 3.419-2.07 1.623-4.678 2.348-7.29 2.04 2.179 1.397 4.768 2.212 7.548 2.212 9.142 0 14.307-7.721 13.995-14.646.962-.695 1.797-1.562 2.457-2.549z"></path></svg></a> 
          <a><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" class="fill-current"><path d="M19.615 3.184c-3.604-.246-11.631-.245-15.23 0-3.897.266-4.356 2.62-4.385 8.816.029 6.185.484 8.549 4.385 8.816 3.6.245 11.626.246 15.23 0 3.897-.266 4.356-2.62 4.385-8.816-.029-6.185-.484-8.549-4.385-8.816zm-10.615 12.816v-8l8 3.993-8 4.007z"></path></svg></a> 
          <a><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" class="fill-current"><path d="M9 8h-3v4h3v12h5v-12h3.642l.358-4h-4v-1.667c0-.955.192-1.333 1.115-1.333h2.885v-5h-3.808c-3.596 0-5.192 1.583-5.192 4.615v3.385z"></path></svg></a>
        </div>
      </div> 
      <div>
        <p>Made with 💖 using DaisyUI Cupcake theme</p>
      </div>
    </footer>
  </div>
</template>
