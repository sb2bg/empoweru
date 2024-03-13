import 'package:age_sync/pages/view_account_page.dart';
import 'package:age_sync/utils/constants.dart';
import 'package:age_sync/utils/loading_state.dart';
import 'package:age_sync/utils/organization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class OpportunityPage extends StatefulWidget {
  const OpportunityPage({super.key});

  @override
  State<OpportunityPage> createState() => _OpportunityPageState();
}

class _OpportunityPageState extends LoadingState<OpportunityPage> {
  List<OrganizationMeta> _organizations = [];

  @override
  Future<void> onInit() async {
    List<dynamic> maps =
        await supabase.from('organizations').select().eq('verified', true);

    List<OrganizationMeta> organizations =
        await Future.wait(maps.map((e) async {
      return await OrganizationMeta.fromId(e['id']);
    }));

    setState(() {
      _organizations = organizations;
    });
  }

  @override
  AppBar get constAppBar => AppBar(
        title: const Text('Find Opportunities'),
      );

  @override
  Widget buildLoaded(BuildContext context) {
    return _organizations.isEmpty
        ? const Center(child: Text('No opportunities found. Check back later.'))
        : ListView.builder(
            itemCount: _organizations.length,
            itemBuilder: (context, index) {
              final organization = _organizations[index];

              return OrganizationCard(
                organization: organization.organization,
                avatarUrl: organization.profile.avatarUrl,
                onPressed: () {
                  context.pushNamed(ViewAccountPage.routeName,
                      arguments: organization.profile);
                },
              );
            },
          );
  }
}

class OrganizationCard extends StatelessWidget {
  final Organization organization;
  final String avatarUrl;
  final VoidCallback onPressed;

  const OrganizationCard({
    super.key,
    required this.organization,
    required this.avatarUrl,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(avatarUrl),
        ),
        title: Text(organization.name),
        subtitle: Text(organization.mission),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onPressed,
      ),
    );
  }
}
