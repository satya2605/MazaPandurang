import 'package:flutter/material.dart';
import '../../app/role_selector/role_selector_screen.dart';
import '../../app/module_selector/module_selector_screen.dart';
import '../../modules/pilgrim/pilgrim_module.dart';
import '../../modules/dindi/dindi_module.dart';
import '../../modules/police/police_module.dart';
import '../../modules/ngo/ngo_module.dart';
import '../../modules/citizen/citizen_module.dart';

/// App route definitions and route generator.
abstract class AppRoutes {
  static const String roleSelector = '/';
  static const String devModuleSelector = '/dev-module-selector';

  static const String pilgrim = '/pilgrim';
  static const String dindi = '/dindi';
  static const String police = '/police';
  static const String ngo = '/ngo';
  static const String citizen = '/citizen';

  static Map<String, WidgetBuilder> get routes => {
        roleSelector: (context) => const RoleSelectorScreen(),
        devModuleSelector: (context) => const ModuleSelectorScreen(),
        pilgrim: (context) => PilgrimModule.screen(),
        dindi: (context) => DindiModule.screen(),
        police: (context) => PoliceModule.screen(),
        ngo: (context) => NgoModule.screen(),
        citizen: (context) => CitizenModule.screen(),
      };
}
