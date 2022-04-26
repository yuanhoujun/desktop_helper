import 'dart:typed_data';

class ApplicationInfo {
    final String url;
    final String name;
    final Uint8List icon;
    final String bundleId;

    const ApplicationInfo(this.url, this.name, this.icon, this.bundleId);
}