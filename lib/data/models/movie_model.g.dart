// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MovieAdapter extends TypeAdapter<Movie> {
  @override
  final int typeId = 0;

  @override
  Movie read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Movie(
      id: fields[0] as int,
      title: fields[1] as String,
      posterPath: fields[2] as String,
      releaseDate: fields[3] as String?,
      tmdbRating: fields[4] as double,
      genres: (fields[5] as List).cast<String>(),
      overview: fields[6] as String,
      myRating: fields[7] as double?,
      isSeen: fields[8] as bool,
      isWatchlist: fields[9] as bool,
      notes: fields[10] as String?,
      isManuallyAdded: fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Movie obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.posterPath)
      ..writeByte(3)
      ..write(obj.releaseDate)
      ..writeByte(4)
      ..write(obj.tmdbRating)
      ..writeByte(5)
      ..write(obj.genres)
      ..writeByte(6)
      ..write(obj.overview)
      ..writeByte(7)
      ..write(obj.myRating)
      ..writeByte(8)
      ..write(obj.isSeen)
      ..writeByte(9)
      ..write(obj.isWatchlist)
      ..writeByte(10)
      ..write(obj.notes)
      ..writeByte(11)
      ..write(obj.isManuallyAdded);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovieAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
