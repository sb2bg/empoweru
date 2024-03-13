import 'package:age_sync/utils/loading_state.dart';
import 'package:age_sync/utils/organization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../utils/constants.dart';

class ApproveOrgPage extends StatefulWidget {
  static const routeName = '/approve-widget.org';

  const ApproveOrgPage({super.key, required this.org});

  final OrganizationMeta org;

  @override
  State<ApproveOrgPage> createState() => _ApproveOrgPageState();
}

class _ApproveOrgPageState extends LoadingState<ApproveOrgPage> {
  bool _showMore = false;

  @override
  AppBar get constAppBar => AppBar(
        title: const Text('Review'),
      );

  @override
  Future<void> onInit() async {}

  @override
  Widget buildLoaded(BuildContext context) {
    return Padding(
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
              leading:
                  CachedNetworkImage(imageUrl: widget.org.profile.avatarUrl),
              title: Text(widget.org.organization.name),
              subtitle: Text(widget.org.organization.name),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.email),
              title: Text(widget.org.organization.email),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.phone),
              title: Text(widget.org.organization.phone.isEmpty
                  ? 'No number provided'
                  : widget.org.organization.phone),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.location_on),
              title: Text(
                  "${widget.org.organization.address} ${widget.org.organization.city}, ${widget.org.organization.state} ${widget.org.organization.zip}"),
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
          if (_showMore)
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    children: [
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.description),
                          title: Text(widget.org.organization.mission),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.category),
                          title: Text(widget.org.organization.type),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.language),
                          title: Text(widget.org.organization.website.isEmpty
                              ? 'No website'
                              : widget.org.organization.website),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.facebook),
                          title: Text(widget.org.organization.facebook.isEmpty
                              ? 'No Facebook'
                              : widget.org.organization.facebook),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.one_x_mobiledata),
                          title: Text(widget.org.organization.twitter.isEmpty
                              ? 'No Twitter'
                              : widget.org.organization.twitter),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.camera_alt_outlined),
                          title: Text(widget.org.organization.instagram.isEmpty
                              ? 'No Instagram'
                              : widget.org.organization.instagram),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.credit_card),
                          title: Text(widget.org.organization.ein.isEmpty
                              ? 'No EIN provided'
                              : widget.org.organization.ein),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
                      onConfirm: () async {
                        await supabase
                            .from('organizations')
                            .update({'verified': true}).eq(
                                'id', widget.org.organization.id);

                        widget.org.organization.verified = true;

                        if (mounted) {
                          context.showSnackBar(
                              message:
                                  'Organization approved and added to the platform.',
                              backgroundColor: Colors.green);
                          context.pop();
                        }
                      });
                },
                label: const Text('Approve'),
                icon: const Icon(Icons.check),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () {
                  context.showConfirmationDialog(
                      title: 'Confirm',
                      message:
                          'This will delete the organization and all its data. Are you sure you want to deny this organization?',
                      confirmText: 'Yes, delete it.',
                      onConfirm: () {
                        supabase
                            .from('organizations')
                            .delete()
                            .eq('id', widget.org.organization.id);

                        context.pop();
                      });
                },
                icon: const Icon(Icons.delete),
                label: const Text('Deny'),
              ),
            ],
          ),
          SizedBox(height: context.bottomPadding),
        ],
      ),
    );
  }
}
