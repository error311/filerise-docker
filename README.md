## multi-file-upload-editor-docker

  # dockerfile
  
  Install Apache, PHP, and required packages
  
  adds multi file upload editor to /var/www directory (https://github.com/error311/multi-file-upload-editor)

  # start.sh
  
  Permissions changes 
  
  Allows configuration changes with env variables for apache & multi file upload editor

  # changelog:

  **Changes 3/7/2025:**

- **Module Separation & ES6 Conversion**  
  - networkUtils.js: For handling HTTP requests.  
  - domUtils.js: For DOM manipulation functions (e.g. toggleVisibility, escapeHTML, toggleAllCheckboxes, and file action button updates).  
  - fileManager.js: For file operations, rendering the file list, sorting, editing, renaming, and pagination.  
  - folderManager.js: For folder-related operations (loading folder lists, renaming/deleting folders, etc.).  
  - upload.js: For handling file uploads and progress display.  
  - auth.js: For authentication and user management.  
  - Converted all modules to ES6  

- **File List Rendering & Pagination in fileManager.js**  
  - Implemented Pagination  
  - Added global settings (window.itemsPerPage and window.currentPage) with defaults (10 items per page).  
  - Modified renderFileTable() to calculate the current slice of files and render pagination controls (with “Prev”/“Next” buttons and an items-per-page selector).  
  - Reworked Sorting  
  - updated sortFiles() to re-render the table on sorting.  
  - Implemented sorting for non-date columns by converting strings to lowercase.  
  - Date sorting improvements  

- **File Upload Enhancements in upload.js**  
  - Maintained individual progress tracking for the first 10 files while still uploading all selected files.  
  - Implemented logic to refresh the file list instantly after uploads finish.  
  - Configured the progress list to remain visible for 10 seconds after the file list refresh so users can verify the upload status.  
  - Ensured that after refreshing the file list, event listeners for actions (delete, copy, move) are reattached.  
  - File upload error handling and display  

- **File Action Buttons & Checkbox Handling (domUtils.js and fileManager.js)**  
  - Rewrote the updateFileActionButtons()  
  - Removed duplicate or conflicting logic from renderFileTable() and initFileActions() that previously managed button visibility.  
  - Adjusted toggleAllCheckboxes() and toggleDeleteButton() so they call updateFileActionButtons() to maintain a single source of truth.  

- **Rename Functionality**  
  - Updated the Actions column in the file table to always include a “Rename” button for each file.  
  - Implemented renameFile()  

- **Responsive Behavior & Additional UI Tweaks**  
  - Added CSS media queries to hide less critical columns (Date Modified, Upload Date, File Size, Uploader) on smaller screens.  
  - Adjusted margins on file preview images and file icons.  
  - Improved header centering and button styling.  

 **Changes 3/4/2025:**  
  - Copy & Move functionality added  
  - Header Layout  
  - Modal Popups (Edit, Add User, Remove User) changes  
  - Consolidated table styling  
  - CSS Consolidation  
  - assets folder  
  - additional changes and fixes   

**Changes 3/3/2025:**  
  - folder management added  
  - some refactoring  
  - config added USERS_DIR & USERS_FILE  
