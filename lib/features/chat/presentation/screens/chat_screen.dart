import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'package:waddek_lk/core/services/places_service.dart';
import 'package:waddek_lk/core/theme/app_colors.dart';
import 'package:waddek_lk/core/utils/i18n_helpers.dart';
import 'package:waddek_lk/core/widgets/address_lookup_field.dart';
import 'package:waddek_lk/core/widgets/loading_shimmer.dart';
import 'package:waddek_lk/core/widgets/neon_button.dart';
import 'package:waddek_lk/core/services/supabase_service.dart';
import 'package:waddek_lk/features/chat/presentation/providers/chat_provider.dart';
import 'package:waddek_lk/features/chat/domain/message_model.dart';
import 'package:waddek_lk/features/jobs/data/jobs_repository.dart';
import 'package:waddek_lk/features/profile/data/profile_repository.dart';
import 'package:waddek_lk/features/profile/presentation/providers/profile_provider.dart';
import 'package:waddek_lk/l10n/app_localizations.dart';

/// Chat screen — realtime messaging with a matched party.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.conversationId});
  final String conversationId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;

  String get _currentUserId =>
      SupabaseService.client.auth.currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    // Mark messages as read when opening chat
    ref.read(chatRepositoryProvider).markMessagesAsRead(widget.conversationId);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync =
        ref.watch(messagesStreamProvider(widget.conversationId));
    final convAsync =
        ref.watch(conversationDetailProvider(widget.conversationId));
    final l10n = AppLocalizations.of(context)!;
    final conv = convAsync.valueOrNull;

    // After both parties agree (job.status >= matched), phone reveals.
    final jobStatus = conv?.jobData?['status'] as String?;
    final canSeePhone = jobStatus != null &&
        {'matched', 'in_progress', 'completed', 'disputed'}
            .contains(jobStatus);
    final myId = _currentUserId;
    final bool iAmCustomer =
        conv != null && conv.customerId == myId;
    String? otherPhone;
    if (canSeePhone && conv != null) {
      final Object? raw;
      if (iAmCustomer) {
        raw = conv.workerData?['phone'];
      } else {
        raw = conv.customerData?['phone'];
      }
      if (raw is String) otherPhone = raw;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chat),
        actions: [
          if (otherPhone != null && otherPhone.isNotEmpty)
            Builder(builder: (ctx) {
              final String phone = otherPhone!;
              return IconButton(
                icon: const Icon(Icons.phone, color: AppColors.neonGreen),
                tooltip: phone,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: phone));
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Phone copied: $phone')),
                  );
                },
              );
            }),
        ],
      ),
      body: Column(
        children: [
          // ── Messages List ──
          Expanded(
            child: messagesAsync.when(
              loading: () => const LoadingShimmer(),
              error: (e, _) => Center(child: Text('${l10n.error}: $e')),
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'Start the conversation!',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }

                // Auto-scroll to bottom
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                    );
                  }
                });

                // Only the LATEST job_proposal message is actionable
                // for the receiver — older proposals are history and
                // their buttons stay hidden even if the status would
                // otherwise allow action.
                int latestProposalIdx = -1;
                for (int k = messages.length - 1; k >= 0; k--) {
                  if (messages[k].type == 'job_proposal') {
                    latestProposalIdx = k;
                    break;
                  }
                }
                final proposalIsPending = jobStatus == 'draft';
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (ctx, i) {
                    final m = messages[i];
                    final senderIsCustomer = conv != null &&
                        m.senderId == conv.customerId;
                    final isMine = m.senderId == _currentUserId;
                    final isLatestPending = i == latestProposalIdx &&
                        proposalIsPending &&
                        !isMine;
                    return _MessageBubble(
                      message: m,
                      isMine: isMine,
                      senderIsCustomer: senderIsCustomer,
                      isReceiverOfLatestProposal: isLatestPending,
                      onAccept: _acceptProposal,
                      onReject: _rejectProposal,
                      onAmend: _amendProposal,
                    );
                  },
                );
              },
            ),
          ),

          // ── Input Bar ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              border: Border(
                  top: BorderSide(
                      color: AppColors.bgSurface.withOpacity(0.5))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Propose Job — either side can initiate. Hidden
                  // while a draft is pending (negotiation happens in
                  // the proposal bubble's Accept/Amend/Reject), and
                  // hidden while a job is actively live. Re-appears
                  // once the previous job is completed/cancelled/
                  // disputed so a fresh gig can start.
                  if (conv != null &&
                      (conv.jobId == null ||
                          jobStatus == 'completed' ||
                          jobStatus == 'cancelled' ||
                          jobStatus == 'disputed'))
                    IconButton(
                      icon: const Icon(Icons.work_outline,
                          color: AppColors.neonAmber),
                      tooltip: 'Propose Job',
                      onPressed: () => _openProposeJobSheet(conv),
                    ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: const TextStyle(
                            color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.bgSurface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      maxLines: 4,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: IconButton(
                      icon: _sending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.neonCyan),
                            )
                          : const Icon(Icons.send,
                              color: AppColors.neonCyan),
                      onPressed: _sending ? null : _send,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openProposeJobSheet(
    ConversationModel? conv, {
    _ProposalEditingContext? editing,
  }) async {
    if (conv == null) return;
    var me = ref.read(currentProfileProvider).valueOrNull;
    if (me == null) return;

    final iAmCustomer = conv.customerId == me.id;

    // The job's geography pin is the customer's address. For fresh
    // proposals we make sure it exists (and prompt to set it if
    // the proposer IS the customer); for amends, the existing job
    // already has the pin so we skip this whole block.
    double? customerLat;
    double? customerLng;
    if (editing == null) {
      if (iAmCustomer) {
        if (me.latitude == null || me.longitude == null) {
          final saved = await showModalBottomSheet<bool>(
            context: context,
            backgroundColor: AppColors.bgCard,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (ctx) => const _LocationSetupSheet(),
          );
          if (saved != true || !mounted) return;
          me = ref.read(currentProfileProvider).valueOrNull;
          if (me == null ||
              me.latitude == null ||
              me.longitude == null) {
            return;
          }
        }
        customerLat = me.latitude;
        customerLng = me.longitude;
      } else {
        // Worker proposing — read the customer's saved location. We
        // can't write it for them, so if it's missing the worker has
        // to ask the customer to add their address first.
        final customer =
            await ProfileRepository().getProfile(conv.customerId);
        if (!mounted) return;
        if (customer == null ||
            customer.latitude == null ||
            customer.longitude == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    "Customer hasn't set their address yet — ask them in chat to add one before you propose.")),
          );
          return;
        }
        customerLat = customer.latitude;
        customerLng = customer.longitude;
      }
    }

    // The worker's registered categories are still the constraint
    // even when the worker is the proposer — we propose within
    // their listed skills, not arbitrary services.
    final cats =
        await ProfileRepository().getWorkerCategories(conv.workerId);
    if (!mounted) return;
    if (cats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "This worker has no listed skills yet — can't propose a job.")),
      );
      return;
    }

    final locale = Localizations.localeOf(context);
    final result = await showModalBottomSheet<_ProposeJobResult>(
      context: context,
      backgroundColor: AppColors.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _ProposeJobSheet(
        workerCategories: cats,
        locale: locale,
        isAmend: editing != null,
        initialCategoryId: editing?.categoryId,
        initialTitle: editing?.title,
        initialPrice: editing?.price,
        initialScheduledAt: editing?.scheduledAt,
      ),
    );
    if (result == null || !mounted) return;

    try {
      final String jobId;
      if (editing != null) {
        // Amend: update existing job row, flips proposed_by to me
        // server-side so the previous sender becomes the receiver
        // of the next proposal message.
        await JobsRepository().amendChatProposedJob(
          jobId: editing.jobId,
          title: result.title,
          categoryId: result.categoryId,
          price: result.price,
          scheduledAt: result.scheduledAt,
        );
        jobId = editing.jobId;
      } else {
        final job = await JobsRepository().createChatProposedJob(
          customerId: conv.customerId,
          workerId: conv.workerId,
          proposedBy: me.id,
          categoryId: result.categoryId,
          title: result.title,
          price: result.price,
          scheduledAt: result.scheduledAt,
          customerLat: customerLat!,
          customerLng: customerLng!,
        );
        jobId = job.id;
      }
      await ref.read(chatRepositoryProvider).sendJobProposal(
            conversationId: widget.conversationId,
            jobId: jobId,
            title: result.title,
            price: result.price,
            scheduledAt: result.scheduledAt,
            categoryName: result.categoryName,
          );
      ref.invalidate(conversationDetailProvider(widget.conversationId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(editing != null
                  ? 'Could not amend job: $e'
                  : 'Could not propose job: $e')),
        );
      }
    }
  }

  Future<void> _acceptProposal(String jobId) async {
    try {
      await JobsRepository().acceptChatProposedJob(
        jobId: jobId,
        conversationId: widget.conversationId,
      );
      await ref.read(chatRepositoryProvider).sendMessage(
            conversationId: widget.conversationId,
            content: '✅ Job accepted — you can now exchange contact details.',
            type: 'system',
          );
      ref.invalidate(conversationDetailProvider(widget.conversationId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not accept: $e')),
        );
      }
    }
  }

  Future<void> _rejectProposal(String jobId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: const Text('Reject proposal?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'This cancels the proposed job. You can always propose a new one.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reject',
                style: TextStyle(color: AppColors.neonRed)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await JobsRepository().rejectChatProposedJob(jobId: jobId);
      await ref.read(chatRepositoryProvider).sendMessage(
            conversationId: widget.conversationId,
            content: '❌ Proposal rejected.',
            type: 'system',
          );
      ref.invalidate(conversationDetailProvider(widget.conversationId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not reject: $e')),
        );
      }
    }
  }

  Future<void> _amendProposal(String jobId) async {
    // The chat bubble only knows what's in the message JSON (title,
    // price, scheduled_at). Pull the live job row to grab the
    // current category_id which we need for the amend RPC.
    final job = await JobsRepository().getJob(jobId);
    if (!mounted) return;
    if (job == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load the proposal to amend.')),
      );
      return;
    }
    final conv =
        ref.read(conversationDetailProvider(widget.conversationId)).valueOrNull;
    if (conv == null) return;
    await _openProposeJobSheet(
      conv,
      editing: _ProposalEditingContext(
        jobId: jobId,
        categoryId: job.categoryId,
        title: job.title,
        price: job.budgetMin,
        scheduledAt: job.scheduledAt,
      ),
    );
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _sending = true);
    _controller.clear();

    try {
      await ref.read(chatRepositoryProvider).sendMessage(
            conversationId: widget.conversationId,
            content: text,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send: $e'),
            backgroundColor: AppColors.neonRed,
          ),
        );
        _controller.text = text; // Restore text on failure
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }
}

