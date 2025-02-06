import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:restaurant_app/core/error/restaurant_exception.dart';
import 'package:restaurant_app/data/datasources/remote/api_services.dart';
import 'package:restaurant_app/domain/entities/restaurant_review_model.dart';
import 'package:restaurant_app/presentation/providers/restaurant/states/restaurant_review_result_state.dart';

class RestaurantReviewProvider extends ChangeNotifier {
  final ApiServices apiService;

  RestaurantReviewProvider({required this.apiService});

  bool _isLoading = false;
  String _message = '';
  RestaurantReviewState _state = const RestaurantReviewInitialState();

  bool get isLoading => _isLoading;
  String get message => _message;
  RestaurantReviewState get state => _state;

  Future<bool> postReview(String id, String name, String review) async {
    try {
      _isLoading = true;
      _state = const RestaurantReviewLoadingState();
      notifyListeners();

      final response = await apiService.postReview(id, name, review);
      _isLoading = false;

      if (response.error == false) {
        _message = 'Review berhasil ditambahkan';
        _state = RestaurantReviewSuccessState(
          review: response,
          message: _message,
        );
        notifyListeners();
        return true;
      } else {
        _message = 'Gagal menambahkan review';
        _state = RestaurantReviewErrorState(message: _message);
        notifyListeners();
        return false;
      }
    } on RestaurantException catch (e) {
      _isLoading = false;
      _message = e.message;
      _state = RestaurantReviewErrorState(message: _message);
      notifyListeners();
      return false;
    } on SocketException catch (_) {
      _isLoading = false;
      _message = 'Tidak dapat terhubung ke server';
      _state = RestaurantReviewErrorState(message: _message);
      notifyListeners();
      return false;
    } on TimeoutException catch (_) {
      _isLoading = false;
      _message = 'Request timed out. Please try again.';
      _state = RestaurantReviewErrorState(message: _message);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _message = 'Terjadi kesalahan: ${e.toString()}';
      _state = RestaurantReviewErrorState(message: _message);
      notifyListeners();
      return false;
    } finally {
      notifyListeners();
    }
  }
}
