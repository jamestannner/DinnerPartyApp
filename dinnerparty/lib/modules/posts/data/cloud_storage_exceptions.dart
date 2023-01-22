class CloudStorageException implements Exception {
  const CloudStorageException();
}

class CouldNotCreatePostException extends CloudStorageException {}

class CouldNotGetAllPostsException extends CloudStorageException {}

class CouldNotUpdatePostException extends CloudStorageException {}

class CouldNotDeletePostException extends CloudStorageException {}

