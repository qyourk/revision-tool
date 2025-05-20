import 'package:process_run/shell_run.dart';
import 'package:revitool/shared/win_registry_service.dart';
import 'package:revitool/utils.dart';
import 'package:win32_registry/win32_registry.dart';

enum ServiceGrouping { forced, recommended, disabled }

const _userSvcSplitDisabled = {"CDPUserSvc_", "OneSyncSvc_", "WpnUserService_"};

final _recommendedSplitDisabled = {
  "DisplayEnhancementService",
  "PcaSvc",
  "WdiSystemHost",
  "AudioEndpointBuilder",
  "DeviceAssociationService",
  "NcbService",
  "StorSvc",
  "SysMain",
  "TextInputManagementService",
  "TrkWks",
  "hidserv",

  "Appinfo",
  "BITS",
  "LanmanServer",
  "SENS",
  "Schedule",
  "ShellHWDetection",
  "Themes",
  "TokenBroker",
  "UserManager",
  "UsoSvc",
  "Winmgmt",
  "WpnService",
  "gpsvc",
  "iphlpsvc",
  "wuauserv",

  "WinHttpAutoProxySvc",
  "EventLog",
  "TimeBrokerSvc",
  "lmhosts",
  "Dhcp",

  "FontCache",
  "nsi",
  "SstpSvc",
  "DispBrokerDesktopSvc",
  "CDPSvc",
  "EventSystem",
  "LicenseManager",

  "SystemEventsBroker",
  "Power",
  "LSM",
  "DcomLaunch",
  "BrokerInfrastructure",

  "CoreMessagingRegistrar",
  "DPS",

  "AppXSvc",
  "ClipSVC",
};

const _defaultSplitDisabled = {
  "BFE",
  "BrokerInfrastructure",
  "DcomLaunch",
  "DisplayEnhancementService\\Parameters",
  "mpssvc",
  "OneSyncSvc",
  "PimIndexMaintenanceSvc",
  "PlugPlay",
  "Power",
  "RasMan",
  "RemoteAccess",
  "RpcEptMapper",
  "RpcSs",
  "SensorService\\Parameters",
  "SystemEventsBroker",
  "UnistoreSvc",
  "UserDataSvc",
};

class PerformanceService {
  static final _shell = Shell();

  static const _instance = PerformanceService._private();
  factory PerformanceService() {
    return _instance;
  }
  const PerformanceService._private();

  bool get statusSuperfetch {
    return !(WinRegistryService.readInt(
              RegistryHive.localMachine,
              r'SYSTEM\ControlSet001\Services\rdyboost',
              'Start',
            ) ==
            4 &&
        WinRegistryService.readInt(
              RegistryHive.localMachine,
              r'SYSTEM\ControlSet001\Services\SysMain',
              'Start',
            ) ==
            4);
  }

  Future<void> enableSuperfetch() async {
    await _shell.run(
      '"$directoryExe\\MinSudo.exe" --NoLogo --TrustedInstaller cmd /min /c "$directoryExe\\EnableSF.bat"',
    );
  }

  Future<void> disableSuperfetch() async {
    await _shell.run(
      '"$directoryExe\\MinSudo.exe" --NoLogo --TrustedInstaller cmd /min /c "$directoryExe\\DisableSF.bat"',
    );
  }

  bool get statusMemoryCompression {
    return isProcessRunning('Memory Compression');
  }

  Future<void> enableMemoryCompression() async {
    await _shell.run(
      'PowerShell -NonInteractive -NoLogo -NoProfile -Command "Enable-MMAgent -mc"',
    );
  }

  Future<void> disableMemoryCompression() async {
    await _shell.run(
      'PowerShell -NonInteractive -NoLogo -NoProfile -Command "Disable-MMAgent -mc"',
    );
  }

  bool get statusIntelTSX {
    return WinRegistryService.readInt(
          RegistryHive.localMachine,
          r'SYSTEM\ControlSet001\Control\Session Manager\Kernel',
          'DisableTsx',
        ) ==
        0;
  }

  void enableIntelTSX() {
    WinRegistryService.writeRegistryValue(
      Registry.localMachine,
      r'SYSTEM\CurrentControlSet\Control\Session Manager\kernel',
      'DisableTsx',
      0,
    );
  }