/// Chat message bubble.
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.senderIsCustomer,
    this.isReceiverOfLatestProposal = false,
    this.onAccept,
    this.onReject,
    this.onAmend,
  });
  final MessageModel message;
  final bool isMine;
  // Role of the sender — drives the bubble's accent color so the
  // thread is visually consistent for both parties. Customer = cyan,
  // Waddek = green (matches the role-toggle pill).
  final bool senderIsCustomer;
  // True when this bubble is the *latest* proposal in the thread,
  // the bound job is still `draft`, and the caller is the other
  // party (i.e. not the proposer). The three action buttons show
  // only in that single case.
  final bool isReceiverOfLatestProposal;
  final void Function(String jobId)? onAccept;
  final void Function(String jobId)? onReject;
  final void Function(String jobId)? onAmend;

  @override
  Widget build(BuildContext context) {
    final time = message.createdAt != null
        ? '${message.createdAt!.hour}:${message.createdAt!.minute.toString().padLeft(2, '0')}'
        : '';

    if (message.type == 'job_proposal') {
      return _ProposalBubble(
        message: message,
        showActions: isReceiverOfLatestProposal,
        onAccept: onAccept,
        onReject: onReject,
        onAmend: onAmend,
      );
    }

    if (message.type == 'system') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message.content,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
        ),
      );
    }

    // Role-coloured accent — same colour regardless of who's viewing.
    final accent = senderIsCustomer
        ? AppColors.neonCyan
        : AppColors.neonGreen;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.15),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMine
                ? const Radius.circular(16)
                : const Radius.circular(4),
            bottomRight: isMine
                ? const Radius.circular(4)
                : const Radius.circular(16),
          ),
          border: Border.all(color: accent.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.content,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 14),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(time,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 10)),
                if (isMine) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead
                        ? Icons.done_all
                        : Icons.done,
                    color: message.isRead
                        ? AppColors.neonCyan
                        : AppColors.textSecondary,
                    size: 14,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Job proposal bubble ──────────────────────────────────────────
