import 'package:age_sync/pages/auth/org_sign_up_stage.dart';
import 'package:age_sync/utils/constants.dart';
import 'package:flutter/material.dart';

class OrgSignUpPage extends StatefulWidget {
  static const routeName = '/org-sign-up';
  static const beta = false;

  const OrgSignUpPage({super.key});

  @override
  State<OrgSignUpPage> createState() => _OrgSignUpPageState();
}

class _OrgSignUpPageState extends State<OrgSignUpPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  update() {
    setState(() {});
  }

  final List<OrgStage> _stages = [];
  bool _submitting = false;

  @override
  void initState() {
    super.initState();

    _stages.addAll([
      OrgStage(
        key: const Key('org-info'),
        parentSetState: update,
        submitted: ValueNotifier(false),
        title: 'First, tell us about your organization',
        subtitle: 'This information will be displayed on your profile',
        fields: [
          FieldInfo(
              'Organization Name',
              Icons.person,
              (name) =>
                  name.isEmpty ? 'Organization name cannot be empty' : null),
          FieldInfo(
              'Organization Mission',
              Icons.description,
              (mission) => mission.isEmpty
                  ? 'Organization mission cannot be empty'
                  : null),
          FieldInfo(
              'Organization Type',
              Icons.category,
              (type) =>
                  type.isEmpty ? 'Organization type cannot be empty' : null),
        ],
      ),
      OrgStage(
        key: const Key('org-contact'),
        parentSetState: update,
        submitted: ValueNotifier(false),
        title:
            'Now, let\'s get your organization\'s contact information, address, and other details',
        subtitle:
            'This information will not be displayed on your profile, unless you choose to do so',
        fields: [
          FieldInfo('Address', Icons.location_on,
              (address) => address.isEmpty ? 'Address cannot be empty' : null),
          FieldInfo('City', Icons.location_city,
              (city) => city.isEmpty ? 'City cannot be empty' : null),
          FieldInfo('State', Icons.location_city,
              (state) => state.isEmpty ? 'State cannot be empty' : null),
          FieldInfo('Zip Code', Icons.location_city, (zip) {
            if (zip.isEmpty) {
              return 'Zip code cannot be empty';
            }

            if (zip.length != 5 || int.tryParse(zip) == null) {
              return 'Zip code must be 5 digits';
            }

            return null;
          }),
          FieldInfo('Phone Number', Icons.phone, (phone) {
            if (phone.isEmpty) {
              return null;
            }

            if (phone.length != 10 || int.tryParse(phone) == null) {
              return 'Phone number must be 10 digits';
            }

            return null;
          }, textInputType: TextInputType.phone),
          FieldInfo('EIN (XX-XXXXXXX)', Icons.credit_card, (ein) {
            if (ein.isEmpty) {
              return null;
            }

            final einRegex = RegExp(r'^\d{2}-?\d{7}$');

            if (!einRegex.hasMatch(ein)) {
              return 'EIN must be in the format XX-XXXXXXX';
            }

            return null;
          }),
        ],
      ),
      OrgStage(
        key: const Key('org-social'),
        parentSetState: update,
        submitted: ValueNotifier(false),
        title:
            'Next, let\'s get your organization\'s social media links, website, and logo',
        subtitle: 'This helps build your organization\'s profile',
        fields: [
          FieldInfo('Contact Email', Icons.email,
              (email) => email.isEmpty ? 'Email cannot be empty' : null),
          FieldInfo('Website', Icons.web, (website) => null),
          FieldInfo('Facebook', Icons.facebook, (facebook) => null),
          FieldInfo('Twitter', Icons.south_america_outlined, (twitter) => null),
          FieldInfo(
              'Instagram', Icons.south_america_outlined, (instagram) => null),
          FieldInfo('Logo', Icons.image, (logo) => null),
        ],
      ),
      OrgStage(
        key: const Key('org-account'),
        parentSetState: update,
        submitted: ValueNotifier(false),
        title: 'Finally, let\'s create your account',
        subtitle: 'This will be used to log in to your account',
        fields: [
          FieldInfo('Email', Icons.email,
              (email) => email.isEmpty ? 'Email cannot be empty' : null),
          FieldInfo(
            password: true,
            'Password',
            Icons.lock,
            (password) => password.length < 6
                ? 'Password must be at least 6 characters'
                : null,
          ),
        ],
      )
    ]);

    _tabController = TabController(vsync: this, length: _stages.length);
  }

  int _currentStage = 0;

  @override
  void dispose() {
    for (final stage in _stages) {
      for (final controller in stage.controllers) {
        controller.dispose();
      }
    }

    _tabController.dispose();
    super.dispose();
  }

  Future<void> signUpOrganization() async {
    try {
      if (!_stages[_currentStage].isValid) {
        _stages[_currentStage].submitted.value = true;
        return;
      }

      context.showConfirmationDialog(
          title: 'Submit application?',
          message: 'Are you sure you want to submit your application?',
          confirmText: 'Submit',
          onConfirm: () async {
            setState(() {
              _submitting = true;
            });

            final signUpResponse = await supabase.auth.signUp(
                email: _stages[3].controllers[0].text,
                password: _stages[3].controllers[1].text,
                data: {
                  'full_name': _stages[0].controllers[0].text,
                  if (_stages[2].controllers[5].text.isNotEmpty)
                    'avatar_url': _stages[2].controllers[5].text,
                });

            if (signUpResponse.user == null && mounted) {
              context.showErrorSnackBar(
                message: 'Error signing up',
              );

              context.pop();
              return;
            }

            final orgInsertResponse =
                await supabase.from('organizations').insert({
              'name': _stages[0].controllers[0].text,
              'mission': _stages[0].controllers[1].text,
              'type': _stages[0].controllers[2].text,
              'address': _stages[1].controllers[0].text,
              'city': _stages[1].controllers[1].text,
              'state': _stages[1].controllers[2].text,
              'zip': _stages[1].controllers[3].text,
              'phone': _stages[1].controllers[4].text,
              'ein': _stages[1].controllers[5].text,
              'email': _stages[2].controllers[0].text,
              'website': _stages[2].controllers[1].text,
              'facebook': _stages[2].controllers[2].text,
              'twitter': _stages[2].controllers[3].text,
              'instagram': _stages[2].controllers[4].text,
              'logo': _stages[2].controllers[5].text,
            }).select('id');

            await supabase.from('profiles').update({
              'organization': orgInsertResponse[0]['id'],
            }).eq('id', signUpResponse.user!.id);

            if (mounted) {
              context.showSnackBar(
                message:
                    'Successfully completed organization sign up. We will review your application and get back to you soon.',
                backgroundColor: Colors.green,
              );

              context.pop();
            }
          });
    } catch (error) {
      if (mounted) {
        context.showErrorSnackBar(
          message: 'Error signing up',
        );
      }

      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organization Sign Up'),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: _stages,
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              if (_currentStage > 0)
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _tabController.animateTo(--_currentStage);
                    });
                  },
                  icon: const Text('Previous'),
                  label: const Icon(Icons.arrow_back),
                ),
              Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: _currentStage < _stages.length - 1
                      ? ElevatedButton.icon(
                          onPressed: () {
                            if (!_stages[_currentStage].isValid) {
                              _stages[_currentStage].submitted.value = true;
                              return;
                            }

                            setState(() {
                              _tabController.animateTo(++_currentStage);
                            });
                          },
                          icon: const Text('Next'),
                          label: const Icon(Icons.arrow_forward),
                        )
                      : ElevatedButton.icon(
                          onPressed: _submitting ? null : signUpOrganization,
                          icon: const Text('Finish'),
                          label: const Icon(Icons.check),
                        ))
            ]),
            SizedBox(height: context.bottomPadding),
          ],
        ),
      ),
    );
  }
}