  void disableIntelTSX() {
    WinRegistryService.writeRegistryValue(
      Registry.localMachine,
      r'SYSTEM\CurrentControlSet\Control\Session Manager\kernel',
      'DisableTsx',
      1,
    );
  }

  bool get statusFullscreenOptimization {
    return WinRegistryService.readInt(
          RegistryHive.currentUser,
          r'System\GameConfigStore',
          "GameDVR_FSEBehaviorMode",
        ) ==
        0;
  }

  void enableFullscreenOptimization() {
    WinRegistryService.writeRegistryValue(
      Registry.currentUser,
      r'System\GameConfigStore',
      'GameDVR_FSEBehaviorMode',
      0,
    );
    WinRegistryService.deleteValue(
      Registry.currentUser,
      r'System\GameConfigStore',
      'GameDVR_FSEBehavior',
    );
    WinRegistryService.deleteValue(
      Registry.currentUser,
      r'System\GameConfigStore',
      'GameDVR_HonorUserFSEBehaviorMode',
    );
    WinRegistryService.deleteValue(
      Registry.currentUser,
      r'System\GameConfigStore',
      'GameDVR_DXGIHonorFSEWindowsCompatible',
    );
    WinRegistryService.deleteValue(
      Registry.currentUser,
      r'System\GameConfigStore',
      'GameDVR_EFSEFeatureFlags',
    );

    WinRegistryService.writeRegistryValue(
      Registry.allUsers,
      r'.DEFAULT\System\GameConfigStore',
      'GameDVR_FSEBehaviorMode',
      0,
    );
    WinRegistryService.deleteValue(
      Registry.allUsers,
      r'.DEFAULT\System\GameConfigStore',
      'GameDVR_FSEBehavior',
    );
    WinRegistryService.deleteValue(
      Registry.allUsers,
      r'.DEFAULT\System\GameConfigStore',
      'GameDVR_HonorUserFSEBehaviorMode',
    );
    WinRegistryService.deleteValue(
      Registry.allUsers,
      r'.DEFAULT\System\GameConfigStore',
      'GameDVR_DXGIHonorFSEWindowsCompatible',
    );
    WinRegistryService.deleteValue(
      Registry.allUsers,
      r'.DEFAULT\System\GameConfigStore',
      'GameDVR_EFSEFeatureFlags',
    );
  }

  void disableFullscreenOptimization() {
    WinRegistryService.writeRegistryValue(
      Registry.currentUser,
      r'System\GameConfigStore',
      'GameDVR_FSEBehaviorMode',
      2,
    );
    WinRegistryService.writeRegistryValue(
      Registry.currentUser,
      r'System\GameConfigStore',
      'GameDVR_HonorUserFSEBehaviorMode',
      1,
    );
    WinRegistryService.writeRegistryValue(
      Registry.currentUser,
      r'System\GameConfigStore',
      'GameDVR_DXGIHonorFSEWindowsCompatible',
      1,
    );
    WinRegistryService.writeRegistryValue(
      Registry.currentUser,
      r'System\GameConfigStore',
      'GameDVR_EFSEFeatureFlags',
      0,
    );
    WinRegistryService.writeRegistryValue(
      Registry.currentUser,
      r'System\GameConfigStore',
      'GameDVR_FSEBehavior',
      2,
    );

    // WinRegistryService.writeRegistryValue(Registry.allUsers,
    //     r'System\GameConfigStore', 'GameDVR_FSEBehaviorMode', 2);
    // WinRegistryService.writeRegistryValue(Registry.allUsers,
    //     r'System\GameConfigStore', 'GameDVR_HonorUserFSEBehaviorMode', 1);
    // WinRegistryService.writeRegistryValue(Registry.allUsers,
    //     r'System\GameConfigStore', 'GameDVR_DXGIHonorFSEWindowsCompatible', 1);
    // WinRegistryService.writeRegistryValue(Registry.allUsers,
    //     r'System\GameConfigStore', 'GameDVR_EFSEFeatureFlags', 0);
    // WinRegistryService.writeRegistryValue(
    //     Registry.allUsers, r'System\GameConfigStore', 'GameDVR_FSEBehavior', 2);
  }

