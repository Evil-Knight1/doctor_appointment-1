import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  static Future<String?> pickImage({ImageSource source = ImageSource.gallery}) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    return image?.path;
  }

  static Future<List<String>> pickMultiImage() async {
    final List<XFile> images = await _picker.pickMultiImage(
      imageQuality: 80,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    return images.map((e) => e.path).toList();
  }
}
