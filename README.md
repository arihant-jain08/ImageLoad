# ImageLoad
Load and display images in a scrollable grid.
The ViewController class is responsible for managing the main view of the app, which includes a collection view. It fetches image URLs from the API, populates them into the collection view, and handles the lazy loading of images./n
The fetchImageUrlsFromAPI function is called to fetch image URLs from the API. It constructs the API URL with a limit and offset to fetch paginated data. It then makes a network request using URLSession to fetch the data asynchronously.
Once the data is received from the API, it's parsed as JSON, and image URLs are extracted and stored in the imageUrls array. The collection view is then reloaded to display the images.
The ImageManager class handles the caching of images, both in memory (imageCache) and on disk (urlCache). It has a function retrieveImage to load images lazily from the cache or fetch them if not cached.
The ImageCell class represents a cell in the collection view. It contains an image view to display the image and a reference to the task (URLSessionDataTask) responsible for loading the image.
When a cell is reused (prepareForReuse method), any ongoing image loading task is canceled, and the image view is cleared to prepare it for reuse.
