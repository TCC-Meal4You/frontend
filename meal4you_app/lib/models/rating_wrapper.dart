import 'package:meal4you_app/models/user_rating_response_dto.dart';
import 'package:meal4you_app/models/meal_rating_response_dto.dart';

class RatingWrapper {
  final UserRatingResponseDTO? restaurantRating;
  final MealRatingResponseDTO? mealRating;

  RatingWrapper({this.restaurantRating, this.mealRating});

  bool get isRestaurant => restaurantRating != null;
  bool get isMeal => mealRating != null;

  String get title {
    if (isRestaurant) return restaurantRating!.restaurantName ?? 'Restaurante';
    if (isMeal) return mealRating!.mealName ?? 'Refeição';
    return '';
  }

  String get userName {
    if (isRestaurant) return restaurantRating!.userName;
    if (isMeal) return mealRating!.userName;
    return '';
  }

  double get rating {
    if (isRestaurant) return restaurantRating!.rating;
    if (isMeal) return mealRating!.rating;
    return 0;
  }

  String? get comment {
    if (isRestaurant) return restaurantRating!.comment;
    if (isMeal) return mealRating!.comment;
    return null;
  }

  DateTime get ratingDate {
    if (isRestaurant) return restaurantRating!.ratingDate;
    if (isMeal) return mealRating!.ratingDate;
    return DateTime.now();
  }

  int get id {
    if (isRestaurant) return restaurantRating!.ratingId;
    if (isMeal) return mealRating!.ratingId;
    return 0;
  }
}