  bool get statusWindowedOptimization {
    final value = WinRegistryService.readString(
      RegistryHive.currentUser,
      r'Software\Microsoft\DirectX\UserGpuPreferences',
      "DirectXUserGlobalSettings",
    );
    return value == null || !value.contains('SwapEffectUpgradeEnable=0');
  }

  void enableWindowedOptimization() {
    final currentValue = WinRegistryService.readString(
      RegistryHive.currentUser,
      r'Software\Microsoft\DirectX\UserGpuPreferences',
      "DirectXUserGlobalSettings",
    );

    final String newValue;
    if (currentValue == null || currentValue.isEmpty) {
      newValue = 'SwapEffectUpgradeEnable=1;';
    } else {
      newValue =
          'SwapEffectUpgradeEnable=1;${currentValue.replaceAll('SwapEffectUpgradeEnable=0;', '').replaceAll('SwapEffectUpgradeEnable=0', '')}';
    }

    WinRegistryService.writeRegistryValue(
      Registry.currentUser,
      r'Software\Microsoft\DirectX\UserGpuPreferences',
      'DirectXUserGlobalSettings',
      newValue,
    );
  }

  void disableWindowedOptimization() {
    final currentValue = WinRegistryService.readString(
      RegistryHive.currentUser,
      r'Software\Microsoft\DirectX\UserGpuPreferences',
      "DirectXUserGlobalSettings",
    );

    final String newValue;
    if (currentValue == null || currentValue.isEmpty) {
      newValue = 'SwapEffectUpgradeEnable=0;';
    } else {
      newValue =
          'SwapEffectUpgradeEnable=0;${currentValue.replaceAll('SwapEffectUpgradeEnable=1;', '').replaceAll('SwapEffectUpgradeEnable=1', '')}';
    }

    WinRegistryService.writeRegistryValue(
      Registry.currentUser,
      r'Software\Microsoft\DirectX\UserGpuPreferences',
      'DirectXUserGlobalSettings',
      newValue,
    );
  }

  bool get statusBackgroundApps {
    return WinRegistryService.readInt(
              RegistryHive.localMachine,
              r'Software\Policies\Microsoft\Windows\AppPrivacy',
              'LetAppsRunInBackground',
            ) !=
            2 &&
        WinRegistryService.readInt(
              RegistryHive.currentUser,
              r'Software\Microsoft\Windows\CurrentVersion\Search',
              'BackgroundAppGlobalToggle',
            ) !=
            0 &&
        WinRegistryService.readInt(
              RegistryHive.currentUser,
              r'Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications',
              'GlobalUserDisabled',
            ) !=
            1;
  }

  void enableBackgroundApps() {
    WinRegistryService.deleteValue(
      Registry.currentUser,
      r'Software\Microsoft\Windows\CurrentVersion\Search',
      'BackgroundAppGlobalToggle',
    );
    WinRegistryService.deleteValue(
      Registry.localMachine,
      r'Software\Microsoft\Windows\CurrentVersion\Search',
      'BackgroundAppGlobalToggle',
    );

    WinRegistryService.deleteValue(
      Registry.currentUser,
      r'Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications',
      'GlobalUserDisabled',
    );
    WinRegistryService.deleteValue(
      Registry.localMachine,
      r'Software\Policies\Microsoft\Windows\AppPrivacy',
      'LetAppsRunInBackground',
    );
  }

  void disableBackgroundApps() {
    WinRegistryService.writeRegistryValue(
      Registry.currentUser,
      r'Software\Microsoft\Windows\CurrentVersion\Search',
      'BackgroundAppGlobalToggle',
      0,
    );

    WinRegistryService.writeRegistryValue(
      Registry.currentUser,
      r'Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications',
      'GlobalUserDisabled',
      1,
    );
    WinRegistryService.writeRegistryValue(
      Registry.localMachine,
      r'Software\Policies\Microsoft\Windows\AppPrivacy',
      'LetAppsRunInBackground',
      2,
    );
  }

  bool get statusCStates {
    return WinRegistryService.readInt(
          RegistryHive.localMachine,
          r'SYSTEM\ControlSet001\Control\Processor',
          'Capabilities',
        ) ==
        516198;
  }

