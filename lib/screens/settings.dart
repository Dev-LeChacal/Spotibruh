import "package:flutter/material.dart";
import "package:hugeicons_pro/hugeicons.dart";
import "package:spotibruh/app.dart";
import "package:spotibruh/extensions.dart";
import "package:spotibruh/services/auth/index.dart";
import "package:spotibruh/services/storage/prefs.dart";
import "package:spotibruh/utils/color.dart";
import "package:spotibruh/widgets/button.dart";
import "package:spotibruh/widgets/icon.dart";
import "package:spotibruh/widgets/scaffold.dart";
import "package:spotibruh/widgets/switch.dart";
import "package:spotibruh/widgets/theme.dart";

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, top: 60),

          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,

                children: [
                  _buildTitle("Apparence"),

                  const ThemeWidget(),

                  _buildTitle("Notifications"),

                  _buildSwitch(
                    HugeIconsSolid.alert02,
                    HugeIconsSolid.alertCircle,

                    "Ne montrer que les erreurs",
                    Prefs.showOnlyErrors,
                  ),

                  _buildTitle("Stockage"),

                  const ButtonWidget(onPressed: ColorUtils.clearCache, label: "Vider le cache des couleurs"),

                  _buildTitle("Compte"),

                  ButtonWidget(
                    onPressed: () async {
                      await Prefs.clear();
                      setState(() {});
                    },

                    label: "Réinitialiser les préférences",
                  ),

                  const ButtonWidget(onPressed: Auth.logout, label: "Se déconnecter", isDangerous: true),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsetsGeometry.only(bottom: 6, left: 4),
      child: Text(
        title,
        textAlign: TextAlign.start,
        style: TextStyle(color: context.c.onPrimary, fontWeight: FontWeight.bold, fontSize: 24),
      ),
    );
  }

  Widget _buildSwitch(IconData onIcon, IconData offIcon, String label, Pref pref) {
    bool value = pref.value;

    return App.buildContainer(
      height: 48,

      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 12,

        children: [
          Expanded(
            child: Row(
              spacing: 8,

              children: [
                IconWidget(icon: value ? onIcon : offIcon),

                Expanded(
                  child: Text(
                    label,

                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),

          SwitchWidget(
            defaultValue: value,
            value: value,

            onPressed: () async {
              setState(() {
                value = !value;
              });

              await pref.set(value);
            },
          ),
        ],
      ),
    );
  }
}
