import "package:age_sync/pages/approve_org_page.dart";
import "package:age_sync/pages/chat/spectate_room_page.dart";
import "package:age_sync/pages/view_account_page.dart";
import "package:age_sync/utils/constants.dart";
import "package:age_sync/utils/loading_state.dart";
import "package:age_sync/utils/organization.dart";
import "package:age_sync/utils/profile.dart";
import "package:age_sync/utils/room.dart";
import "package:age_sync/utils/task.dart";
import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  static const routeName = "/admin";

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends LoadingState<AdminPage>
    with SingleTickerProviderStateMixin {
  late Profile _profile;
  late TabController _tabController;
  late List<Profile> _profiles;
  late List<Task> _tasks;
  late List<RoomMeta> _rooms;
  late List<OrganizationMeta> _organizations;
  List<OrganizationMeta> _filteredOrgs = [];
  String _filter = "All";

  static final _tabs = [
    const Tab(icon: Icon(Icons.person), text: "Profiles"),
    const Tab(icon: Icon(Icons.task), text: "Tasks"),
    const Tab(icon: Icon(Icons.message), text: "Messages"),
    const Tab(icon: Icon(Icons.business), text: "Organizations"),
    const Tab(icon: Icon(Icons.report), text: "Reports"),
  ];

  @override
  AppBar get loadingAppBar => AppBar(title: const Text("Admin Page"));

  @override
  AppBar get loadedAppBar => AppBar(
        title: const Text("Admin Page"),
        bottom: _profile.admin
            ? TabBar(
                controller: _tabController,
                tabs: _tabs,
              )
            : null,
      );

  @override
  onInit() async {
    final profile = await supabase.getCurrentUser();
    List<dynamic> profiles = await supabase.from("profiles").select();
    List<dynamic> tasks = await supabase.from("tasks").select();
    List<dynamic> rooms = await supabase.from("rooms").select();
    List<RoomMeta> roomMetas = await Future.wait(
        rooms.map((room) => RoomMeta.fromRoomId(room["id"])).toList());
    List<dynamic> organizations = await supabase.from("organizations").select();
    List<OrganizationMeta> orgMetas = await Future.wait(organizations
        .map((org) => OrganizationMeta.fromId(org["id"]))
        .toList());

    setState(() {
      _profile = profile;
      _profiles = profiles.map((profile) => Profile.fromMap(profile)).toList();
      _tasks = tasks.map((task) => Task.fromMap(task)).toList();
      _rooms = roomMetas;
      _tabController = TabController(
        length: _tabs.length,
        vsync: this,
      );
      _organizations = orgMetas;
      _filteredOrgs = _organizations;
    });
  }

  @override
  Widget buildLoaded(BuildContext context) {
    if (!_profile.admin) {
      return const Center(
        child: Text("You are not an admin"),
      );
    }

    return DefaultTabController(
      length: _tabs.length,
      child: TabBarView(
        controller: _tabController,
        children: [
          ListView.builder(
              shrinkWrap: true,
              itemCount: _profiles.length,
              itemBuilder: (context, index) {
                final profile = _profiles[index];

                return Card(
                    child: GestureDetector(
                  onTap: () {
                    context.pushNamed(ViewAccountPage.routeName,
                        arguments: profile);
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(
                        profile.avatarUrl,
                      ),
                    ),
                    title: Text(profile.name),
                    subtitle: Text(
                        profile.admin
                            ? "Admin"
                            : profile.organization
                                ? "Organization"
                                : "Volunteer",
                        style: TextStyle(
                            color: profile.admin
                                ? Colors.red
                                : profile.organization
                                    ? Colors.blue
                                    : Colors.green)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final sure = await context
                            .confirmation('delete ${profile.name}\'s profile');

                        if (!sure) {
                          return;
                        }

                        await supabase
                            .from("profiles")
                            .delete()
                            .eq("id", profile.id);

                        setState(() {
                          _profiles.remove(profile);
                        });
                      },
                    ),
                  ),
                ));
              }),
          ListView.builder(
              shrinkWrap: true,
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];

                return Card(
                    child: ListTile(
                  title: Text(task.name),
                  subtitle: Text(task.details),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      final sure = await context
                          .confirmation('delete the task "${task.name}"');

                      if (!sure) {
                        return;
                      }

                      await supabase.from("tasks").delete().eq("id", task.id);

                      setState(() {
                        _tasks.remove(task);
                      });
                    },
                  ),
                ));
              }),
          ListView.builder(
              shrinkWrap: true,
              itemCount: _rooms.length,
              itemBuilder: (context, index) {
                final room = _rooms[index];

                return GestureDetector(
                  onTap: () async {
                    context.pushNamed(SpectateChatRoomPage.routeName,
                        arguments: room.room.id);
                  },
                  child: Card(
                      child: ListTile(
                    title: Text('${room.user1.name} and ${room.user2.name}'),
                    subtitle: Text(room.lastMessage?.content ?? 'No messages'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final sure = await context.confirmation(
                            'delete the chat between ${room.user1.name} and ${room.user2.name}');

                        if (!sure) {
                          return;
                        }

                        await supabase
                            .from("rooms")
                            .delete()
                            .eq("id", room.room.id);

                        setState(() {
                          _rooms.remove(room);
                        });
                      },
                    ),
                  )),
                );
              }),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  children: [
                    const Text('Filter by '),
                    const SizedBox(width: 10),
                    DropdownButton(
                      value: _filter,
                      items: const [
                        DropdownMenuItem(
                          value: 'All',
                          child: Text('All'),
                        ),
                        DropdownMenuItem(
                          value: 'Pending',
                          child: Text('Pending'),
                        ),
                        DropdownMenuItem(
                          value: 'Approved',
                          child: Text('Approved'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == "All") {
                          _filteredOrgs = _organizations;
                        } else if (value == "Pending") {
                          _filteredOrgs = _organizations
                              .where((org) => !org.organization.verified)
                              .toList();
                        } else if (value == "Approved") {
                          _filteredOrgs = _organizations
                              .where((org) => org.organization.verified)
                              .toList();
                        }

                        setState(() {
                          _filter = value.toString();
                        });
                      },
                    ),
                  ],
                ),
              ),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredOrgs.length,
                  itemBuilder: (context, index) {
                    final org = _filteredOrgs[index];

                    return Card(
                        child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                          org.profile.avatarUrl,
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(org.organization.name),
                          if (org.organization.verified)
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Icon(
                                Icons.verified,
                                color: Colors.green,
                              ),
                            )
                          else if (!org.organization.verified)
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.not_interested,
                                    color: Colors.amber,
                                  ),
                                  SizedBox(width: 4),
                                  Text("Pending approval",
                                      style: TextStyle(color: Colors.amber))
                                ],
                              ),
                            )
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(org.organization.mission),
                          if (!org.organization.verified)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                    onPressed: () async {
                                      await context.pushNamed(
                                          ApproveOrgPage.routeName,
                                          arguments: org);

                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.check),
                                    label: const Text("Approve")),
                              ),
                            )
                        ],
                      ),
                    ));
                  }),
            ],
          ),
          const Center(child: Text("Reports")),
        ],
      ),
    );
  }
}
