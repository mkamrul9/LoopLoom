import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'looploom_theme.dart';

enum FeedbackCategory { bug, idea, question }

Uri feedbackMailto(FeedbackCategory category, String message) {
  final subject = switch (category) {
    FeedbackCategory.bug => 'LoopLoom bug report',
    FeedbackCategory.idea => 'LoopLoom idea',
    FeedbackCategory.question => 'LoopLoom question',
  };
  return Uri(
    scheme: 'mailto',
    path: 'cdkamrul9@gmail.com',
    queryParameters: {'subject': subject, 'body': message.trim()},
  );
}

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _message = TextEditingController();
  FeedbackCategory _category = FeedbackCategory.bug;
  bool _opening = false;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  void _show(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  Future<void> _openDraft() async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      final opened = await launchUrl(
        feedbackMailto(_category, _message.text),
        mode: LaunchMode.externalApplication,
      );
      if (!opened && mounted) {
        _show(
          'No email app opened. Copy the address below and send from your mail app.',
        );
      }
    } catch (_) {
      if (mounted) {
        _show(
          'No email app opened. Copy the address below and send from your mail app.',
        );
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Feedback & contact')),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text('HELP SHAPE LOOPLOOM', style: noteLabel),
              const SizedBox(height: 10),
              const Text(
                'Tell us what you found.',
                style: TextStyle(fontSize: 29, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Text(
                'Report a bug, share an idea, or ask the team a question. Your email app will open a draft that you can review before sending.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.55,
                  color: context.palette.muted,
                ),
              ),
              const SizedBox(height: 24),
              const Text('WHAT IS THIS ABOUT?', style: noteLabel),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    [
                          (FeedbackCategory.bug, 'Bug report'),
                          (FeedbackCategory.idea, 'Idea or opinion'),
                          (FeedbackCategory.question, 'Contact team'),
                        ]
                        .map(
                          (item) => ChoiceChip(
                            label: Text(item.$2),
                            selected: _category == item.$1,
                            onSelected: (_) =>
                                setState(() => _category = item.$1),
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _message,
                minLines: 5,
                maxLines: 10,
                decoration: const InputDecoration(
                  labelText: 'Your message (optional)',
                  hintText:
                      'What happened, or what would make practice better?',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _opening ? null : _openDraft,
                icon: const Icon(Icons.mail_outline),
                label: const Text('Open email draft'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(
                    const ClipboardData(text: 'cdkamrul9@gmail.com'),
                  );
                  if (mounted) _show('Email address copied.');
                },
                icon: const Icon(Icons.copy_outlined),
                label: const Text('Copy cdkamrul9@gmail.com'),
              ),
              const SizedBox(height: 18),
              Text(
                'The app does not send your message automatically. Please avoid including passwords or private code.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: context.palette.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
