<template>
  <div class="flex flex-col gap-8">
    <!-- Page header -->
    <div class="text-center">
      <h1 class="text-4xl font-bold text-primary">Books Gallery</h1>
      <p class="mt-2 text-lg">Browse books and upload pictures for your favorites</p>
    </div>

    <!-- Search and filter section -->
    <div class="flex flex-col md:flex-row gap-4 justify-between">
      <div class="form-control w-full md:w-1/2">
        <div class="input-group">
          <input 
            type="text" 
            placeholder="Search by title, author, or category..." 
            class="input input-bordered w-full" 
            v-model="searchQuery"
            @input="handleSearch"
          />
          <button class="btn btn-square btn-primary">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
          </button>
        </div>
      </div>
      
      <div class="flex flex-wrap gap-2">
        <select class="select select-bordered" v-model="categoryFilter" @change="applyFilters">
          <option value="">All Categories</option>
          <option v-for="category in uniqueCategories" :key="category" :value="category">
            {{ category }}
          </option>
        </select>
        
        <select class="select select-bordered" v-model="sortOption" @change="applyFilters">
          <option value="name_asc">Name (A-Z)</option>
          <option value="name_desc">Name (Z-A)</option>
          <option value="author_asc">Author (A-Z)</option>
          <option value="author_desc">Author (Z-A)</option>
        </select>
      </div>
    </div>

    <!-- Loading state -->
    <div v-if="loading" class="flex justify-center items-center py-12">
      <span class="loading loading-spinner loading-lg text-primary"></span>
    </div>

    <!-- Error state -->
    <div v-if="error" class="alert alert-error shadow-lg">
      <div>
        <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current flex-shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
        <span>{{ error }}</span>
      </div>
    </div>

    <!-- No results state -->
    <div v-if="!loading && filteredBooks.length === 0 && !error" class="alert alert-info shadow-lg">
      <div>
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="stroke-current flex-shrink-0 h-6 w-6"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
        <span v-if="searchQuery || categoryFilter">No books match your search criteria. Try adjusting your filters.</span>
        <span v-else>No books available at this time.</span>
      </div>
    </div>

    <!-- Books grid -->
    <div v-if="paginatedBooks.length > 0" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div 
        v-for="book in paginatedBooks" 
        :key="book.books_id" 
        class="card bg-base-100 shadow-xl hover:shadow-2xl transition-all duration-300"
      >
        <figure class="px-10 pt-10 relative group">
          <img :src="book.static_resources.picture_url" :alt="book.name" class="rounded-xl h-48 object-cover" />
          <div class="absolute inset-0 bg-black bg-opacity-0 group-hover:bg-opacity-40 transition-all duration-300 flex items-center justify-center opacity-0 group-hover:opacity-100">
            <button 
              class="btn btn-circle btn-secondary"
              @click.stop="selectBookForUpdate(book)"
            >
              <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
              </svg>
            </button>
          </div>
        </figure>
        <div class="card-body">
          <h2 class="card-title text-secondary">{{ book.name }}</h2>
          <div class="badge badge-primary">{{ book.category }}</div>
          <p class="text-sm mt-2">By {{ book.author_name }}</p>
          <p>{{ book.description }}</p>
          <div class="card-actions justify-end mt-4">
            <button 
              class="btn btn-sm btn-outline btn-error"
              @click.stop="openDeleteModal(book)"
            >
              Delete Picture
            </button>
            <button 
              class="btn btn-sm btn-outline btn-accent"
              @click.stop="selectBookForUpdate(book)"
            >
              Change Picture
            </button>
            <button 
              class="btn btn-sm btn-primary"
              @click.stop="selectBook(book)"
            >
              Upload New Picture
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Pagination -->
    <div v-if="filteredBooks.length > 0" class="flex justify-center mt-8">
      <div class="btn-group">
        <button 
          class="btn" 
          :class="{ 'btn-active': currentPage === 1 }"
          :disabled="currentPage === 1"
          @click="goToPage(1)"
        >
          «
        </button>
        
        <button 
          class="btn" 
          :class="{ 'btn-active': currentPage === 1 }"
          :disabled="currentPage === 1"
          @click="goToPage(currentPage - 1)"
        >
          ‹
        </button>
        
        <button 
          v-for="page in displayedPages" 
          :key="page" 
          class="btn" 
          :class="{ 'btn-active': currentPage === page }"
          @click="goToPage(page)"
        >
          {{ page }}
        </button>
        
        <button 
          class="btn" 
          :class="{ 'btn-active': currentPage === totalPages }"
          :disabled="currentPage === totalPages"
          @click="goToPage(currentPage + 1)"
        >
          ›
        </button>
        
        <button 
          class="btn" 
          :class="{ 'btn-active': currentPage === totalPages }"
          :disabled="currentPage === totalPages"
          @click="goToPage(totalPages)"
        >
          »
        </button>
      </div>
    </div>

    <!-- Per page selector -->
    <div v-if="filteredBooks.length > 0" class="flex justify-center mt-4">
      <div class="form-control">
        <label class="label">
          <span class="label-text">Books per page</span>
        </label>
        <select v-model="perPage" class="select select-bordered" @change="handlePerPageChange">
          <option value="6">6</option>
          <option value="9">9</option>
          <option value="12">12</option>
          <option value="24">24</option>
        </select>
      </div>
    </div>

    <!-- Upload modal -->
    <div class="modal" :class="{ 'modal-open': selectedBook !== null }">
      <div class="modal-box">
        <h3 class="font-bold text-lg text-primary">Upload Picture for "{{ selectedBook?.name }}"</h3>
        
        <div class="py-4">
          <div v-if="uploadSuccess" class="alert alert-success mb-4">
            <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current flex-shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
            <span>Picture uploaded successfully!</span>
          </div>
          
          <div v-if="uploadError" class="alert alert-error mb-4">
            <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current flex-shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
            <span>{{ uploadError }}</span>
          </div>
          
          <div class="form-control w-full">
            <label class="label">
              <span class="label-text">Choose a picture to upload</span>
            </label>
            <input 
              type="file" 
              accept="image/*" 
              class="file-input file-input-bordered file-input-primary w-full" 
              @change="handleFileChange"
              ref="fileInput"
            />
          </div>
          
          <div v-if="selectedFile" class="mt-4">
            <div class="flex items-center gap-2">
              <div class="badge badge-primary">Selected File</div>
              <p class="text-sm">{{ selectedFile.name }}</p>
            </div>
            
            <div v-if="filePreview" class="mt-4 flex justify-center">
              <img :src="filePreview" alt="Preview" class="max-h-40 rounded-lg" />
            </div>
          </div>

          <div class="mt-4">
            <p class="text-sm text-info">Book ID: {{ selectedBook?.books_id }}</p>
          </div>
        </div>
        
        <div class="modal-action">
          <button class="btn btn-outline" @click="closeModal">Cancel</button>
          <button 
            class="btn btn-primary" 
            :disabled="!selectedFile || uploading" 
            @click="uploadPicture"
          >
            <span v-if="uploading" class="loading loading-spinner loading-sm"></span>
            {{ isUpdateMode ? 'Update Picture' : 'Upload Picture' }}
          </button>
        </div>
      </div>
    </div>

    <!-- Delete modal -->
    <div class="modal" :class="{ 'modal-open': deleteModalOpen }">
      <div class="modal-box">
        <h3 class="font-bold text-lg text-error">Delete Picture</h3>
        
        <div class="py-4">
          <div v-if="deleteSuccess" class="alert alert-success mb-4">
            <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current flex-shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
            <span>Picture deleted successfully!</span>
          </div>
          
          <div v-if="deleteError" class="alert alert-error mb-4">
            <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current flex-shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
            <span>{{ deleteError }}</span>
          </div>
          
          <div v-if="bookForDelete" class="alert alert-warning mb-4">
            <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current flex-shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" /></svg>
            <span>Are you sure you want to delete the picture for "{{ bookForDelete.name }}"?</span>
          </div>
          
          <div v-if="bookForDelete && bookForDelete.static_resources && bookForDelete.static_resources.picture_url" class="flex justify-center mb-4">
            <img :src="bookForDelete.static_resources.picture_url" :alt="bookForDelete.name" class="h-40 object-contain rounded-lg" />
          </div>
          
          <div v-if="bookForDelete" class="text-sm text-info mb-4">
            <p>Book ID: {{ bookForDelete.books_id }}</p>
            <p>This action cannot be undone.</p>
          </div>
        </div>
        
        <div class="modal-action">
          <button class="btn btn-outline" @click="closeDeleteModal">Cancel</button>
          <button 
            class="btn btn-error" 
            :disabled="!bookForDelete || deleting" 
            @click="deletePicture"
          >
            <span v-if="deleting" class="loading loading-spinner loading-sm"></span>
            Delete Picture
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      books: [],
      loading: true,
      error: null,
      selectedBook: null,
      selectedFile: null,
      filePreview: null,
      uploading: false,
      uploadSuccess: false,
      uploadError: null,
      isUpdateMode: false,
      
      // Delete functionality
      deleteModalOpen: false,
      bookForDelete: null,
      deleting: false,
      deleteSuccess: false,
      deleteError: null,
      
      // Search and filter functionality
      searchQuery: '',
      searchTimeout: null,
      categoryFilter: '',
      sortOption: 'name_asc',
      
      // Pagination
      currentPage: 1,
      perPage: 9,
      maxPageDisplay: 5
    }
  },
  computed: {
    // Get unique categories for the filter dropdown
    uniqueCategories() {
      return [...new Set(this.books.map(book => book.category))];
    },
    
    // Filter books based on search query and category filter
    filteredBooks() {
      let result = [...this.books];
      
      // Apply search filter
      if (this.searchQuery.trim() !== '') {
        const query = this.searchQuery.toLowerCase().trim();
        result = result.filter(book => 
          book.name.toLowerCase().includes(query) || 
          book.author_name.toLowerCase().includes(query) || 
          book.category.toLowerCase().includes(query) ||
          (book.description && book.description.toLowerCase().includes(query))
        );
      }
      
      // Apply category filter
      if (this.categoryFilter) {
        result = result.filter(book => book.category === this.categoryFilter);
      }
      
      // Apply sorting
      result = this.sortBooks(result);
      
      return result;
    },
    
    // Calculate total pages based on filtered books and per page count
    totalPages() {
      return Math.max(1, Math.ceil(this.filteredBooks.length / this.perPage));
    },
    
    // Calculate which pages to display in pagination
    displayedPages() {
      const pages = [];
      const halfDisplayCount = Math.floor(this.maxPageDisplay / 2);
      
      // Calculate start and end page numbers to display
      let startPage = Math.max(1, this.currentPage - halfDisplayCount);
      let endPage = Math.min(this.totalPages, startPage + this.maxPageDisplay - 1);
      
      // Adjust startPage if we're near the end
      if (endPage - startPage + 1 < this.maxPageDisplay) {
        startPage = Math.max(1, endPage - this.maxPageDisplay + 1);
      }
      
      // Generate the page numbers array
      for (let i = startPage; i <= endPage; i++) {
        pages.push(i);
      }
      
      return pages;
    },
    
    // Get paginated books to display
    paginatedBooks() {
      const start = (this.currentPage - 1) * this.perPage;
      const end = start + this.perPage;
      return this.filteredBooks.slice(start, end);
    }
  },
  mounted() {
    this.fetchBooks();
  },
  methods: {
    async fetchBooks() {
      this.loading = true;
      this.error = null;
      
      try {
        const response = await fetch('http://localhost:5000/books');
        
        if (!response.ok) {
          throw new Error(`Failed to fetch books: ${response.status} ${response.statusText}`);
        }
        
        this.books = await response.json();
        
        // Reset to page 1 when fetching new data
        this.currentPage = 1;
      } catch (err) {
        console.error('Error fetching books:', err);
        this.error = 'Failed to load books. Please try again later.';
      } finally {
        this.loading = false;
      }
    },
    
    // Search and filter methods
    handleSearch() {
      // Debounce search to avoid rapid API calls
      clearTimeout(this.searchTimeout);
      this.searchTimeout = setTimeout(() => {
        this.currentPage = 1; // Reset to first page on search
      }, 300);
    },
    
    applyFilters() {
      this.currentPage = 1; // Reset to first page when filters change
    },
    
    sortBooks(books) {
      const sortedBooks = [...books];
      
      switch(this.sortOption) {
        case 'name_asc':
          return sortedBooks.sort((a, b) => a.name.localeCompare(b.name));
        case 'name_desc':
          return sortedBooks.sort((a, b) => b.name.localeCompare(a.name));
        case 'author_asc':
          return sortedBooks.sort((a, b) => a.author_name.localeCompare(b.author_name));
        case 'author_desc':
          return sortedBooks.sort((a, b) => b.author_name.localeCompare(a.author_name));
        default:
          return sortedBooks;
      }
    },
    
    // Pagination methods
    goToPage(page) {
      if (page >= 1 && page <= this.totalPages) {
        this.currentPage = page;
        // Scroll to top of books section
        window.scrollTo({ top: 0, behavior: 'smooth' });
      }
    },
    
    handlePerPageChange() {
      // Reset to first page when changing items per page
      this.currentPage = 1;
    },
    
    // Original functionality
    selectBook(book) {
      this.selectedBook = book;
      this.selectedFile = null;
      this.filePreview = null;
      this.uploadSuccess = false;
      this.uploadError = null;
      this.isUpdateMode = false;
      
      // Reset file input
      if (this.$refs.fileInput) {
        this.$refs.fileInput.value = '';
      }
    },
    
    selectBookForUpdate(book) {
      this.selectBook(book);
      this.isUpdateMode = true;
    },
    
    closeModal() {
      this.selectedBook = null;
      this.selectedFile = null;
      this.filePreview = null;
      this.isUpdateMode = false;
    },
    
    handleFileChange(event) {
      const file = event.target.files[0];
      if (!file) return;
      
      // Store the file
      this.selectedFile = file;
      this.uploadSuccess = false;
      this.uploadError = null;
      
      // Create preview
      const reader = new FileReader();
      reader.onload = e => {
        this.filePreview = e.target.result;
      };
      reader.readAsDataURL(file);
    },
    
    async uploadPicture() {
      if (!this.selectedFile || !this.selectedBook) return;
      
      this.uploading = true;
      this.uploadSuccess = false;
      this.uploadError = null;
      
      try {
        const formData = new FormData();
        formData.append('file', this.selectedFile);
        
        // Use PUT method for update mode, POST for new upload
        const method = this.isUpdateMode ? 'PUT' : 'POST';
        console.log(`${method} request to book_id: ${this.selectedBook.books_id}`);
        
        const response = await fetch(`http://localhost:3000/pictures?book_id=${this.selectedBook.books_id}`, {
          method: method,
          body: formData
        });
        
        console.log('Response status:', response.status);
        
        if (!response.ok) {
          const errorText = await response.text();
          console.error('Error response:', errorText);
          throw new Error(`${this.isUpdateMode ? 'Update' : 'Upload'} failed: ${response.status} ${response.statusText}`);
        }
        
        this.uploadSuccess = true;
        
        // Refresh books data after successful upload
        setTimeout(() => {
          this.fetchBooks();
          this.closeModal();
        }, 1500);
      } catch (err) {
        console.error(`Error ${this.isUpdateMode ? 'updating' : 'uploading'} picture:`, err);
        this.uploadError = `Failed to ${this.isUpdateMode ? 'update' : 'upload'} picture. Please try again.`;
      } finally {
        this.uploading = false;
      }
    },
    
    // Delete functionality methods
    openDeleteModal(book) {
      this.deleteModalOpen = true;
      this.bookForDelete = book;
      this.deleteSuccess = false;
      this.deleteError = null;
    },
    
    closeDeleteModal() {
      this.deleteModalOpen = false;
      this.bookForDelete = null;
    },
    
    async deletePicture() {
      if (!this.bookForDelete) return;
      
      this.deleting = true;
      this.deleteSuccess = false;
      this.deleteError = null;
      
      try {
        const response = await fetch(`http://localhost:3000/pictures?book_id=${this.bookForDelete.books_id}`, {
          method: 'DELETE'
        });
        
        if (!response.ok) {
          const errorText = await response.text();
          console.error('Error response:', errorText);
          throw new Error(`Delete failed: ${response.status} ${response.statusText}`);
        }
        
        this.deleteSuccess = true;
        
        // Refresh books data after successful deletion
        setTimeout(() => {
          this.fetchBooks();
          if (this.deleteSuccess) {
            this.closeDeleteModal();
          }
        }, 1500);
      } catch (err) {
        console.error('Error deleting picture:', err);
        this.deleteError = 'Failed to delete picture. Please try again.';
      } finally {
        this.deleting = false;
      }
    }
  }
}
</script>
