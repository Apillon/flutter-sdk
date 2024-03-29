import 'package:apillon_flutter/libs/apillon-api.dart';
import 'package:apillon_flutter/libs/apillon-logger.dart';
import 'package:apillon_flutter/libs/apillon.dart';

class Ipns extends ApillonModel {
  /// Informational IPNS name, which is set by user to easily organize their IPNS records.
  String? name;

  /// IPNS record description.
  String? description;

  /// IPNS name that is used to access IPNS content on IPFS gateway.
  String? ipnsName;

  /// IPFS value (CID), to which this IPNS points.
  String? ipnsValue;

  /// IPNS link to Apillon IPFS gateway, where it is possible to see content to which this IPNS points.
  String? link;

  /// Unique identifier of the IPNS record's bucket.
  String? bucketUuid;

  /// Constructor which should only be called via StorageBucket class.
  /// @param bucketUuid Unique identifier of the file's bucket.
  /// @param ipnsUuid Unique identifier of the IPNS record.
  /// @param data Data to populate the IPNS record with.
  Ipns(
    this.bucketUuid,
    String ipnsUuid, {
    Map<String, dynamic>? data,
  }) : super(ipnsUuid) {
    apiPrefix = '/storage/buckets/$bucketUuid/ipns/$ipnsUuid';
    populate(data);
  }

  /// Gets IPNS details.
  /// @returns IPNS record
  Future<Ipns> get() async {
    final data = await ApillonApi.get<Ipns>(apiPrefix!, mapper: Ipns.fromMap);
    return data;
  }

  /// Publish an IPNS record to IPFS and link it to a CID.
  /// @param {string} cid - CID to which this ipns name will point.
  /// @returns IPNS record with updated data after publish
  Future<Ipns> publish(String cid) async {
    final data = await ApillonApi.post<Ipns>(
        '$apiPrefix/publish',
        {
          'cid': cid,
        },
        mapper: Ipns.fromMap);
    ApillonLogger.log('IPNS record published successfully');
    return data;
  }

  /// Delete an IPNS record from the bucket.
  /// @returns Deleted IPNS record
  Future<Ipns> delete() async {
    final data =
        await ApillonApi.delete<Ipns>(apiPrefix!, mapper: Ipns.fromMap);
    ApillonLogger.log('IPNS record deleted successfully');
    return data;
  }

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    map.addAll({
      "name": name,
      "description": description,
      "ipnsName": ipnsName,
      "ipnsValue": ipnsValue,
      "link": link,
      "bucketUuid": bucketUuid,
    });
    return map;
  }

  factory Ipns.fromMap(Map<String, dynamic> map) {
    return Ipns(map["bucketUuid"], map["ipnsUuid"]).populate(map);
  }

  @override
  dynamic populate(dynamic data) {
    if (data != null) {
      super.populate(data);
      name ??= data["name"];
      description ??= data["description"];
      ipnsName ??= data["ipnsName"];
      ipnsValue ??= data["ipnsValue"];
      link ??= data["link"];
    }
    return this;
  }
}
