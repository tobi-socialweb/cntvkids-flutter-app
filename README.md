# CNTVKids Flutter App

## TODOs
- [ ] Check if values can be null or empty. `lib/models/video.dart > Video.fromJason()`
- [ ] Use this function to force list update (and fix it). `lib/pages/featured.dart > _FeaturedState._checkForForceUpdate()`
- [ ] Fix bad scrolling when moving backwards. `lib/pages/featured.dart > _FeaturedState.build()`
- [ ] Fix BetterPlayer's bad [controlsHideTime] process. `lib/widgets/video_container > _VideoContainerState.initState()`
- [ ] Figure how to call event [hideFullscreen] when using the 'back' button (system UI). `lib/widgets/video_container > _VideoContainerState.initState()`

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
