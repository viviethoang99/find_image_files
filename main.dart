import 'dart:io';

void main() async {
  String mainDirectory = "../lib";
  List<String> fileExtensions = [".dart"]; // Các phần mở rộng của file cần tìm kiếm
  List<String> wordsToCount = await getJpgAndPngFiles('../assets'); // Danh sách từ cần thống kê

  print(wordsToCount.length);

  Map<String, int> result = countOccurrences(mainDirectory, fileExtensions, wordsToCount);

  // In ra kết quả thống kê
  print("Những ảnh không được sử dụng:");
  result.forEach((word, count) {
    if (count == 0) print("$word: $count lần");
  });
}

List<String> getJpgAndPngFiles(String directory) {
  List<String> fileNames = [];

  void processDirectory(Directory dir) {
    dir.listSync().forEach((FileSystemEntity entity) {
      if (entity is File) {
        String extension = entity.uri.pathSegments.last.split('.').last.toLowerCase();
        if (extension == 'jpg' || extension == 'png' || extension == 'webp') {
          fileNames.add(entity.path.replaceFirst('../', ''));
        }
      } else if (entity is Directory) {
        processDirectory(entity);
      }
    });
  }

  Directory rootDir = Directory(directory);
  processDirectory(rootDir);

  return fileNames;
}

Map<String, int> countOccurrences(String directory, List<String> fileExtensions, List<String> wordsToCount) {
  Map<String, int> wordCounts = {};

  void processFile(File file) {
    String content = file.readAsStringSync();
    for (String word in wordsToCount) {
      RegExp regex = RegExp(r'\b' + RegExp.escape(word) + r'\b', caseSensitive: false);
      Iterable<Match> matches = regex.allMatches(content);
      int occurrences = matches.length;
      if (wordCounts.containsKey(word)) {
        wordCounts[word] = (wordCounts[word] ?? 0) + occurrences;
      } else {
        wordCounts[word] = occurrences;
      }
    }
  }

  void walkDirectory(Directory dir) {
    dir.listSync(recursive: true).forEach((FileSystemEntity entity) {
      if (entity is File && fileExtensions.any((ext) => entity.path.toLowerCase().endsWith(ext))) {
        print(entity.path);
        processFile(entity);
      }
    });
  }

  walkDirectory(Directory(directory));

  return wordCounts;
}
