import 'dart:async';

import 'package:intl/intl.dart';
import 'package:wepei_module/auth/network/auth_service.dart';
import 'package:wepei_module/commons/network/wpy_dio.dart';
import 'package:wepei_module/commons/preferences/common_prefs.dart';
import 'package:wepei_module/commons/util/logger.dart';
import 'package:wepei_module/studyroom/model/studyroom_models.dart';
import 'package:wepei_module/studyroom/util/session_util.dart';

class _StudyroomDio {
  final Dio _dio;

  _StudyroomDio() : _dio = Dio(BaseOptions(
    baseUrl: 'https://selfstudy.twt.edu.cn/',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'DOMAIN': AuthDio.DOMAIN,
      'ticket': AuthDio.ticket,
    },
  ));

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) =>
      _dio.get(path, queryParameters: queryParameters);

  Future<Response> post(String path, {Map<String, dynamic>? queryParameters, dynamic data}) =>
      _dio.post(path, queryParameters: queryParameters, data: data);
}


final _studyroomDio = _StudyroomDio();

class StudyroomService {
  /// 获取收藏的教室id
  static Future<List<int>> getFavouriteIds() async {
    final response = await _studyroomDio.get('getCollections');
    // var response =
    var pre = Map<String, List<dynamic>>.from(response.data).values;
    if (pre.isEmpty) {
      return <int>[];
    } else {
      return pre.first.map((e) => int.parse(e)).toList();
    }
  }

  /// 收藏教室
  static Future<bool> collectRoom(int id) async {
    try {
      await _studyroomDio.post(
        'addCollection',
        queryParameters: {'classroom_id': id},
      );
      return true;
    } catch (e, s) {
      Logger.reportError(e, s);
      return false;
    }
  }

  /// 取消收藏教室，失败的话就在本地添加记录，下次再做同步
  static Future<bool> deleteRoom(int id) async {
    try {
      await _studyroomDio.post(
        'deleteCollection',
        queryParameters: {'classroom_id': id},
      );
      return true;
    } catch (e, s) {
      Logger.reportError(e, s);
      return false;
    }
  }

  static Future<List<Campus>> getCampusList() async {
    try {
      final response = await _studyroomDio.get('/campus');
      if (response.statusCode != 200) return [];
      final raw = response.data as Map<String, dynamic>;
      return (raw['data'] as List).map((e) => Campus.fromJson(e)).toList();
    } catch (e, s) {
      Logger.reportError(e, s);
      return [];
    }
  }

  static Future<List<Building>> getBuildingList(int campusId) async {
    try {
      final response = await _studyroomDio.get('/campus/${campusId}/building');
      if (response.statusCode != 200) return [];
      final raw = response.data as Map<String, dynamic>;
      return (raw['data'] as List).map((e) => Building.fromJson(e)).toList();
    } catch (e, s) {
      Logger.reportError(e, s);
      return [];
    }
  }

  static Future<List<Room>> getRoomList(
      int buildingId, int session, DateTime date) async {
    try {
      final response;
      if (session == -1) session = SessionIndexUtil.getCurrentSessionIndex();
      if (session == -1) {
        response = await _studyroomDio.get('/building/${buildingId}/room');
      } else {
        response = await _studyroomDio.get(
            '/building/${buildingId}/room/session/${session}/date/${DateFormat('yyyy-MM-dd').format(date)}');
      }
      if (response.statusCode != 200) return [];
      final raw = response.data as Map<String, dynamic>;
      return (raw['data'] as List).map((e) => Room.fromJson(e)).toList();
    } catch (e, s) {
      Logger.reportError(e, s);
      return [];
    }
  }

  static Future<List<Occupy>> getSchedule(int id) async {
    try {
      final response = await _studyroomDio.get('/room/${id}/schedule');
      if (response.statusCode != 200) return [];
      final raw = response.data as Map<String, dynamic>;
      return (raw['data'] as List).map((e) => Occupy.fromJson(e)).toList();
    } catch (e, s) {
      Logger.reportError(e, s);
      return [];
    }
  }
}
