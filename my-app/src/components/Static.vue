<template>
  <div class="static-container">
    <h1 class="text-2xl font-bold mb-6">Available Books</h1>
    
    <!-- Search Bar -->
    <div class="mb-6">
      <div class="flex flex-col md:flex-row gap-4">
        <div class="flex-grow">
          <input 
            type="text" 
            v-model="searchQuery" 
            placeholder="Search by title, author or category..." 
            class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            @input="handleSearch"
          />
        </div>
        <div class="flex gap-2">
          <select 
            v-model="searchField" 
            class="px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            @change="handleSearch"
          >
            <option value="all">All Fields</option>
            <option value="name">Title</option>
            <option value="author_name">Author</option>
            <option value="category">Category</option>
          </select>
          <button 
            @click="clearSearch" 
            class="px-4 py-2 bg-gray-200 hover:bg-gray-300 rounded-lg"
          >
            Clear
          </button>
        </div>
      </div>
    </div>
    
    <div v-if="loading" class="text-center py-8">
      <p>Loading books...</p>
    </div>
    
    <div v-else-if="error" class="text-center py-8 text-red-600">
      <p>{{ error }}</p>
    </div>
    
    <div v-else>
      <div v-if="filteredBooks.length === 0" class="text-center py-8">
        <p>No books found matching your search criteria.</p>
        <button 
          @click="clearSearch" 
          class="mt-4 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg"
        >
          Clear Search
        </button>
      </div>
      
      <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div v-for="book in paginatedBooks" :key="book.books_id" class="book-card border rounded-lg overflow-hidden shadow-md">
          <div class="book-image-container h-48 overflow-hidden bg-gray-100">
            <img 
              :src="getBookImageUrl(book)" 
              :alt="book.name" 
              class="w-full h-full object-cover"
              @error="handleImageError"
            />
          </div>
          
          <div class="p-4">
            <h2 class="text-xl font-bold mb-2">{{ book.name }}</h2>
            <p class="text-sm text-gray-700 mb-1"><span class="font-medium">Author:</span> {{ book.author_name }}</p>
            <p class="text-sm text-gray-700 mb-2"><span class="font-medium">Category:</span> {{ book.category }}</p>
            <p class="text-sm text-gray-800 mb-4">{{ book.description }}</p>
            
            <div class="flex justify-between items-center mb-2">
              <a 
                v-if="hasStaticResources(book) && book.static_resources.download_url" 
                :href="book.static_resources.download_url" 
                target="_blank" 
                class="text-blue-600 hover:text-blue-800 text-sm"
              >
                Download PDF
              </a>
              <span v-else class="text-gray-500 text-sm">No PDF available</span>
              
              <div>
                <button 
                  v-if="!hasStaticResources(book)"
                  @click="addStaticContent(book.books_id)" 
                  class="bg-green-600 hover:bg-green-700 text-white py-1 px-4 rounded"
                  :disabled="addingIds.includes(book.books_id) || deletingIds.includes(book.books_id)"
                >
                  {{ addingIds.includes(book.books_id) ? 'Adding...' : 'Add' }}
                </button>
                
                <button 
                  v-else
                  @click="openUpdateModal(book)" 
                  class="bg-blue-600 hover:bg-blue-700 text-white py-1 px-4 rounded"
                  :disabled="addingIds.includes(book.books_id) || deletingIds.includes(book.books_id)"
                >
                  Update
                </button>
              </div>
            </div>
            
            <div v-if="hasStaticResources(book)" class="mt-2 text-right">
              <button 
                @click="deleteStaticContent(book.books_id)" 
                class="bg-red-600 hover:bg-red-700 text-white py-1 px-3 rounded text-sm"
                :disabled="deletingIds.includes(book.books_id) || addingIds.includes(book.books_id)"
              >
                {{ deletingIds.includes(book.books_id) ? 'Deleting...' : 'Delete Resources' }}
              </button>
            </div>
          </div>
        </div>
      </div>
      
      <!-- Search Results Stats -->
      <div v-if="isSearchActive && filteredBooks.length > 0" class="mt-4 text-sm text-gray-600">
        Found {{ filteredBooks.length }} results for "{{ searchQuery }}"
        <button 
          @click="clearSearch" 
          class="ml-2 text-blue-600 hover:underline"
        >
          Clear
        </button>
      </div>
      
      <!-- Pagination -->
      <div v-if="totalPages > 1" class="flex justify-center mt-8">
        <div class="flex space-x-2">
          <button 
            @click="changePage(currentPage - 1)" 
            class="px-3 py-1 rounded border"
            :class="currentPage === 1 ? 'bg-gray-100 text-gray-400 cursor-not-allowed' : 'bg-white hover:bg-gray-100'"
            :disabled="currentPage === 1"
          >
            &laquo; Prev
          </button>
          
          <template v-for="page in totalPages" :key="page">
            <button 
              v-if="shouldShowPage(page)"
              @click="changePage(page)"
              class="px-3 py-1 rounded border"
              :class="currentPage === page ? 'bg-blue-600 text-white' : 'bg-white hover:bg-gray-100'"
            >
              {{ page }}
            </button>
            
            <span v-else-if="page === ellipsisAfter || page === ellipsisBefore" class="px-3 py-1">
              ...
            </span>
          </template>
          
          <button 
            @click="changePage(currentPage + 1)" 
            class="px-3 py-1 rounded border"
            :class="currentPage === totalPages ? 'bg-gray-100 text-gray-400 cursor-not-allowed' : 'bg-white hover:bg-gray-100'"
            :disabled="currentPage === totalPages"
          >
            Next &raquo;
          </button>
        </div>
      </div>
    </div>
    
    <!-- Update Modal -->
    <div v-if="showModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-md">
        <h2 class="text-xl font-bold mb-4">Update Static Content</h2>
        
        <div class="mb-4">
          <label class="block text-gray-700 text-sm font-bold mb-2" for="pictureUrl">
            Picture URL
          </label>
          <input 
            id="pictureUrl" 
            v-model="updateData.pictureUrl" 
            class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
            type="text" 
            placeholder="Enter picture URL"
          />
        </div>
        
        <div class="mb-4">
          <label class="block text-gray-700 text-sm font-bold mb-2" for="downloadUrl">
            Download URL
          </label>
          <input 
            id="downloadUrl" 
            v-model="updateData.downloadUrl" 
            class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
            type="text" 
            placeholder="Enter download URL"
          />
        </div>
        
        <div class="flex justify-end">
          <button 
            @click="closeModal" 
            class="bg-gray-500 hover:bg-gray-700 text-white py-2 px-4 rounded mr-2"
          >
            Cancel
          </button>
          <button 
            @click="updateStaticContent" 
            class="bg-blue-600 hover:bg-blue-700 text-white py-2 px-4 rounded"
            :disabled="updating"
          >
            {{ updating ? 'Updating...' : 'Update' }}
          </button>
        </div>
      </div>
    </div>
    
    <!-- Notification -->
    <div 
      v-if="notification.show" 
      class="fixed bottom-4 right-4 p-4 rounded-md shadow-md"
      :class="notification.type === 'success' ? 'bg-green-500 text-white' : 'bg-red-500 text-white'"
    >
      {{ notification.message }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'StaticPage',
  data() {
    return {
      books: [],
      loading: true,
      error: null,
      addingIds: [], // Tracks which books are currently being added
      deletingIds: [], // Tracks which books are currently being deleted
      notification: {
        show: false,
        message: '',
        type: 'success'
      },
      showModal: false,
      updating: false,
      updateData: {
        bookId: null,
        pictureUrl: '',
        downloadUrl: ''
      },
      // Pagination
      currentPage: 1,
      itemsPerPage: 10,
      maxPagesToShow: 5,
      // Search
      searchQuery: '',
      searchField: 'all',
      debouncedSearchTimeout: null
    }
  },
  computed: {
    isSearchActive() {
      return this.searchQuery.trim() !== ''
    },
    filteredBooks() {
      if (!this.isSearchActive) return this.books
      
      const query = this.searchQuery.toLowerCase().trim()
      
      return this.books.filter(book => {
        if (this.searchField === 'all') {
          return (
            book.name.toLowerCase().includes(query) ||
            book.author_name.toLowerCase().includes(query) ||
            book.category.toLowerCase().includes(query)
          )
        } else {
          return book[this.searchField].toLowerCase().includes(query)
        }
      })
    },
    totalPages() {
      return Math.ceil(this.filteredBooks.length / this.itemsPerPage)
    },
    paginatedBooks() {
      const start = (this.currentPage - 1) * this.itemsPerPage
      const end = start + this.itemsPerPage
      return this.filteredBooks.slice(start, end)
    },
    // For ellipsis logic in pagination
    ellipsisBefore() {
      return Math.ceil(this.maxPagesToShow / 2)
    },
    ellipsisAfter() {
      return this.totalPages - Math.floor(this.maxPagesToShow / 2) + 1
    }
  },
  watch: {
    filteredBooks() {
      // Reset to first page when search results change
      this.currentPage = 1
    }
  },
  created() {
    this.fetchBooks()
  },
  methods: {
    async fetchBooks() {
      try {
        this.loading = true
        const response = await fetch('http://localhost:5000/books')
        
        if (!response.ok) {
          throw new Error(`Failed to fetch books: ${response.status} ${response.statusText}`)
        }
        
        this.books = await response.json()
        this.loading = false
      } catch (error) {
        console.error('Error fetching books:', error)
        this.error = 'Failed to load books. Please try again later.'
        this.loading = false
      }
    },
    
    // Search Methods
    handleSearch() {
      // Debounce search for better performance
      clearTimeout(this.debouncedSearchTimeout)
      this.debouncedSearchTimeout = setTimeout(() => {
        // The search happens automatically via computed properties
      }, 300)
    },
    
    clearSearch() {
      this.searchQuery = ''
      this.searchField = 'all'
      this.currentPage = 1
    },
    
    // Pagination Methods
    changePage(page) {
      if (page >= 1 && page <= this.totalPages) {
        this.currentPage = page
        // Scroll to top when changing pages
        window.scrollTo(0, 0)
      }
    },
    
    shouldShowPage(page) {
      // Always show first and last page
      if (page === 1 || page === this.totalPages) {
        return true
      }
      
      // Show pages around current page
      if (
        (page >= this.currentPage - 1 && page <= this.currentPage + 1) ||
        (this.currentPage <= 3 && page <= 5) ||
        (this.currentPage >= this.totalPages - 2 && page >= this.totalPages - 4)
      ) {
        return true
      }
      
      return false
    },
    
    async addStaticContent(bookId) {
      if (this.addingIds.includes(bookId) || this.deletingIds.includes(bookId)) return
      
      this.addingIds.push(bookId)
      try {
        const response = await fetch(`http://localhost:5000/books/static/add/${bookId}`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({}) // Empty JSON body as specified
        })
        
        if (!response.ok) {
          throw new Error(`Failed to add static content: ${response.status} ${response.statusText}`)
        }
        
        // Refresh books to get updated data
        await this.fetchBooks()
        
        // Show success notification
        this.showNotification('Static content added successfully!', 'success')
      } catch (error) {
        console.error('Error adding static content:', error)
        this.showNotification('Failed to add static content. Please try again.', 'error')
      } finally {
        // Remove bookId from addingIds
        const index = this.addingIds.indexOf(bookId)
        if (index > -1) {
          this.addingIds.splice(index, 1)
        }
      }
    },
    
    openUpdateModal(book) {
      this.updateData = {
        bookId: book.books_id,
        pictureUrl: book.static_resources?.picture_url || '',
        downloadUrl: book.static_resources?.download_url || ''
      }
      this.showModal = true
    },
    
    closeModal() {
      this.showModal = false
      this.updateData = {
        bookId: null,
        pictureUrl: '',
        downloadUrl: ''
      }
    },
    
    async updateStaticContent() {
      if (!this.updateData.bookId) return
      
      this.updating = true
      try {
        const response = await fetch(`http://localhost:5000/books/static/update/${this.updateData.bookId}`, {
          method: 'PUT',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            picture_url: this.updateData.pictureUrl,
            download_url: this.updateData.downloadUrl
          })
        })
        
        if (!response.ok) {
          throw new Error(`Failed to update static content: ${response.status} ${response.statusText}`)
        }
        
        // Refresh books to get updated data
        await this.fetchBooks()
        
        // Show success notification
        this.showNotification('Static content updated successfully!', 'success')
        
        // Close the modal
        this.closeModal()
      } catch (error) {
        console.error('Error updating static content:', error)
        this.showNotification('Failed to update static content. Please try again.', 'error')
      } finally {
        this.updating = false
      }
    },
    
    async deleteStaticContent(bookId) {
      if (this.deletingIds.includes(bookId) || this.addingIds.includes(bookId)) return
      
      // Confirm deletion
      if (!confirm('Are you sure you want to delete the static resources for this book?')) {
        return
      }
      
      this.deletingIds.push(bookId)
      try {
        const response = await fetch(`http://localhost:5000/books/static/delete/${bookId}`, {
          method: 'DELETE'
        })
        
        if (!response.ok) {
          throw new Error(`Failed to delete static content: ${response.status} ${response.statusText}`)
        }
        
        // Refresh books to get updated data
        await this.fetchBooks()
        
        // Show success notification
        this.showNotification('Static resources deleted successfully!', 'success')
      } catch (error) {
        console.error('Error deleting static content:', error)
        this.showNotification('Failed to delete static resources. Please try again.', 'error')
      } finally {
        // Remove bookId from deletingIds
        const index = this.deletingIds.indexOf(bookId)
        if (index > -1) {
          this.deletingIds.splice(index, 1)
        }
      }
    },
    
    showNotification(message, type = 'success') {
      this.notification = {
        show: true,
        message,
        type
      }
      
      // Hide notification after 3 seconds
      setTimeout(() => {
        this.notification.show = false
      }, 3000)
    },
    
    handleImageError(event) {
      // Replace broken images with a placeholder
      event.target.src = 'https://via.placeholder.com/400x300?text=No+Image'
    },
    
    // Helper to check if a book has static resources
    hasStaticResources(book) {
      return book && book.static_resources !== null && typeof book.static_resources === 'object'
    },
    
    // Helper to get appropriate image URL
    getBookImageUrl(book) {
      if (this.hasStaticResources(book) && book.static_resources.picture_url) {
        return book.static_resources.picture_url
      }
      return 'https://via.placeholder.com/400x300?text=No+Image'
    }
  }
}
</script>

<style scoped>
.static-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}

.book-card {
  transition: transform 0.2s;
}

.book-card:hover {
  transform: translateY(-5px);
}
</style>
