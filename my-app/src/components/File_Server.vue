<template>
  <div class="max-w-6xl mx-auto p-4 md:p-6">
    <div class="text-center mb-8">
      <h1 class="text-4xl font-bold text-gray-800 mb-2">File Server</h1>
      <p class="text-xl text-gray-600">Manage your files and backups</p>
    </div>
    
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
      <!-- Backup & Restore Card -->
      <div class="bg-white rounded-lg shadow-md p-6">
        <h2 class="text-2xl font-semibold text-gray-800 mb-4">Database Management</h2>
        
        <!-- Backup Section -->
        <div class="mb-6">
          <h3 class="text-lg font-medium text-gray-700 mb-2">Backup</h3>
          <p class="text-gray-600 mb-4">Download a complete backup of all files in the database</p>
          
          <!-- Backup Options -->
          <div class="mb-4">
            <div class="flex items-center mb-2">
              <input 
                type="radio" 
                id="standardBackup" 
                name="backupOption" 
                value="standard" 
                v-model="backupOption"
                class="mr-2"
              />
              <label for="standardBackup" class="text-sm text-gray-700">Standard Backup (Streaming)</label>
            </div>
            <div class="flex items-center">
              <input 
                type="radio" 
                id="asyncBackup" 
                name="backupOption" 
                value="async" 
                v-model="backupOption"
                class="mr-2"
              />
              <label for="asyncBackup" class="text-sm text-gray-700">Asynchronous Backup (For slow connections)</label>
            </div>
          </div>
          
          <button 
            @click="downloadBackup" 
            :disabled="isDownloading" 
            class="bg-green-600 hover:bg-green-700 disabled:bg-gray-400 text-white py-2 px-4 rounded-md transition-colors"
          >
            <span v-if="isDownloading">Downloading...</span>
            <span v-else>Download Backup</span>
          </button>
          
          <div 
            v-if="backupStatus" 
            class="mt-4 p-3 rounded-md text-sm"
            :class="{
              'bg-blue-100 text-blue-800': backupStatus.type === 'info',
              'bg-green-100 text-green-800': backupStatus.type === 'success',
              'bg-red-100 text-red-800': backupStatus.type === 'error'
            }"
          >
            {{ backupStatus.message }}
          </div>
          
          <!-- Async Backup Status Check -->
          <div v-if="backupOperationId" class="mt-4">
            <div v-if="backupOperation && backupOperation.status === 'processing'" class="flex items-center">
              <div class="mr-2 animate-spin rounded-full h-4 w-4 border-b-2 border-blue-500"></div>
              <span class="text-sm text-gray-600">Processing backup ({{ Math.round(backupOperation.progress || 0) }}%)...</span>
            </div>
            <button 
              v-if="backupOperation && backupOperation.status === 'completed'"
              @click="downloadAsyncBackup"
              class="mt-2 bg-blue-600 hover:bg-blue-700 text-white py-1 px-3 rounded-md text-sm transition-colors"
            >
              Download Ready Backup
            </button>
          </div>
        </div>
        
        <!-- Restore Section -->
        <div class="pt-4 border-t border-gray-200">
          <h3 class="text-lg font-medium text-gray-700 mb-2">Restore</h3>
          <p class="text-gray-600 mb-4">Restore the database from a backup file</p>
          
          <!-- Restore Options -->
          <div class="mb-4">
            <div class="flex items-center mb-2">
              <input 
                type="radio" 
                id="standardRestore" 
                name="restoreOption" 
                value="standard" 
                v-model="restoreOption"
                class="mr-2"
              />
              <label for="standardRestore" class="text-sm text-gray-700">Standard Upload (Small files)</label>
            </div>
            <div class="flex items-center">
              <input 
                type="radio" 
                id="chunkedRestore" 
                name="restoreOption" 
                value="chunked" 
                v-model="restoreOption"
                class="mr-2"
              />
              <label for="chunkedRestore" class="text-sm text-gray-700">Chunked Upload (Large files/slow connections)</label>
            </div>
          </div>
          
          <div class="flex flex-col sm:flex-row gap-4">
            <label class="block flex-grow">
              <span class="sr-only">Choose backup file</span>
              <input 
                type="file" 
                ref="fileInput"
                @change="handleFileChange" 
                accept=".zip"
                class="block w-full text-sm text-gray-500
                  file:mr-4 file:py-2 file:px-4
                  file:rounded-md file:border-0
                  file:text-sm file:font-medium
                  file:bg-gray-100 file:text-gray-700
                  hover:file:bg-gray-200"
              />
            </label>
            <button 
              @click="restoreBackup" 
              :disabled="isRestoring || !selectedFile" 
              class="bg-blue-600 hover:bg-blue-700 disabled:bg-gray-400 text-white py-2 px-4 rounded-md transition-colors"
            >
              <span v-if="isRestoring">Restoring...</span>
              <span v-else>Restore</span>
            </button>
          </div>
          
          <div v-if="restoreProgress > 0 && restoreProgress < 100" class="mt-4">
            <div class="w-full bg-gray-200 rounded-full h-2.5">
              <div class="bg-blue-600 h-2.5 rounded-full" :style="{ width: `${restoreProgress}%` }"></div>
            </div>
            <p class="text-sm text-gray-600 mt-1">Uploading: {{ restoreProgress.toFixed(0) }}%</p>
          </div>
          
          <div 
            v-if="restoreStatus" 
            class="mt-4 p-3 rounded-md text-sm"
            :class="{
              'bg-blue-100 text-blue-800': restoreStatus.type === 'info',
              'bg-green-100 text-green-800': restoreStatus.type === 'success',
              'bg-red-100 text-red-800': restoreStatus.type === 'error'
            }"
          >
            {{ restoreStatus.message }}
          </div>
        </div>
      </div>
      
      <!-- File Management Card -->
      <div class="bg-white rounded-lg shadow-md p-6">
        <h2 class="text-2xl font-semibold text-gray-800 mb-4">File Management</h2>
        
        <!-- Tabs -->
        <div class="border-b border-gray-200 mb-6">
          <nav class="flex space-x-6">
            <button 
              @click="activeTab = 'pictures'" 
              class="py-2 px-1 font-medium text-sm border-b-2 transition-colors"
              :class="activeTab === 'pictures' ? 'border-green-500 text-green-600' : 'border-transparent text-gray-500 hover:text-gray-700'"
            >
              Pictures
            </button>
            <button 
              @click="activeTab = 'downloads'" 
              class="py-2 px-1 font-medium text-sm border-b-2 transition-colors"
              :class="activeTab === 'downloads' ? 'border-green-500 text-green-600' : 'border-transparent text-gray-500 hover:text-gray-700'"
            >
              Downloads
            </button>
          </nav>
        </div>
        
        <!-- Loading State -->
        <div v-if="loading" class="text-center py-8 text-gray-500">
          Loading files...
        </div>
        
        <!-- Empty State -->
        <div v-else-if="files.length === 0" class="text-center py-8 text-gray-500">
          No files found in this category
        </div>
        
        <!-- File List -->
        <div v-else class="overflow-y-auto max-h-96">
          <div v-for="file in files" :key="file.filename" class="py-3 border-b border-gray-100 last:border-0">
            <div class="flex justify-between items-center">
              <div>
                <div class="font-medium text-gray-800">{{ file.filename }}</div>
                <div class="text-sm text-gray-500">{{ formatFileSize(file.size) }}</div>
              </div>
              <div class="flex space-x-2">
                <button 
                  @click="viewFile(file)" 
                  class="bg-blue-500 hover:bg-blue-600 text-white px-3 py-1 rounded text-sm"
                >
                  View
                </button>
                <button 
                  @click="deleteFile(file)" 
                  class="bg-red-500 hover:bg-red-600 text-white px-3 py-1 rounded text-sm"
                >
                  Delete
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'FileServer',
  data() {
    return {
      activeTab: 'pictures',
      files: [],
      loading: false,
      
      // Backup state
      isDownloading: false,
      backupStatus: null,
      backupOption: 'standard', // 'standard' or 'async'
      backupOperationId: null,
      backupOperation: null,
      backupOperationCheckInterval: null,
      
      // Restore state
      selectedFile: null,
      isRestoring: false,
      restoreStatus: null,
      restoreProgress: 0,
      restoreOption: 'standard', // 'standard' or 'chunked'
      restoreOperationId: null,
      chunks: [],
      currentChunk: 0,
      totalChunks: 0,
      chunkSize: 1024 * 1024 * 5, // 5MB chunks
      
      // API base URL
      apiBaseUrl: 'https://bookslibraryfileserver-production.up.railway.app'
    }
  },
  watch: {
    activeTab() {
      this.fetchFiles()
    }
  },
  mounted() {
    this.fetchFiles()
  },
  beforeUnmount() {
    this.clearBackupOperationCheck()
  },
  methods: {
    async fetchFiles() {
      this.loading = true
      try {
        const response = await fetch(`${this.apiBaseUrl}/${this.activeTab}`)
        if (response.ok) {
          this.files = await response.json()
        } else {
          console.error('Failed to fetch files:', response.statusText)
        }
      } catch (error) {
        console.error('Error fetching files:', error)
      } finally {
        this.loading = false
      }
    },
    
    // BACKUP METHODS
    async downloadBackup() {
      this.isDownloading = true
      this.backupStatus = { type: 'info', message: 'Starting backup process...' }
      this.clearBackupOperationCheck()
      
      try {
        if (this.backupOption === 'standard') {
          // Standard streaming backup
          await this.downloadStandardBackup()
        } else {
          // Asynchronous backup
          await this.initiateAsyncBackup()
        }
      } catch (error) {
        console.error('Backup failed:', error)
        this.backupStatus = { type: 'error', message: `Backup failed: ${error.message}` }
      } finally {
        this.isDownloading = false
      }
    },
    
    async downloadStandardBackup() {
      this.backupStatus = { type: 'info', message: 'Downloading backup...' }
      
      try {
        // Use the standard GET /backup endpoint for streaming backup
        const response = await fetch(`${this.apiBaseUrl}/backup`, {
          method: 'GET',
          headers: {
            'Accept': 'application/zip'
          }
        })
        
        if (!response.ok) {
          throw new Error(`Server responded with status: ${response.status}`)
        }
        
        // Use streams API for large file downloads if supported
        if (window.ReadableStream && response.body instanceof ReadableStream) {
          // Get the content length if available
          const contentLength = response.headers.get('Content-Length')
          let receivedLength = 0
          const chunks = []
          
          const reader = response.body.getReader()
          
          // Read the stream
          while (true) {
            const { done, value } = await reader.read()
            
            if (done) {
              break
            }
            
            chunks.push(value)
            receivedLength += value.length
            
            // Update progress if content length is known
            if (contentLength) {
              this.backupStatus = { 
                type: 'info', 
                message: `Downloading... ${Math.round(receivedLength / contentLength * 100)}%` 
              }
            }
          }
          
          // Combine all chunks into a single Uint8Array
          const chunksAll = new Uint8Array(receivedLength)
          let position = 0
          for (const chunk of chunks) {
            chunksAll.set(chunk, position)
            position += chunk.length
          }
          
          // Create blob and download
          const blob = new Blob([chunksAll], { type: 'application/zip' })
          this.saveBlob(blob, this.getFilenameFromResponse(response) || 'db_backup.zip')
        } else {
          // Fallback for browsers without stream support
          const blob = await response.blob()
          this.saveBlob(blob, this.getFilenameFromResponse(response) || 'db_backup.zip')
        }
        
        this.backupStatus = { type: 'success', message: 'Backup downloaded successfully!' }
        
        // Clear success message after a delay
        setTimeout(() => {
          this.backupStatus = null
        }, 5000)
      } catch (error) {
        throw error
      }
    },
    
    async initiateAsyncBackup() {
      this.backupStatus = { type: 'info', message: 'Initiating asynchronous backup...' }
      
      try {
        // Request asynchronous backup
        const response = await fetch(`${this.apiBaseUrl}/backup?stream=false`, {
          method: 'GET'
        })
        
        if (!response.ok) {
          throw new Error(`Server responded with status: ${response.status}`)
        }
        
        const data = await response.json()
        this.backupOperationId = data.operation_id
        
        this.backupStatus = { 
          type: 'info', 
          message: 'Backup in progress. You can continue using the application...' 
        }
        
        // Start checking the operation status
        this.startBackupOperationCheck()
      } catch (error) {
        throw error
      }
    },
    
    startBackupOperationCheck() {
      // Check every 2 seconds
      this.backupOperationCheckInterval = setInterval(this.checkBackupOperation, 2000)
    },
    
    clearBackupOperationCheck() {
      if (this.backupOperationCheckInterval) {
        clearInterval(this.backupOperationCheckInterval)
        this.backupOperationCheckInterval = null
      }
    },
    
    async checkBackupOperation() {
      if (!this.backupOperationId) {
        this.clearBackupOperationCheck()
        return
      }
      
      try {
        const response = await fetch(`${this.apiBaseUrl}/operation/${this.backupOperationId}`)
        
        if (!response.ok) {
          throw new Error(`Server responded with status: ${response.status}`)
        }
        
        const data = await response.json()
        this.backupOperation = data
        
        // If operation is complete
        if (data.status === 'completed') {
          this.clearBackupOperationCheck()
          this.backupStatus = { 
            type: 'success', 
            message: 'Backup is ready for download!' 
          }
        } else if (data.status === 'failed') {
          this.clearBackupOperationCheck()
          this.backupStatus = { 
            type: 'error', 
            message: `Backup failed: ${data.error || 'Unknown error'}` 
          }
          this.backupOperationId = null
        }
      } catch (error) {
        console.error('Error checking backup operation:', error)
      }
    },
    
    async downloadAsyncBackup() {
      if (!this.backupOperationId) return
      
      this.isDownloading = true
      this.backupStatus = { type: 'info', message: 'Downloading completed backup...' }
      
      try {
        const response = await fetch(`${this.apiBaseUrl}/operation/${this.backupOperationId}?download=true`, {
          method: 'GET'
        })
        
        if (!response.ok) {
          throw new Error(`Server responded with status: ${response.status}`)
        }
        
        const blob = await response.blob()
        this.saveBlob(blob, 'db_backup.zip')
        
        this.backupStatus = { type: 'success', message: 'Backup downloaded successfully!' }
        
        // Reset backup operation state
        this.backupOperationId = null
        this.backupOperation = null
        
        // Clear success message after a delay
        setTimeout(() => {
          this.backupStatus = null
        }, 5000)
      } catch (error) {
        console.error('Download failed:', error)
        this.backupStatus = { type: 'error', message: `Download failed: ${error.message}` }
      } finally {
        this.isDownloading = false
      }
    },
    
    getFilenameFromResponse(response) {
      // Extract filename from Content-Disposition header
      const contentDisposition = response.headers.get('Content-Disposition')
      if (contentDisposition) {
        const filenameMatch = contentDisposition.match(/filename="?([^"]+)"?/)
        if (filenameMatch && filenameMatch[1]) {
          return filenameMatch[1]
        }
      }
      return null
    },
    
    saveBlob(blob, filename) {
      const url = window.URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.style.display = 'none'
      a.href = url
      a.download = filename
      document.body.appendChild(a)
      a.click()
      window.URL.revokeObjectURL(url)
      document.body.removeChild(a)
    },
    
    // RESTORE METHODS
    handleFileChange(event) {
      const files = event.target.files
      if (files.length > 0) {
        // Only accept zip files
        if (!files[0].name.endsWith('.zip')) {
          this.restoreStatus = { type: 'error', message: 'Please select a valid ZIP file' }
          this.selectedFile = null
          event.target.value = null // Clear the input
          return
        }
        
        this.selectedFile = files[0]
        this.restoreStatus = null
        this.restoreProgress = 0
      } else {
        this.selectedFile = null
      }
    },
    
    async restoreBackup() {
      if (!this.selectedFile) {
        this.restoreStatus = { type: 'error', message: 'Please select a backup file first' }
        return
      }
      
      this.isRestoring = true
      
      try {
        if (this.restoreOption === 'standard') {
          await this.performStandardRestore()
        } else {
          await this.performChunkedRestore()
        }
        
        // Refresh the file list after successful restore
        setTimeout(() => {
          this.fetchFiles()
        }, 1000)
      } catch (error) {
        console.error('Restore failed:', error)
        this.restoreStatus = { type: 'error', message: `Restore failed: ${error.message}` }
      } finally {
        this.isRestoring = false
        this.selectedFile = null
        
        // Reset the file input
        if (this.$refs.fileInput) {
          this.$refs.fileInput.value = null
        }
        
        // Clear success message after a delay
        if (this.restoreStatus && this.restoreStatus.type === 'success') {
          setTimeout(() => {
            this.restoreStatus = null
            this.restoreProgress = 0
          }, 5000)
        }
      }
    },
    
    async performStandardRestore() {
      this.restoreStatus = { type: 'info', message: 'Uploading backup file...' }
      
      // Create form data with the file
      const formData = new FormData()
      formData.append('file', this.selectedFile)
      
      // Use XMLHttpRequest for upload progress tracking
      await new Promise((resolve, reject) => {
        const xhr = new XMLHttpRequest()
        
        // Set up progress tracking
        xhr.upload.onprogress = (event) => {
          if (event.lengthComputable) {
            this.restoreProgress = (event.loaded / event.total) * 100
          }
        }
        
        // Handle completion
        xhr.onload = () => {
          if (xhr.status >= 200 && xhr.status < 300) {
            try {
              const response = JSON.parse(xhr.responseText)
              resolve(response)
            } catch (e) {
              reject(new Error('Invalid response from server'))
            }
          } else {
            try {
              const errorResponse = JSON.parse(xhr.responseText)
              reject(new Error(errorResponse.error || `HTTP Error: ${xhr.status}`))
            } catch (e) {
              reject(new Error(`HTTP Error: ${xhr.status}`))
            }
          }
        }
        
        // Handle errors
        xhr.onerror = () => {
          reject(new Error('Network error occurred'))
        }
        
        // Configure and send the request
        xhr.open('POST', `${this.apiBaseUrl}/restore`, true)
        xhr.send(formData)
      })
      
      this.restoreStatus = { type: 'success', message: 'Database restored successfully!' }
      this.restoreProgress = 100
    },
    
    async performChunkedRestore() {
      this.restoreStatus = { type: 'info', message: 'Preparing file for chunked upload...' }
      
      // Prepare the file for chunked upload
      this.prepareChunks()
      
      try {
        // Initialize the chunked upload process
        const initResponse = await fetch(`${this.apiBaseUrl}/restore?chunk=true`, {
          method: 'POST',
          headers: {
            'X-Total-Chunks': this.totalChunks
          }
        })
        
        if (!initResponse.ok) {
          throw new Error(`Failed to initialize chunked upload: ${initResponse.statusText}`)
        }
        
        const initData = await initResponse.json()
        this.restoreOperationId = initData.operation_id
        
        // Upload each chunk
        this.restoreStatus = { type: 'info', message: `Uploading chunk 1 of ${this.totalChunks}...` }
        
        for (let i = 0; i < this.totalChunks; i++) {
          const formData = new FormData()
          formData.append('file', this.chunks[i], `chunk_${i}.bin`)
          
          // Update status
          this.restoreStatus = { 
            type: 'info', 
            message: `Uploading chunk ${i + 1} of ${this.totalChunks}...` 
          }
          
          // Calculate overall progress
          this.restoreProgress = (i / this.totalChunks) * 100
          
          // Upload the chunk
          const chunkResponse = await fetch(
            `${this.apiBaseUrl}/restore?chunk=true&operation_id=${this.restoreOperationId}&chunk_number=${i}`, 
            {
              method: 'POST',
              body: formData
            }
          )
          
          if (!chunkResponse.ok) {
            throw new Error(`Failed to upload chunk ${i + 1}: ${chunkResponse.statusText}`)
          }
        }
        
        // Once all chunks are uploaded, the server should automatically process the complete file
        this.restoreProgress = 100
        this.restoreStatus = { type: 'success', message: 'Database restored successfully!' }
      } catch (error) {
        throw error
      } finally {
        // Clean up chunks
        this.chunks = []
      }
    },
    
    prepareChunks() {
      // Slice the file into chunks
      const file = this.selectedFile
      this.chunks = []
      this.totalChunks = Math.ceil(file.size / this.chunkSize)
      
      for (let i = 0; i < this.totalChunks; i++) {
        const start = i * this.chunkSize
        const end = Math.min(file.size, start + this.chunkSize)
        this.chunks.push(file.slice(start, end))
      }
      
      this.currentChunk = 0
    },
    
    formatFileSize(bytes) {
      if (bytes === 0) return '0 Bytes'
      
      const k = 1024
      const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB']
      const i = Math.floor(Math.log(bytes) / Math.log(k))
      
      return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
    },
    
    viewFile(file) {
      window.open(file.url, '_blank')
    },
    
    async deleteFile(file) {
      if (!confirm(`Are you sure you want to delete ${file.filename}?`)) {
        return
      }
      
      try {
        const response = await fetch(`${this.apiBaseUrl}/${this.activeTab}?filename=${encodeURIComponent(file.filename)}`, {
          method: 'DELETE'
        })
        
        if (response.ok) {
          this.fetchFiles()
        } else {
          const errorData = await response.json().catch(() => ({}))
          const errorMessage = errorData.error || 'Failed to delete file'
          console.error('Failed to delete file:', errorMessage)
          alert(errorMessage)
        }
      } catch (error) {
        console.error('Error deleting file:', error)
        alert('Error deleting file: ' + error.message)
      }
    }
  }
}
</script>
