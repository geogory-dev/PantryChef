import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/firebase_config.dart';
import '../models/recipe.dart';
import '../models/meal_plan.dart';
import '../models/shopping_list_item.dart';
import '../models/food_diary_entry.dart';

class CloudSyncService {
  static final FirebaseFirestore _firestore = FirebaseConfig.firestore;

  // Recipe Sync Methods
  static Future<void> syncRecipeToCloud(String userId, Recipe recipe) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('recipes')
          .doc(recipe.id)
          .set(recipe.toJson());
    } catch (e) {
      throw Exception('Failed to sync recipe to cloud: $e');
    }
  }

  static Future<void> removeRecipeFromCloud(String userId, String recipeId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('recipes')
          .doc(recipeId)
          .delete();
    } catch (e) {
      throw Exception('Failed to remove recipe from cloud: $e');
    }
  }

  static Future<List<Recipe>> getRecipesFromCloud(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('recipes')
          .orderBy('savedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Recipe.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get recipes from cloud: $e');
    }
  }

  // Meal Plan Sync Methods
  static Future<void> syncMealPlanToCloud(String userId, MealPlan mealPlan) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('mealPlans')
          .doc(mealPlan.id)
          .set(mealPlan.toJson());
    } catch (e) {
      throw Exception('Failed to sync meal plan to cloud: $e');
    }
  }

  static Future<void> removeMealPlanFromCloud(String userId, String mealPlanId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('mealPlans')
          .doc(mealPlanId)
          .delete();
    } catch (e) {
      throw Exception('Failed to remove meal plan from cloud: $e');
    }
  }

  static Future<List<MealPlan>> getMealPlansFromCloud(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('mealPlans')
          .orderBy('weekStart')
          .get();

      return snapshot.docs
          .map((doc) => MealPlan.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get meal plans from cloud: $e');
    }
  }

  // Shopping List Sync Methods
  static Future<void> syncShoppingListToCloud(String userId, List<ShoppingListItem> shoppingList) async {
    try {
      // Convert list to map for Firestore
      Map<String, dynamic> shoppingListData = {
        'items': shoppingList.map((item) => item.toJson()).toList(),
        'updatedAt': Timestamp.now(),
      };

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('shoppingLists')
          .doc('current')
          .set(shoppingListData);
    } catch (e) {
      throw Exception('Failed to sync shopping list to cloud: $e');
    }
  }

  static Future<List<ShoppingListItem>> getShoppingListFromCloud(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('shoppingLists')
          .doc('current')
          .get();

      if (!doc.exists) return [];

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      List<dynamic> itemsData = data['items'] ?? [];
      
      return itemsData
          .map((item) => ShoppingListItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get shopping list from cloud: $e');
    }
  }

  // Food Diary Sync Methods
  static Future<void> syncFoodDiaryEntryToCloud(String userId, FoodDiaryEntry entry) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('foodDiary')
          .doc(entry.id)
          .set(entry.toJson());
    } catch (e) {
      throw Exception('Failed to sync food diary entry to cloud: $e');
    }
  }

  static Future<void> removeFoodDiaryEntryFromCloud(String userId, String entryId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('foodDiary')
          .doc(entryId)
          .delete();
    } catch (e) {
      throw Exception('Failed to remove food diary entry from cloud: $e');
    }
  }

  static Future<List<FoodDiaryEntry>> getFoodDiaryEntriesFromCloud(String userId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      Query query = _firestore
          .collection('users')
          .doc(userId)
          .collection('foodDiary')
          .orderBy('date', descending: true);

      if (startDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      QuerySnapshot snapshot = await query.get();

      return snapshot.docs
          .map((doc) => FoodDiaryEntry.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get food diary entries from cloud: $e');
    }
  }

  // User Preferences Sync
  static Future<void> syncUserPreferencesToCloud(String userId, Map<String, dynamic> preferences) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'preferences': preferences});
    } catch (e) {
      throw Exception('Failed to sync user preferences to cloud: $e');
    }
  }

  // Full Sync Methods
  static Future<void> performFullSync(String userId, {
    List<Recipe>? recipes,
    List<MealPlan>? mealPlans,
    List<ShoppingListItem>? shoppingList,
    List<FoodDiaryEntry>? foodDiaryEntries,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      // Sync all data in batch for better performance
      WriteBatch batch = _firestore.batch();

      // Sync recipes
      if (recipes != null) {
        for (Recipe recipe in recipes) {
          DocumentReference docRef = _firestore
              .collection('users')
              .doc(userId)
              .collection('recipes')
              .doc(recipe.id);
          batch.set(docRef, recipe.toJson());
        }
      }

      // Sync meal plans
      if (mealPlans != null) {
        for (MealPlan mealPlan in mealPlans) {
          DocumentReference docRef = _firestore
              .collection('users')
              .doc(userId)
              .collection('mealPlans')
              .doc(mealPlan.id);
          batch.set(docRef, mealPlan.toJson());
        }
      }

      // Sync shopping list
      if (shoppingList != null) {
        Map<String, dynamic> shoppingListData = {
          'items': shoppingList.map((item) => item.toJson()).toList(),
          'updatedAt': Timestamp.now(),
        };
        DocumentReference docRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('shoppingLists')
            .doc('current');
        batch.set(docRef, shoppingListData);
      }

      // Sync food diary entries
      if (foodDiaryEntries != null) {
        for (FoodDiaryEntry entry in foodDiaryEntries) {
          DocumentReference docRef = _firestore
              .collection('users')
              .doc(userId)
              .collection('foodDiary')
              .doc(entry.id);
          batch.set(docRef, entry.toJson());
        }
      }

      // Commit batch
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to perform full sync: $e');
    }
  }

  // Conflict Resolution
  static Future<List<Recipe>> resolveRecipeConflicts(String userId, List<Recipe> localRecipes) async {
    try {
      List<Recipe> cloudRecipes = await getRecipesFromCloud(userId);
      Map<String, Recipe> cloudRecipeMap = {recipe.id: recipe for recipe in cloudRecipes};

      List<Recipe> mergedRecipes = [];
      Set<String> processedIds = {};

      // Process local recipes
      for (Recipe localRecipe in localRecipes) {
        if (cloudRecipeMap.containsKey(localRecipe.id)) {
          Recipe cloudRecipe = cloudRecipeMap[localRecipe.id]!;
          
          // Use the most recently updated version
          if (localRecipe.savedAt.isAfter(cloudRecipe.savedAt)) {
            mergedRecipes.add(localRecipe);
          } else {
            mergedRecipes.add(cloudRecipe);
          }
        } else {
          mergedRecipes.add(localRecipe);
        }
        processedIds.add(localRecipe.id);
      }

      // Add cloud-only recipes
      for (Recipe cloudRecipe in cloudRecipes) {
        if (!processedIds.contains(cloudRecipe.id)) {
          mergedRecipes.add(cloudRecipe);
        }
      }

      return mergedRecipes;
    } catch (e) {
      throw Exception('Failed to resolve recipe conflicts: $e');
    }
  }

  // Check network connectivity
  static Future<bool> isNetworkAvailable() async {
    try {
      // Try to reach Firestore
      await _firestore.collection('connectivity').limit(1).get();
      return true;
    } catch (e) {
      return false;
    }
  }
}
