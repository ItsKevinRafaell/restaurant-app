import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:restaurant_app/presentation/providers/notification/local_notification_provider.dart';
import 'package:restaurant_app/presentation/themes/theme_provider.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    // Update every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  Future<void> _requestPermissions() async {
    await context.read<LocalNotificationProvider>().requestPermissions();
  }

  Future<void> _toggleDailyReminder() async {
    final provider = context.read<LocalNotificationProvider>();
    await provider.enableNotification(!provider.isScheduled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Theme Settings
            const Text(
              'Pengaturan Tema',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              child: Column(
                children: [
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, _) {
                      return ListTile(
                        title: const Text('Light Theme'),
                        leading: Radio<ThemeMode>(
                          value: ThemeMode.light,
                          groupValue: themeProvider.themeMode,
                          onChanged: (value) {
                            themeProvider.toggleTheme(value == ThemeMode.dark);
                          },
                        ),
                      );
                    },
                  ),
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, _) {
                      return ListTile(
                        title: const Text('Dark Theme'),
                        leading: Radio<ThemeMode>(
                          value: ThemeMode.dark,
                          groupValue: themeProvider.themeMode,
                          onChanged: (value) {
                            themeProvider.toggleTheme(value == ThemeMode.dark);
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 2: Notification Settings
            const Text(
              'Pengaturan Notifikasi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Status Izin Notifikasi'),
                    trailing: Consumer<LocalNotificationProvider>(
                      builder: (context, notificationProvider, _) {
                        return Text(
                          notificationProvider.permission == true
                              ? "Izin Diberikan ✅"
                              : "Izin Ditolak ❌",
                          style: TextStyle(
                            color: notificationProvider.permission == true
                                ? Colors.green
                                : Colors.red,
                          ),
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _requestPermissions,
                    child: const Text("Minta Izin Notifikasi"),
                  ),
                  const SizedBox(height: 16),
                  // Daily Restaurant Reminder Section
                  ListTile(
                    title: const Text('Notifikasi Harian'),
                    subtitle: const Text('Dapatkan rekomendasi restoran setiap hari'),
                    trailing: Consumer<LocalNotificationProvider>(
                      builder: (context, notificationProvider, _) {
                        if (!notificationProvider.isScheduled) {
                          return const Text('Dimatikan ❌',
                              style: TextStyle(color: Colors.red));
                        }

                        final nextNotification = notificationProvider.getNextNotificationTime();
                        final now = DateTime.now();
                        final remaining = nextNotification.difference(now);

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Aktif ✅',
                                style: TextStyle(color: Colors.green)),
                            const SizedBox(height: 4),
                            Text(
                              'Dalam: ${_formatDuration(remaining)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    onTap: _toggleDailyReminder,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
