import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Enumerator for the types of filters that can be used in the app.
enum VisualFilter { normal, inverted, grayscale }

/// A settings class for storing values and sending to the [ConfigWidget].
class ConfigSettings {
  VisualFilter filter;

  ConfigSettings({this.filter});
}

/// An InheritedWidget in charge of storing global app configurations.
class ConfigWidget extends InheritedWidget {
  final ConfigSettings configSettings;
  final Widget child;

  ConfigWidget({this.configSettings, this.child});

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;

  static ConfigWidget of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ConfigWidget>();
}

/// Works the same way [MaterialPageRoute] does, adding the option of sending
/// app settings with [configSettings].
class ConfigPageRoute extends MaterialPageRoute {
  /// Contains the app settings that will be passed to the next page.
  final ConfigSettings configSettings;

  /// Builds the primary contents of the route.
  final WidgetBuilder builder;

  ConfigPageRoute({this.configSettings, @required this.builder})
      : super(builder: builder);

  @override
  Widget buildContent(BuildContext context) {
    /// If [settings] is not null, then add ConfigWidget to the build.
    if (settings != null) {
      Widget child = builder(context);

      Widget Function(BuildContext context) newBuilder = (context) {
        return ConfigWidget(
          configSettings: configSettings,
          child: child,
        );
      };

      return newBuilder(context);

      /// Otherwise, just return the normal builder.
    } else {
      return builder(context);
    }
  }
}
