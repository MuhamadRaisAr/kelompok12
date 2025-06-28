// lib/views/widgets/news_card_widget.dart
// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/article_model.dart';
import '../utils/helper.dart' as helper;
import '../../routes/route_name.dart';

class NewsCardWidget extends StatelessWidget {
  final Article article;
  final bool isBookmarked;
  final VoidCallback onBookmarkTap;

  const NewsCardWidget({
    super.key,
    required this.article,
    required this.isBookmarked,
    required this.onBookmarkTap,
  });

  Widget _buildImage(ThemeData theme) {
    Widget placeholder = Container(
      width: 110.0,
      height: 110.0,
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Icon(
        Icons.image_not_supported_outlined,
        color: theme.hintColor.withOpacity(0.5),
        size: 40,
      ),
    );

    if (article.urlToImage == null || article.urlToImage!.isEmpty) {
      return placeholder;
    }

    if (article.urlToImage!.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Image.network(
          article.urlToImage!,
          width: 110.0,
          height: 110.0,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => placeholder,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 110.0,
              height: 110.0,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          },
        ),
      );
    } else {
      if (kIsWeb) return placeholder;
      final file = File(article.urlToImage!);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Image.file(
            file,
            width: 110.0,
            height: 110.0,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => placeholder,
          ),
        );
      } else {
        return placeholder;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    String formattedDate = article.publishedAt != null
        ? DateFormat('d MMM, HH:mm', 'id_ID').format(article.publishedAt!)
        : 'No date';

    String sourceDisplay = article.sourceName ?? article.author ?? "Unknown Source";
    bool isLocalArticle = article.url == null || article.url!.isEmpty;

    return GestureDetector(
      onTap: () => context.pushNamed(RouteName.articleDetail, extra: article),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.08),
              blurRadius: 20.0,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            _buildImage(theme),
            helper.hsMedium,
            Expanded(
              child: SizedBox(
                height: 110.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      article.title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textTheme.bodyLarge?.color,
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sourceDisplay,
                                style: textTheme.bodySmall?.copyWith(
                                  color: theme.hintColor,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              helper.vsSuperTiny,
                              Text(
                                formattedDate,
                                style: textTheme.labelSmall?.copyWith(
                                  color: theme.hintColor.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: onBookmarkTap,
                          borderRadius: BorderRadius.circular(30),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              isLocalArticle
                                  ? Icons.delete_outline_rounded
                                  : (isBookmarked
                                      ? Icons.bookmark_rounded
                                      : Icons.bookmark_border_rounded),
                              color: isLocalArticle
                                  ? theme.colorScheme.error
                                  : (isBookmarked
                                      ? theme.colorScheme.primary
                                      : theme.hintColor),
                              size: 24.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}