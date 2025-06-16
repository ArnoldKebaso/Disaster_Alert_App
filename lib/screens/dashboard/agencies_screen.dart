// lib/screens/dashboard/agencies_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../widgets/app_shell.dart';

/// Model classes
class Agency {
  final int id;
  final String name;
  final String description;
  final List<Service> services;

  const Agency({
    required this.id,
    required this.name,
    required this.description,
    required this.services,
  });
}

class Service {
  final String name;
  final String icon;

  const Service({required this.name, required this.icon});
}

/// Static list of agencies
const _agencies = <Agency>[
  Agency(
    id: 1,
    name: 'Kenya Red Cross',
    description:
        'Providing emergency response and disaster relief services across Kenya.',
    services: [
      Service(name: 'Emergency Response', icon: '🚑'),
      Service(name: 'First Aid Training', icon: '🩹'),
      Service(name: 'Disaster Preparedness', icon: '📦'),
    ],
  ),
  Agency(
    id: 2,
    name: 'National Disaster Management Unit (NDMU)',
    description:
        'Specialized in managing national emergencies and disaster response.',
    services: [
      Service(name: 'Flood Management', icon: '🌊'),
      Service(name: 'Fire Rescue', icon: '🔥'),
      Service(name: 'Earthquake Relief', icon: '🏚️'),
    ],
  ),
  Agency(
    id: 3,
    name: 'Kenya Meteorological Department',
    description:
        'Providing weather and climate information to mitigate natural disasters.',
    services: [
      Service(name: 'Weather Forecasting', icon: '🌦️'),
      Service(name: 'Climate Risk Analysis', icon: '📊'),
      Service(name: 'Early Warnings', icon: '⚠️'),
    ],
  ),
  Agency(
    id: 4,
    name: 'St. John Ambulance Kenya',
    description:
        'Delivering lifesaving support and ambulance services nationwide.',
    services: [
      Service(name: 'Ambulance Services', icon: '🚑'),
      Service(name: 'Emergency Medical Response', icon: '💉'),
      Service(name: 'Health Education', icon: '📚'),
    ],
  ),
  Agency(
    id: 5,
    name: 'Kenya Wildlife Service (KWS)',
    description: 'Specialized in wildlife-related disaster response.',
    services: [
      Service(name: 'Wildlife Rescue', icon: '🐘'),
      Service(name: 'Conflict Mitigation', icon: '⚔️'),
      Service(name: 'Environmental Conservation', icon: '🌍'),
    ],
  ),
  Agency(
    id: 6,
    name: 'Kenya Defense Forces (KDF)',
    description:
        'Assisting in disaster recovery and national security during emergencies.',
    services: [
      Service(name: 'Search and Rescue', icon: '🔍'),
      Service(name: 'Flood Relief', icon: '🏞️'),
      Service(name: 'Logistical Support', icon: '🚛'),
    ],
  ),
  Agency(
    id: 7,
    name: 'World Health Organization (Kenya)',
    description:
        'Supporting public health efforts during disasters and pandemics.',
    services: [
      Service(name: 'Disease Control', icon: '🦠'),
      Service(name: 'Emergency Healthcare', icon: '🏥'),
      Service(name: 'Vaccination Drives', icon: '💉'),
    ],
  ),
  Agency(
    id: 8,
    name: 'Kenya Forest Service',
    description: 'Managing forest fires and environmental disasters.',
    services: [
      Service(name: 'Firefighting', icon: '🔥'),
      Service(name: 'Forest Conservation', icon: '🌲'),
      Service(name: 'Climate Monitoring', icon: '🌡️'),
    ],
  ),
  Agency(
    id: 9,
    name: 'UNHCR Kenya',
    description: 'Protecting and assisting refugees during crises.',
    services: [
      Service(name: 'Refugee Protection', icon: '🛡️'),
      Service(name: 'Shelter Provision', icon: '🏠'),
      Service(name: 'Humanitarian Aid', icon: '🤝'),
    ],
  ),
  Agency(
    id: 10,
    name: 'Kenya Maritime Authority',
    description: 'Managing marine disasters and enhancing water safety.',
    services: [
      Service(name: 'Maritime Rescue', icon: '🚤'),
      Service(name: 'Oil Spill Response', icon: '🛢️'),
      Service(name: 'Water Safety Training', icon: '💧'),
    ],
  ),
];

/// ───────────────────────────────────────────────────────────
/// UI
/// ───────────────────────────────────────────────────────────
class AgenciesScreen extends ConsumerStatefulWidget {
  const AgenciesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AgenciesScreen> createState() => _AgenciesScreenState();
}

class _AgenciesScreenState extends ConsumerState<AgenciesScreen> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossCount = width >= 1024
        ? 3
        : width >= 600
            ? 2
            : 1;

    return AppShell(
      isAdmin: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              'Emergency Response Partners',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Connect with certified disaster response agencies ready to provide immediate assistance',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            // Grid of agency cards
            GridView.builder(
              itemCount: _agencies.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 4 / 3,
              ),
              itemBuilder: (ctx, idx) {
                final agency = _agencies[idx];
                return Material(
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                agency.services[0].icon,
                                style: const TextStyle(fontSize: 32),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                agency.name,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: Text(
                                  agency.description,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 300.ms, delay: (100 * idx).ms)
                            .slideY(
                                begin: 0.2,
                                duration: 300.ms,
                                delay: (100 * idx).ms),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => _showDetails(context, agency),
                          child: const Text('View Services'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, Agency agency) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16) +
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    agency.name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
              const SizedBox(height: 8),
              Text(agency.description),
              const SizedBox(height: 16),
              const Text(
                'Key Services',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...agency.services.map((s) {
                return ListTile(
                  leading: Text(s.icon, style: const TextStyle(fontSize: 24)),
                  title: Text(s.name),
                );
              }).toList(),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
