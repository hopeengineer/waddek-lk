import 'package:flutter/material.dart';

/// Generic paginated list that loads more items on scroll.
/// Use this across jobs, bids, transactions, messages, etc.
class PaginatedListView<T> extends StatefulWidget {
  const PaginatedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onLoadMore,
    this.hasMore = true,
    this.isLoading = false,
    this.emptyIcon = Icons.inbox_outlined,
    this.emptyTitle = 'Nothing here yet',
    this.emptySubtitle,
    this.padding = const EdgeInsets.all(12),
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final VoidCallback onLoadMore;
  final bool hasMore;
  final bool isLoading;
  final IconData emptyIcon;
  final String emptyTitle;
  final String? emptySubtitle;
  final EdgeInsets padding;

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!widget.hasMore || widget.isLoading) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    // Trigger load when 200px from bottom
    if (maxScroll - currentScroll <= 200) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && !widget.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.emptyIcon, color: Colors.white38, size: 64),
            const SizedBox(height: 16),
            Text(
              widget.emptyTitle,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            if (widget.emptySubtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.emptySubtitle!,
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      itemCount: widget.items.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (ctx, i) {
        if (i >= widget.items.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        return widget.itemBuilder(ctx, widget.items[i], i);
      },
    );
  }
}
