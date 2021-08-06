// To parse this JSON data, do
//
//     final video = videoFromMap(jsonString);

import 'dart:convert';

List<Video> videoFromMap(String str) =>
    List<Video>.from(json.decode(str).map((x) => Video.fromMap(x)));

String videoToMap(List<Video> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class Video {
  Video({
    this.description,
    this.sources,
    this.subtitle,
    this.thumb,
    this.title,
  });

  String? description;
  List<String>? sources;
  String? subtitle;
  String? thumb;
  String? title;

  factory Video.fromMap(Map<String, dynamic> json) => Video(
        description: json["description"] == null ? null : json["description"],
        sources: json["sources"] == null
            ? null
            : List<String>.from(json["sources"].map((x) => x)),
        subtitle: json["subtitle"] == null ? null : json["subtitle"],
        thumb: json["thumb"] == null ? null : json["thumb"],
        title: json["title"] == null ? null : json["title"],
      );

  Map<String, dynamic> toMap() => {
        "description": description == null ? null : description,
        "sources":
            sources == null ? null : List<dynamic>.from(sources!.map((x) => x)),
        "subtitle": subtitle == null ? null : subtitle,
        "thumb": thumb == null ? null : thumb,
        "title": title == null ? null : title,
      };
}
