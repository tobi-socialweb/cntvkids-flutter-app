# CNTVKids Flutter App

## TODOs
- [ ] Check if values can be null or empty. [`lib/models/video.dart > Video.fromJason()`](lib/models/video.dart#L31)
- [ ] Fix bad scrolling when moving backwards. [`lib/pages/featured.dart > _FeaturedState.build()`](lib/pages/featured.dart#L182)
- [ ] Fix BetterPlayer's bad [controlsHideTime] process. [`lib/widgets/video_container.dart > _VideoContainerState.initState()`](lib/widgets/video_container.dart#L45)
- [ ] Use navigator and app bar for routing. [`lib/main.dart > _HomePageState.build()`](lib/main.dart#L256)

## Files
(red files came with the "flutter for wordpress" example project, green ones are new ones)

### models

``` diff
+video.dart
-article.dart
-Category.dart
-Comment.dart
```


### pages

``` diff
+featured.dart
+games.dart
+list.dart
+series.dart
+search.dart
-add_comment.dart
-articles.dart
-categories.dart
-category_articles.dart
-comments.dart
-favoutite_articles.dart
-local_articles.dart
-settings.dart
-single_article.dart
```


### widgets

``` diff
+video_container.dart
-articleBox.dart
-articleBoxFeatured.dart
-commentBox.dart
-searchBoxes.dart
```
