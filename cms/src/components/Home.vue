<template>
  <div class="flex flex-col gap-10">
    <!-- Hero section with cupcake styling -->
    <div class="hero min-h-[60vh] bg-base-200 rounded-box">
      <div class="hero-content text-center">
        <div class="max-w-md">
          <h1 class="text-5xl font-bold text-primary">Sweet Beginnings</h1>
          <p class="py-6">Experience the delightful world of the Cupcake theme. Light, sweet, and just the right amount of color to make your day brighter.</p>
          <div class="flex justify-center gap-2">
            <button class="btn btn-primary">Get Started</button>
            <button class="btn btn-outline btn-secondary">Learn More</button>
          </div>
        </div>
      </div>
    </div>

    <!-- Feature cards section -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
      <div class="card bg-base-100 shadow-xl hover:shadow-2xl transition-all duration-300">
        <figure class="px-10 pt-10">
          <div class="w-20 h-20 rounded-full bg-primary/20 flex items-center justify-center">
            <span class="text-4xl">🎨</span>
          </div>
        </figure>
        <div class="card-body items-center text-center">
          <h2 class="card-title text-secondary">Beautiful Design</h2>
          <p>The cupcake theme provides soft colors that are easy on the eyes</p>
          <div class="card-actions">
            <button class="btn btn-sm btn-primary">Explore</button>
          </div>
        </div>
      </div>
      
      <div class="card bg-base-100 shadow-xl hover:shadow-2xl transition-all duration-300">
        <figure class="px-10 pt-10">
          <div class="w-20 h-20 rounded-full bg-secondary/20 flex items-center justify-center">
            <span class="text-4xl">⚡</span>
          </div>
        </figure>
        <div class="card-body items-center text-center">
          <h2 class="card-title text-primary">Fast Development</h2>
          <p>Build beautiful UIs quickly with Tailwind CSS and DaisyUI components</p>
          <div class="card-actions">
            <button class="btn btn-sm btn-secondary">Learn</button>
          </div>
        </div>
      </div>
      
      <div class="card bg-base-100 shadow-xl hover:shadow-2xl transition-all duration-300">
        <figure class="px-10 pt-10">
          <div class="w-20 h-20 rounded-full bg-accent/20 flex items-center justify-center">
            <span class="text-4xl">📱</span>
          </div>
        </figure>
        <div class="card-body items-center text-center">
          <h2 class="card-title text-accent">Responsive</h2>
          <p>Perfectly designed for all screen sizes and devices</p>
          <div class="card-actions">
            <button class="btn btn-sm btn-accent">Discover</button>
          </div>
        </div>
      </div>
    </div>

    <!-- Stats section -->
    <div class="stats shadow bg-base-200 w-full">
      <div class="stat">
        <div class="stat-figure text-primary">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="inline-block w-8 h-8 stroke-current"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"></path></svg>
        </div>
        <div class="stat-title">Total Likes</div>
        <div class="stat-value text-primary">25.6K</div>
        <div class="stat-desc">21% more than last month</div>
      </div>
      
      <div class="stat">
        <div class="stat-figure text-secondary">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="inline-block w-8 h-8 stroke-current"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path></svg>
        </div>
        <div class="stat-title">Page Views</div>
        <div class="stat-value text-secondary">2.6M</div>
        <div class="stat-desc">14% more than last month</div>
      </div>
      
      <div class="stat">
        <div class="stat-figure text-accent">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="inline-block w-8 h-8 stroke-current"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4"></path></svg>
        </div>
        <div class="stat-title">New Users</div>
        <div class="stat-value text-accent">4,200</div>
        <div class="stat-desc">↗︎ 400 (22%)</div>
      </div>
    </div>
    
    <!-- Newsletter section -->
    <div class="card bg-base-200 shadow-xl">
      <div class="card-body items-center text-center">
        <h2 class="card-title text-primary text-2xl">Stay Updated!</h2>
        <p>Subscribe to our newsletter for the latest updates and features.</p>
        <div class="form-control w-full max-w-xs">
          <div class="input-group">
            <input type="text" placeholder="Your email address" class="input input-bordered w-full" />
            <button class="btn btn-primary">
              Subscribe
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
