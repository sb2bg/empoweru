import 'package:age_sync/utils/organization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../utils/constants.dart';

class ApproveOrgPage extends StatefulWidget {
  static const routeName = '/approve-widget.org';

  const ApproveOrgPage({Key? key, required this.org}) : super(key: key);

  final Organization org;

  @override
  State<ApproveOrgPage> createState() => _ApproveOrgPageState();
}

class _ApproveOrgPageState extends State<ApproveOrgPage> {
  bool _showMore = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Approve Organization'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              'Approve Organization',
              style: titleStyle,
            ),
            const SizedBox(height: 10),
            const Text(
              'This organization has requested to be on the platform.',
              style: whiteMetaStyle,
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: CachedNetworkImage(imageUrl: widget.org.logo),
                title: Text(widget.org.name),
                subtitle: Text(widget.org.mission),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.email),
                title: Text(widget.org.email),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.phone),
                title: Text(widget.org.phone),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(widget.org.address),
              ),
            ),
            Card(
                child: ListTile(
                    leading: const Icon(Icons.keyboard_arrow_down),
                    title: Text('Show ${_showMore ? 'Less' : 'More'}'),
                    onTap: () {
                      setState(() {
                        _showMore = !_showMore;
                      });
                    })),
            if (_showMore) ErrorWidget(Exception('Show more not implemented')),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    context.showConfirmationDialog(
                        title: 'Confirm',
                        message:
                            'Have you verified the information provided and would like to approve this organization?',
                        confirmText: 'Approve',
                        onConfirm: () {
                          widget.org.verified = true;

                          supabase.from('organizations').update(
                              {'approved': true}).eq('id', widget.org.id);
                          context.pop();
                        });
                  },
                  label: const Text('Approve'),
                  icon: const Icon(Icons.check),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    supabase
                        .from('organizations')
                        .delete()
                        .eq('id', widget.org.id);

                    context.pop();
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text('Deny'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