class _ProposalBubble extends StatelessWidget {
  const _ProposalBubble({
    required this.message,
    required this.showActions,
    required this.onAccept,
    required this.onReject,
    required this.onAmend,
  });
  final MessageModel message;
  // Show Accept / Amend / Reject. True only for the receiver of the
  // latest pending proposal.
  final bool showActions;
  final void Function(String jobId)? onAccept;
  final void Function(String jobId)? onReject;
  final void Function(String jobId)? onAmend;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data;
    try {
      data = jsonDecode(message.content) as Map<String, dynamic>;
    } catch (_) {
      return const SizedBox.shrink();
    }
    final jobId = data['job_id'] as String?;
    final title = data['title'] as String? ?? '';
    final price = (data['price'] as num?)?.toDouble();
    final scheduledAt = data['scheduled_at'] as String?;
    final categoryName = data['category_name'] as String?;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.neonAmber.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.neonAmber.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.work_outline,
                    color: AppColors.neonAmber, size: 18),
                const SizedBox(width: 6),
                const Text('Job proposal',
                    style: TextStyle(
                        color: AppColors.neonAmber,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        letterSpacing: 0.6)),
              ],
            ),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            if (categoryName != null) ...[
              const SizedBox(height: 4),
              Text(categoryName,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
            ],
            const SizedBox(height: 8),
            if (price != null)
              Row(
                children: [
                  const Icon(Icons.payments_outlined,
                      color: AppColors.neonGreen, size: 16),
                  const SizedBox(width: 4),
                  Text('Rs. ${price.toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: AppColors.neonGreen, fontSize: 14)),
                ],
              ),
            if (scheduledAt != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      color: AppColors.textSecondary, size: 14),
                  const SizedBox(width: 4),
                  Text(scheduledAt.split('T').first,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ],
            if (showActions && jobId != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => onAccept?.call(jobId),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neonGreen,
                        foregroundColor: AppColors.scaffoldDark,
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onAmend?.call(jobId),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Amend'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.neonAmber,
                        side: const BorderSide(
                            color: AppColors.neonAmber),
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onReject?.call(jobId),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.neonRed,
                        side:
                            const BorderSide(color: AppColors.neonRed),
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Editing context passed when the propose sheet is being used to
// amend an existing draft — pre-fills the form and switches the
// CTA from "Send proposal" to "Send amended proposal".
class _ProposalEditingContext {
  _ProposalEditingContext({
    required this.jobId,
    required this.categoryId,
    required this.title,
    this.price,
    this.scheduledAt,
  });
  final String jobId;
  final String categoryId;
  final String title;
  final double? price;
  final DateTime? scheduledAt;
}

// ── Propose job bottom sheet ─────────────────────────────────────
class _ProposeJobResult {
  _ProposeJobResult({
    required this.categoryId,
    required this.categoryName,
    required this.title,
    this.price,
    this.scheduledAt,
  });
  final String categoryId;
  final String categoryName;
  final String title;
  final double? price;
  final DateTime? scheduledAt;
}

class _ProposeJobSheet extends StatefulWidget {
  const _ProposeJobSheet({
    required this.workerCategories,
    required this.locale,
    this.isAmend = false,
    this.initialCategoryId,
    this.initialTitle,
    this.initialPrice,
    this.initialScheduledAt,
  });
  final List<Map<String, dynamic>> workerCategories;
  final Locale locale;
  final bool isAmend;
  final String? initialCategoryId;
  final String? initialTitle;
  final double? initialPrice;
  final DateTime? initialScheduledAt;

  @override
  State<_ProposeJobSheet> createState() => _ProposeJobSheetState();
}

class _ProposeJobSheetState extends State<_ProposeJobSheet> {
  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  DateTime? _scheduledAt;
  String? _categoryId;
  String? _categoryName;

  @override
  void initState() {
    super.initState();
    // If amending, pre-fill from initial values; otherwise default
    // category to the worker's first registered skill.
    if (widget.initialTitle != null) _titleCtrl.text = widget.initialTitle!;
    if (widget.initialPrice != null) {
      _priceCtrl.text = widget.initialPrice!.toStringAsFixed(0);
    }
    _scheduledAt = widget.initialScheduledAt;
    Map<String, dynamic>? matchCat;
    if (widget.initialCategoryId != null) {
      for (final s in widget.workerCategories) {
        final cat = s['categories'] as Map<String, dynamic>?;
        if (cat != null && cat['id'] == widget.initialCategoryId) {
          matchCat = cat;
          break;
        }
      }
    }
    matchCat ??=
        widget.workerCategories.first['categories'] as Map<String, dynamic>?;
    if (matchCat != null) {
      _categoryId = matchCat['id'] as String?;
      _categoryName = localizedCategoryName(matchCat, widget.locale);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textDisabled,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(widget.isAmend ? 'Amend the proposal' : 'Propose a job',
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            widget.isAmend
                ? 'Tweak the details and send back for approval.'
                : 'Pick a skill, give it a title, set a price and a date.',
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),
          // Category chips — worker's registered skills only.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.workerCategories.map((s) {
              final cat = s['categories'] as Map<String, dynamic>?;
              if (cat == null) return const SizedBox.shrink();
              final id = cat['id'] as String;
              final name = localizedCategoryName(cat, widget.locale);
              final selected = id == _categoryId;
              return ChoiceChip(
                label: Text(name),
                selected: selected,
                selectedColor: AppColors.neonCyan.withOpacity(0.25),
                labelStyle: TextStyle(
                    color: selected
                        ? AppColors.neonCyan
                        : AppColors.textSecondary),
                onSelected: (_) => setState(() {
                  _categoryId = id;
                  _categoryName = name;
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleCtrl,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'e.g. Fix leaking tap',
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _priceCtrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Price (Rs.)',
              hintText: 'e.g. 1500',
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            icon: const Icon(Icons.calendar_today,
                color: AppColors.neonCyan, size: 16),
            label: Text(
              _scheduledAt == null
                  ? 'Pick date'
                  : _scheduledAt!.toIso8601String().split('T').first,
              style: const TextStyle(color: AppColors.neonCyan),
            ),
            onPressed: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: _scheduledAt ?? now,
                firstDate: now,
                lastDate: now.add(const Duration(days: 365)),
              );
              if (picked != null) setState(() => _scheduledAt = picked);
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final title = _titleCtrl.text.trim();
                if (title.isEmpty || _categoryId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Title and skill are required.')),
                  );
                  return;
                }
                final price = double.tryParse(_priceCtrl.text.trim());
                Navigator.of(context).pop(_ProposeJobResult(
                  categoryId: _categoryId!,
                  categoryName: _categoryName ?? '',
                  title: title,
                  price: price,
                  scheduledAt: _scheduledAt,
                ));
              },
              icon: const Icon(Icons.send, size: 18),
              label: Text(widget.isAmend
                  ? 'Send amended proposal'
                  : 'Send proposal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonAmber,
                foregroundColor: AppColors.scaffoldDark,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Inline location-setup sheet ──────────────────────────────────
// Shown when a customer tries to propose a job from chat but has
// no saved address yet. Detect-button reverse-geocodes the GPS
// fix; the address field is editable so the user can refine it
// before saving. On save → writes to profiles, pops with `true`.
class _LocationSetupSheet extends ConsumerStatefulWidget {
  const _LocationSetupSheet();

  @override
  ConsumerState<_LocationSetupSheet> createState() =>
      _LocationSetupSheetState();
}

class _LocationSetupSheetState extends ConsumerState<_LocationSetupSheet> {
  final _addressCtrl = TextEditingController();
  double? _lat;
  double? _lng;
  bool _locating = false;
  bool _saving = false;

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _detect() async {
    setState(() => _locating = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
        }
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      final address =
          await PlacesService.reverseGeocode(pos.latitude, pos.longitude);
      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
        if (address != null && address.isNotEmpty) {
          _addressCtrl.text = address;
        }
      });
      if (address == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Location pinned, but couldn\'t resolve an address. Type it below.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not get location: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _save() async {
    final typed = _addressCtrl.text.trim();
    setState(() => _saving = true);
    try {
      // If the user typed an address manually without picking a
      // Google suggestion, we don't have coordinates yet — forward-
      // geocode the typed text now so the saved row has both.
      if ((_lat == null || _lng == null) && typed.isNotEmpty) {
        final details = await PlacesService.forwardGeocode(typed);
        if (details != null) {
          _lat = details.lat;
          _lng = details.lng;
          // Use Google's cleaned-up formatted address back in the
          // field so what we save matches what the customer sees.
          _addressCtrl.text = details.formattedAddress;
        }
      }
      if (_lat == null || _lng == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Pick a suggestion, tap Detect, or enter a more specific address.')),
          );
        }
        return;
      }
      await ref.read(currentProfileProvider.notifier).updateLocation(
            lat: _lat!,
            lng: _lng!,
            address: _addressCtrl.text.trim().isEmpty
                ? null
                : _addressCtrl.text.trim(),
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ConstrainedBox caps the sheet at 85% of the screen so it
    // shrink-wraps to content on tall pages and scrolls only if
    // the autocomplete suggestions push it past that limit.
    final maxHeight = MediaQuery.of(context).size.height * 0.85;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textDisabled,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Where is the job?',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              const Text(
                "We need an address so the Waddek knows where to come. We'll save it to your profile for next time.",
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 16),
              NeonButton(
                label: 'Detect my location',
                icon: Icons.my_location,
                isLoading: _locating,
                onPressed: _detect,
              ),
              const SizedBox(height: 16),
              AddressLookupField(
                controller: _addressCtrl,
                label: 'Address',
                hint: 'e.g. 12/4, Galle Road, Wellawatte',
                onSelected: (addr, lat, lng) {
                  setState(() {
                    _lat = lat;
                    _lng = lng;
                  });
                },
              ),
              const SizedBox(height: 20),
              NeonButton(
                label: 'Save and continue',
                icon: Icons.check,
                isLoading: _saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
