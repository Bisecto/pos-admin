import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  static Future putString(String key, String value) async {
    return putValue(key, value, 'string');
  }

  static Future<String> getString(String key) async {
    return await getValue(key: key, dataType: 'string') ?? '';
  }

  static Future<bool> hasString(String key) async {
    return await getValue(key: key, dataType: 'string') != '';
  }

  static Future putInt(String key, int value) async {
    return putValue(key, value, 'int');
  }

  static Future<int> getInt(String key) async {
    return int.parse(getValue(key: key, dataType: 'int').toString());
  }

  static Future putDouble(String key, double value) async {
    return putValue(key, value, 'double');
  }

  static Future<double> getDouble(String key) async {
    return double.parse(getValue(key: key, dataType: 'double').toString());
  }

  static Future putBool(String key, bool value) async {
    return putValue(key, value, 'bool');
  }

  static Future getBool(String key) async {
    return getValue(key: key, dataType: 'bool');
  }

  //Methods to add data to sharedPrefs
  static Future putValue(String key, dynamic value, String dataType) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      switch (dataType) {
        case 'string':
          pref.setString(key, value);
          break;
        case 'bool':
          pref.setBool(key, value);
          break;
        case 'double':
          pref.setDouble(key, value);
          break;
        case 'int':
          pref.setInt(key, value);
          break;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

//Methods to retrieve data from sharedPrefs
  static Future<dynamic> getValue(
      {required String key, required String dataType}) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    switch (dataType) {
      case 'string':
        return (pref.getString(key) ?? '');

      case 'bool':
        return (pref.getBool(key));

      case 'double':
        return (pref.getDouble(key) ?? 0.0);

      case 'int':
        return (pref.getInt(key) ?? 0);
    }
  }

//Methods to remove data from sharedPrefs
  static Future<dynamic> remove(String key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    return (pref.remove(key));
  }
}
