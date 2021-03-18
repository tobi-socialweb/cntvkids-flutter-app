/// A base model object class to avoid repeating the `has` method.
abstract class BaseModel {
  /// Compare object to null and to the elements in `comp`, if any. Returns
  /// `object` if it's not equal to any of those things; otherwise, return
  /// `value` which by default is null. `then` gets called if `object` is
  /// returned.
  static T has<T>(T object, T value,
      {List<T> comp = const [], void Function(T object)? then}) {
    /// Default value of the `then` parameter.
    then ??= (obj) {};

    /// Get first result with `obj != null`.
    bool res = object != null;

    for (int i = 0; i < comp.length; i++) {
      res &= object != comp[i];
    }

    if (res) then(object);

    return res ? object : value;
  }
}
