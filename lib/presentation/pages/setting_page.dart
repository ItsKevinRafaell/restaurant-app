import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/presentation/providers/notification/local_notification_provider.dart';
import 'package:restaurant_app/presentation/themes/providers/theme_provider.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
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
                    onPressed: () async {
                      await context
                          .read<LocalNotificationProvider>()
                          .requestPermissions();
                    },
                    child: const Text("Minta Izin Notifikasi"),
                  ),
                  const SizedBox(height: 16),
                  Consumer<LocalNotificationProvider>(
                    builder: (context, notificationProvider, _) {
                      return ListTile(
                        title: const Text('Notifikasi Harian'),
                        subtitle: const Text(
                            'Dapatkan rekomendasi restoran setiap hari'),
                        trailing: Switch(
                          value: notificationProvider.isScheduled,
                          onChanged: (value) async {
                            await notificationProvider
                                .enableNotification(value);
                          },
                        ),
                      );
                    },
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