  void enableCStates() {
    WinRegistryService.deleteValue(
      Registry.localMachine,
      r'SYSTEM\ControlSet001\Control\Processor',
      'Capabilities',
    );
  }

  void disableCStates() {
    WinRegistryService.writeRegistryValue(
      Registry.localMachine,
      r'SYSTEM\ControlSet001\Control\Processor',
      'Capabilities',
      516198,
    );
  }

  bool get statusLastTimeAccessNTFS {
    return WinRegistryService.readInt(
          RegistryHive.localMachine,
          r'SYSTEM\ControlSet001\Control\FileSystem',
          "RefsDisableLastAccessUpdate",
        ) ==
        1;
  }

  Future<void> enableLastTimeAccessNTFS() async {
    await _shell.run('fsutil behavior set disableLastAccess 0');
  }

  Future<void> disableLastTimeAccessNTFS() async {
    await _shell.run('fsutil behavior set disableLastAccess 1');
  }

  bool get status8dot3NamingNTFS {
    return WinRegistryService.readInt(
          RegistryHive.localMachine,
          r'SYSTEM\ControlSet001\Control\FileSystem',
          "NtfsDisable8dot3NameCreation",
        ) ==
        1;
  }

  Future<void> enable8dot3NamingNTFS() async {
    await _shell.run('fsutil behavior set disable8dot3 2');
  }

  Future<void> disable8dot3NamingNTFS() async {
    await _shell.run('fsutil behavior set disable8dot3 1');
  }

  bool get statusMemoryUsageNTFS {
    return WinRegistryService.readInt(
          RegistryHive.localMachine,
          r'SYSTEM\ControlSet001\Control\FileSystem',
          "NtfsMemoryUsage",
        ) ==
        2;
  }

  ServiceGrouping get statusServicesGrouping {
    final value = WinRegistryService.readInt(
      RegistryHive.localMachine,
      r'SYSTEM\ControlSet001\Control',
      'SvcHostSplitThresholdInKB',
    );

    if (value == 0xFFFFFFFF) {
      return ServiceGrouping.forced;
    } else if (WinRegistryService.readInt(
          RegistryHive.localMachine,
          r'SYSTEM\ControlSet001\Services\AudioEndpointBuilder',
          'SvcHostSplitDisable',
        ) ==
        1) {
      for (final service in _userSvcSplitDisabled) {
        final finalService = WinRegistryService.getUserServices(service);
        for (final userService in finalService) {
          _recommendedSplitDisabled.add(userService);
        }
      }
      return ServiceGrouping.recommended;
    }
    return ServiceGrouping.disabled;
  }

  void forcedServicesGrouping() {
    WinRegistryService.writeRegistryValue(
      Registry.localMachine,
      r'SYSTEM\CurrentControlSet\Control',
      'SvcHostSplitThresholdInKB',
      0xFFFFFFFF,
    );
  }

  void recommendedServicesGrouping() {
    WinRegistryService.writeRegistryValue(
      Registry.localMachine,
      r'SYSTEM\CurrentControlSet\Control',
      'SvcHostSplitThresholdInKB',
      0x380000, // default value
    );
    for (final service in {
      ..._defaultSplitDisabled,
      ..._recommendedSplitDisabled,
    }) {
      WinRegistryService.writeRegistryValue(
        Registry.localMachine,
        r'SYSTEM\ControlSet001\Services\' + service,
        'SvcHostSplitDisable',
        1,
      );
    }
  }

  void disableServicesGrouping() {
    final servicesToDelete = _recommendedSplitDisabled.difference(
      _defaultSplitDisabled,
    );
    for (final service in servicesToDelete) {
      WinRegistryService.deleteValue(
        Registry.localMachine,
        'SYSTEM\\ControlSet001\\Services\\$service',
        'SvcHostSplitDisable',
      );
    }
    WinRegistryService.writeRegistryValue(
      Registry.localMachine,
      r'SYSTEM\CurrentControlSet\Control',
      'SvcHostSplitThresholdInKB',
      0x380000, // default value
    );
  }

  Future<void> enableMemoryUsageNTFS() async {
    await _shell.run('fsutil behavior set memoryusage 2');
  }

  Future<void> disableMemoryUsageNTFS() async {
    await _shell.run('fsutil behavior set memoryusage 1');
  }
}
