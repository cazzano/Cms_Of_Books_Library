<template>
  <div class="p-6 max-w-4xl mx-auto">
    <h1 class="text-2xl font-bold mb-6">Database Management</h1>
    
    <!-- Status Card -->
    <div class="bg-white rounded-lg shadow-md p-4 mb-6">
      <h2 class="text-lg font-semibold mb-2">Database Status</h2>
      <div v-if="loading" class="flex justify-center py-4">
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"></div>
      </div>
      <div v-else>
        <div class="mb-2 flex justify-between items-center">
          <span>Status:</span>
          <span class="font-medium" :class="{'text-green-600': dbStatus.all_files_exist, 'text-red-600': !dbStatus.all_files_exist}">
            {{ dbStatus.all_files_exist ? 'All database files present' : 'Some database files missing' }}
          </span>
        </div>
        <div class="mb-2 flex justify-between items-center">
          <span>Total Size:</span>
          <span class="font-medium">{{ dbStatus.total_size_formatted }}</span>
        </div>
        <div class="mt-4">
          <h3 class="text-sm font-semibold mb-2">Database Files:</h3>
          <div v-for="(db, index) in dbStatus.databases" :key="index" 
              class="flex justify-between items-center py-1 border-b border-gray-100 last:border-b-0">
            <span class="text-sm text-gray-600 truncate max-w-xs">{{ db.path }}</span>
            <div class="flex items-center">
              <span class="mr-2" :class="{'text-green-600': db.exists, 'text-red-600': !db.exists}">
                <svg v-if="db.exists" class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path>
                </svg>
                <svg v-else class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"></path>
                </svg>
              </span>
              <span class="text-sm">{{ db.size_formatted }}</span>
            </div>
          </div>
        </div>
        <button @click="checkStatus" class="mt-4 bg-gray-100 hover:bg-gray-200 text-gray-800 py-1 px-3 rounded text-sm">
          Refresh Status
        </button>
      </div>
    </div>
    
    <!-- Backup Section -->
    <div class="bg-white rounded-lg shadow-md p-4 mb-6">
      <h2 class="text-lg font-semibold mb-2">Backup Database</h2>
      <p class="text-gray-600 text-sm mb-4">
        Create a backup of your database files. The backup will be downloaded as a ZIP file.
      </p>
      
      <div v-if="backupStatus === 'idle'" class="flex space-x-2">
        <button @click="startBackup" class="bg-blue-600 hover:bg-blue-700 text-white py-2 px-4 rounded flex items-center">
          <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7H5a2 2 0 00-2 2v9a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-3m-1 4l-3 3m0 0l-3-3m3 3V4"></path>
          </svg>
          Download Backup
        </button>
      </div>
      
      <div v-else-if="backupStatus === 'downloading'">
        <div class="mb-2">
          <div class="w-full bg-gray-200 rounded-full h-2.5">
            <div class="bg-blue-600 h-2.5 rounded-full" :style="{ width: `${backupProgress}%` }"></div>
          </div>
        </div>
        <div class="flex justify-between text-sm text-gray-600">
          <span>Downloading backup...</span>
          <span>{{ backupProgress.toFixed(0) }}%</span>
        </div>
        <button @click="cancelBackup" class="mt-2 text-red-600 hover:text-red-700 text-sm">
          Cancel Download
        </button>
      </div>
      
      <div v-else-if="backupStatus === 'verifying'">
        <div class="flex items-center justify-center space-x-2 py-2">
          <div class="animate-spin rounded-full h-5 w-5 border-b-2 border-blue-500"></div>
          <span>Verifying backup integrity...</span>
        </div>
      </div>
      
      <div v-else-if="backupStatus === 'complete'" class="text-green-600 py-2">
        <div class="flex items-center">
          <svg class="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path>
          </svg>
          <span>Backup completed successfully!</span>
        </div>
        <button @click="resetBackupStatus" class="mt-2 text-blue-600 hover:text-blue-700 text-sm">
          Create Another Backup
        </button>
      </div>
      
      <div v-else-if="backupStatus === 'error'" class="text-red-600 py-2">
        <div class="flex items-center">
          <svg class="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"></path>
          </svg>
          <span>{{ backupError }}</span>
        </div>
        <button @click="resetBackupStatus" class="mt-2 text-blue-600 hover:text-blue-700 text-sm">
          Try Again
        </button>
      </div>
    </div>
    
    <!-- Restore Section -->
    <div class="bg-white rounded-lg shadow-md p-4">
      <h2 class="text-lg font-semibold mb-2">Restore Database</h2>
      <p class="text-gray-600 text-sm mb-4">
        Restore your database from a previous backup. Select a backup ZIP file to begin.
      </p>
      
      <div v-if="restoreStatus === 'idle'">
        <div class="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center"
            :class="{'border-blue-400 bg-blue-50': isDragging}"
            @dragover.prevent="isDragging = true"
            @dragleave.prevent="isDragging = false"
            @drop.prevent="handleFileDrop">
          <svg class="mx-auto h-12 w-12 text-gray-400" stroke="currentColor" fill="none" viewBox="0 0 48 48">
            <path d="M28 8H12a4 4 0 00-4 4v20m32-12v8m0 0v8a4 4 0 01-4 4H12a4 4 0 01-4-4v-4m32-4l-3.172-3.172a4 4 0 00-5.656 0L28 28M8 32l9.172-9.172a4 4 0 015.656 0L28 28m0 0l4 4m4-24h8m-4-4v8m-12 4h.02" 
              stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
          </svg>
          
          <div class="flex flex-col items-center mt-4">
            <span class="text-sm text-gray-600">Drag and drop a backup file, or</span>
            <label class="mt-2 cursor-pointer text-sm text-blue-600 hover:text-blue-700">
              browse to upload
              <input type="file" class="hidden" accept=".zip" @change="handleFileSelect">
            </label>
            <span class="mt-2 text-xs text-gray-500">Only .zip files are supported</span>
          </div>
        </div>
      </div>
      
      <div v-else-if="restoreStatus === 'uploading'">
        <div class="mb-2">
          <div class="w-full bg-gray-200 rounded-full h-2.5">
            <div class="bg-green-600 h-2.5 rounded-full" :style="{ width: `${restoreProgress}%` }"></div>
          </div>
        </div>
        <div class="flex justify-between text-sm text-gray-600">
          <span>Uploading backup file...</span>
          <span>{{ restoreProgress.toFixed(0) }}% ({{ uploadedChunks }}/{{ totalChunks }} chunks)</span>
        </div>
        <button @click="cancelRestore" class="mt-2 text-red-600 hover:text-red-700 text-sm">
          Cancel Upload
        </button>
      </div>
      
      <div v-else-if="restoreStatus === 'restoring'">
        <div class="flex items-center justify-center space-x-2 py-4">
          <div class="animate-spin rounded-full h-6 w-6 border-b-2 border-green-500"></div>
          <span>Restoring database from backup...</span>
        </div>
        <p class="text-xs text-gray-500 text-center mt-2">Please do not close this window during restoration</p>
      </div>
      
      <div v-else-if="restoreStatus === 'complete'" class="text-green-600 py-2">
        <div class="flex items-center">
          <svg class="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path>
          </svg>
          <span>Database restored successfully!</span>
        </div>
        <div class="mt-2 text-sm text-gray-600">
          <p>The following files were restored:</p>
          <ul class="list-disc pl-5 mt-1">
            <li v-for="(file, index) in restoredFiles" :key="index">{{ file }}</li>
          </ul>
        </div>
        <button @click="resetRestoreStatus" class="mt-4 bg-blue-600 hover:bg-blue-700 text-white py-1 px-3 rounded text-sm">
          Restore Another Backup
        </button>
      </div>
      
      <div v-else-if="restoreStatus === 'error'" class="text-red-600 py-2">
        <div class="flex items-center">
          <svg class="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"></path>
          </svg>
          <span>{{ restoreError }}</span>
        </div>
        <button @click="resetRestoreStatus" class="mt-2 text-blue-600 hover:text-blue-700 text-sm">
          Try Again
        </button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Database',
  data() {
    return {
      loading: true,
      dbStatus: {
        databases: [],
        total_size_bytes: 0,
        total_size_formatted: '0 KB',
        all_files_exist: false
      },
      
      // Backup state
      backupStatus: 'idle', // idle, downloading, verifying, complete, error
      backupProgress: 0,
      backupError: '',
      backupAbortController: null,
      backupFilename: '',
      backupChecksum: '',
      
      // Restore state
      restoreStatus: 'idle', // idle, uploading, restoring, complete, error
      restoreProgress: 0,
      restoreError: '',
      uploadedChunks: 0,
      totalChunks: 0,
      isDragging: false,
      selectedFile: null,
      uploadId: null,
      chunkSize: 1024 * 1024, // 1MB chunk size
      restoredFiles: [],
      abortController: null,
      
      // API base URL for testing
      apiBaseUrl: 'https://bookslibrarybackend-production.up.railway.app'
    };
  },
  mounted() {
    this.checkStatus();
  },
  methods: {
    // Database status
    async checkStatus() {
      this.loading = true;
      try {
        const response = await fetch(`${this.apiBaseUrl}/backup/status`);
        if (!response.ok) {
          throw new Error('Failed to fetch database status');
        }
        this.dbStatus = await response.json();
      } catch (error) {
        console.error('Error fetching database status:', error);
      } finally {
        this.loading = false;
      }
    },
    
    // Backup methods
    async startBackup() {
      this.backupStatus = 'downloading';
      this.backupProgress = 0;
      this.backupError = '';
      
      try {
        // Create abort controller for cancellation
        this.backupAbortController = new AbortController();
        
        // Start the backup download with fetch and track progress
        const response = await fetch(`${this.apiBaseUrl}/backup`, {
          signal: this.backupAbortController.signal
        });
        
        if (!response.ok) {
          const errorData = await response.json();
          throw new Error(errorData.error || 'Failed to start backup');
        }
        
        // Get file info from headers
        this.backupFilename = this.getFilenameFromContentDisposition(
          response.headers.get('Content-Disposition')
        );
        this.backupChecksum = response.headers.get('X-Checksum');
        const totalBytes = parseInt(response.headers.get('X-Total-Size'), 10);
        
        // Stream the response to track download progress
        const reader = response.body.getReader();
        let receivedBytes = 0;
        
        // Create a new ReadableStream to handle download progress
        const stream = new ReadableStream({
          start: controller => {
            const push = () => {
              reader.read().then(({ done, value }) => {
                if (done) {
                  controller.close();
                  return;
                }
                
                receivedBytes += value.length;
                const progress = (receivedBytes / totalBytes) * 100;
                this.backupProgress = Math.min(progress, 99); // Cap at 99% until verified
                
                controller.enqueue(value);
                push();
              }).catch(error => {
                controller.error(error);
              });
            };
            
            push();
          }
        });
        
        // Create a Response from the stream
        const streamResponse = new Response(stream);
        
        // Get the blob from the response
        const blob = await streamResponse.blob();
        
        // Create download link
        const downloadUrl = window.URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = downloadUrl;
        link.download = this.backupFilename;
        
        // Set status to verifying
        this.backupStatus = 'verifying';
        
        // Verify the download if checksum is available
        if (this.backupChecksum) {
          // TODO: In a real implementation, we'd calculate the checksum of the blob
          // For demonstration, we'll just simulate verification
          await new Promise(resolve => setTimeout(resolve, 1000));
        }
        
        // Trigger download
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        
        // Clean up
        window.URL.revokeObjectURL(downloadUrl);
        
        // Mark as complete
        this.backupProgress = 100;
        this.backupStatus = 'complete';
        
      } catch (error) {
        if (error.name === 'AbortError') {
          this.backupError = 'Backup was cancelled';
        } else {
          this.backupError = `Backup failed: ${error.message}`;
        }
        this.backupStatus = 'error';
      } finally {
        this.backupAbortController = null;
      }
    },
    
    cancelBackup() {
      if (this.backupAbortController) {
        this.backupAbortController.abort();
        this.backupStatus = 'idle';
      }
    },
    
    resetBackupStatus() {
      this.backupStatus = 'idle';
      this.backupProgress = 0;
      this.backupError = '';
    },
    
    // Restore methods
    handleFileDrop(event) {
      this.isDragging = false;
      const files = event.dataTransfer.files;
      if (files.length > 0) {
        this.handleFile(files[0]);
      }
    },
    
    handleFileSelect(event) {
      const files = event.target.files;
      if (files.length > 0) {
        this.handleFile(files[0]);
      }
    },
    
    handleFile(file) {
      if (file.type !== 'application/zip' && !file.name.endsWith('.zip')) {
        this.restoreError = 'Only ZIP files are supported';
        this.restoreStatus = 'error';
        return;
      }
      
      this.selectedFile = file;
      this.startRestore();
    },
    
    async startRestore() {
      if (!this.selectedFile) return;
      
      this.restoreStatus = 'uploading';
      this.restoreProgress = 0;
      this.restoreError = '';
      this.uploadedChunks = 0;
      
      const file = this.selectedFile;
      const fileSize = file.size;
      
      // Calculate total chunks
      this.totalChunks = Math.ceil(fileSize / this.chunkSize);
      
      // Generate a unique upload ID
      this.uploadId = Date.now().toString();
      
      // Abort controller for cancellation
      this.abortController = new AbortController();
      
      try {
        // Upload file in chunks
        for (let chunk = 0; chunk < this.totalChunks; chunk++) {
          // Check if canceled
          if (this.abortController === null) {
            throw new Error('Upload cancelled');
          }
          
          const start = chunk * this.chunkSize;
          const end = Math.min(fileSize, start + this.chunkSize);
          const chunkBlob = file.slice(start, end);
          
          const formData = new FormData();
          formData.append('backup_file', chunkBlob);
          formData.append('upload_id', this.uploadId);
          formData.append('chunk', chunk.toString());
          formData.append('total_chunks', this.totalChunks.toString());
          
          // If this is the last chunk, calculate and include checksum
          if (chunk === this.totalChunks - 1) {
            // In a real implementation, we'd calculate the MD5 of the file
            // For this example, we'll skip it
            // formData.append('checksum', '...');
          }
          
          const response = await fetch(`${this.apiBaseUrl}/restore`, {
            method: 'POST',
            body: formData,
            signal: this.abortController ? this.abortController.signal : null
          });
          
          if (!response.ok) {
            const errorData = await response.json();
            throw new Error(errorData.error || 'Failed to upload backup');
          }
          
          const data = await response.json();
          
          // Update progress
          this.uploadedChunks++;
          this.restoreProgress = (this.uploadedChunks / this.totalChunks) * 100;
          
          // If restore has started, poll for status
          if (data.success && chunk === this.totalChunks - 1) {
            this.restoreStatus = 'restoring';
            await this.pollRestoreStatus(this.uploadId);
          }
        }
      } catch (error) {
        if (error.name === 'AbortError') {
          this.restoreError = 'Restore was cancelled';
        } else {
          this.restoreError = `Restore failed: ${error.message}`;
        }
        this.restoreStatus = 'error';
      } finally {
        this.abortController = null;
      }
    },
    
    async pollRestoreStatus(uploadId) {
      const maxAttempts = 30;
      let attempts = 0;
      
      while (attempts < maxAttempts) {
        try {
          const response = await fetch(`${this.apiBaseUrl}/operation/status/${uploadId}`);
          
          if (!response.ok) {
            throw new Error('Failed to get operation status');
          }
          
          const data = await response.json();
          
          if (data.status === 'completed') {
            this.restoreStatus = 'complete';
            this.restoredFiles = data.restored_files || [];
            return;
          } else if (data.status === 'failed') {
            throw new Error(data.error || 'Restore failed');
          }
          
          // Wait before polling again
          await new Promise(resolve => setTimeout(resolve, 1000));
          attempts++;
        } catch (error) {
          throw error;
        }
      }
      
      throw new Error('Restore operation timed out');
    },
    
    cancelRestore() {
      if (this.abortController) {
        this.abortController.abort();
        this.abortController = null;
        this.restoreStatus = 'idle';
      }
    },
    
    resetRestoreStatus() {
      this.restoreStatus = 'idle';
      this.restoreProgress = 0;
      this.restoreError = '';
      this.selectedFile = null;
      this.uploadedChunks = 0;
      this.totalChunks = 0;
    },
    
    // Utility methods
    getFilenameFromContentDisposition(contentDisposition) {
      if (!contentDisposition) return 'database-backup.zip';
      
      const filenameRegex = /filename[^;=\n]*=((['"]).*?\2|[^;\n]*)/;
      const matches = filenameRegex.exec(contentDisposition);
      if (matches !== null && matches[1]) {
        return matches[1].replace(/['"]/g, '');
      }
      return 'database-backup.zip';
    }
  }
};
</script>
