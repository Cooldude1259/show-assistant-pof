import 'package:flutter/material.dart';

import '../models.dart';
import '../services/show_service.dart';
import '../theme.dart';
import '../widgets/venue_map.dart';
import 'live_show_screen.dart';

/// Audience view: a digital programme. No scene list, nothing that gives
/// the show away.
class AudienceScreen extends StatelessWidget {
  const AudienceScreen({super.key, required this.service, required this.show});

  final ShowService service;
  final AudienceShow show;

  @override
  Widget build(BuildContext context) {
    // Pushed routes take the app's theme, not the screen that pushed them,
    // so this screen applies the programme theme itself.
    return Theme(
      data: playbillTheme(),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 240,
              backgroundColor: Playbill.bg,
              foregroundColor: Playbill.cream,
              title: const Text('Programme', style: TextStyle(fontFamily: Playbill.serif)),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: _Hero(show: show),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              sliver: SliverList.list(
                children: [
                  _StatusCard(show: show),
                  const SizedBox(height: 12),
                  for (final notice in show.notices) _Notice(text: notice),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                      builder: (_) => LiveShowScreen(service: service, showTitle: show.title),
                    )),
                    style: FilledButton.styleFrom(
                      backgroundColor: Playbill.gold,
                      foregroundColor: Playbill.bg,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Preview show mode',
                        style: TextStyle(fontFamily: Playbill.serif, fontSize: 18)),
                  ),
                  const _SectionTitle('About the show'),
                  Text(show.bio,
                      style: const TextStyle(
                          fontFamily: Playbill.serif, fontSize: 17, height: 1.5)),
                  const _SectionTitle('Cast'),
                  for (final member in show.cast) _CastRow(member: member),
                  const _SectionTitle('Find your way'),
                  const VenueMap(),
                  const _SectionTitle('At the venue'),
                  for (final info in show.venueInfo) _VenueRow(info: info),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.show});

  final AudienceShow show;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Playbill.curtain, Playbill.bg],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      alignment: Alignment.bottomLeft,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(show.title,
              style: const TextStyle(
                  fontFamily: Playbill.serif, fontSize: 40, color: Playbill.cream)),
          const SizedBox(height: 4),
          Text(show.tagline,
              style: const TextStyle(
                  fontFamily: Playbill.serif,
                  fontStyle: FontStyle.italic,
                  color: Playbill.muted,
                  fontSize: 16)),
          const SizedBox(height: 12),
          Text('${show.venue}  ·  ${show.dateLine}',
              style: const TextStyle(
                  color: Playbill.gold, letterSpacing: 1, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.show});

  final AudienceShow show;

  @override
  Widget build(BuildContext context) {
    final (label, icon) = switch (show.status) {
      AudienceStatus.preShow => ('BEFORE THE SHOW', Icons.event_seat_outlined),
      AudienceStatus.inProgress => ('NOW PLAYING', Icons.theater_comedy),
      AudienceStatus.interval => ('INTERVAL', Icons.local_cafe_outlined),
      AudienceStatus.ended => ('THANK YOU', Icons.favorite_border),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Playbill.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Playbill.gold.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Playbill.gold, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Playbill.gold,
                        letterSpacing: 2,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(show.statusLine,
                    style: const TextStyle(fontFamily: Playbill.serif, fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.info_outline, size: 18, color: Playbill.gold),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(color: Playbill.muted))),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text,
              style: const TextStyle(
                  fontFamily: Playbill.serif, fontSize: 26, color: Playbill.cream)),
          const SizedBox(height: 6),
          Container(width: 48, height: 2, color: Playbill.gold),
        ],
      ),
    );
  }
}

class _CastRow extends StatelessWidget {
  const _CastRow({required this.member});

  final CastMember member;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(member.character,
                style: const TextStyle(
                    fontFamily: Playbill.serif, fontStyle: FontStyle.italic, fontSize: 18)),
          ),
          Text(member.performer, style: const TextStyle(color: Playbill.muted)),
        ],
      ),
    );
  }
}

class _VenueRow extends StatelessWidget {
  const _VenueRow({required this.info});

  final VenueInfo info;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(info.icon, color: Playbill.gold),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(info.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(info.detail, style: const TextStyle(color: Playbill.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
