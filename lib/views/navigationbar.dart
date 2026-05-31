import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_solutions/constants/static_stored_data.dart';
import 'package:smart_solutions/controllers/active_files_controller.dart';
import 'package:smart_solutions/controllers/common_filter_controller.dart';
import 'package:smart_solutions/controllers/dashboard_controller.dart';
import 'package:smart_solutions/controllers/data_entry_controller.dart';
import 'package:smart_solutions/controllers/follow_form_controller.dart';
import 'package:smart_solutions/controllers/login_request_controller.dart';
import 'package:smart_solutions/controllers/pin_code_controller.dart';
import 'package:smart_solutions/controllers/theme_controller.dart';
import 'package:smart_solutions/core/app_bindings.dart';
import 'package:smart_solutions/services/api_service.dart';
import 'package:smart_solutions/theme/app_theme.dart';
import 'package:smart_solutions/views/active_files.dart';
import 'package:smart_solutions/views/call_log.dart';
import 'package:smart_solutions/views/dialer_screen.dart';
import 'package:smart_solutions/views/listing_screen.dart';
import 'package:smart_solutions/views/login_request_screen.dart';
import 'package:smart_solutions/views/login_screen.dart';
import '../controllers/auth_controller.dart';
import '../controllers/chartCard_controller.dart';
import '../services/logout_helper.dart';
import '../services/tab_state_service.dart';
import 'dashboard_screen.dart';

class MainScreen extends StatefulWidget {
  final int pageIndex;

  const MainScreen({
    Key? key,
    this.pageIndex = 0,
  }) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final PersistentTabController _controller;
  late final List<PersistentTabConfig> tabs;
  late int _previousIndex;
  bool _isCheckingAuth = false;
  final ThemeController themeController = Get.find<ThemeController>();
  final CommonFilterController _commonFilterController =
      Get.find<CommonFilterController>();

  final RxInt _secureType = 0.obs;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.pageIndex;
    _controller = PersistentTabController(initialIndex: widget.pageIndex);
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    _secureType.value = prefs.getInt('secureType') ?? 0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _ensureLoggedIn() async {
    if (_isCheckingAuth) return false;

    _isCheckingAuth = true;
    try {
      final isLoggedIn = await ApiService().checkUserStillLoggedIn();
      if (!isLoggedIn) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        if (mounted) {
          Get.off(() => const LoginView(), binding: AppBinding());
        }
        return false;
      }
      return true;
    } finally {
      _isCheckingAuth = false;
    }
  }

  Future<bool> _ensureLoggedOnAnotherDevice() async {
    final response = await ApiService().checkUserLoggedInOnAnotherDevice();

    if (response == true) {
      await LogoutHelper.logout(Get.context!);
      return true; // user logged out
    }
    return false;
  }

  List<PersistentTabConfig> _buildTabs() {
    final isTelecaller = StaticStoredData.roleName == 'telecaller';

    if (isTelecaller) {
      return [
        PersistentTabConfig(
          screen: const DashboardScreen(),
          item: ItemConfig(
            icon: SvgPicture.asset(
              'assets/images/dashboard.svg',
              colorFilter: ColorFilter.mode(
                themeController.primaryColor.value,
                BlendMode.srcIn,
              ),
            ),
            inactiveIcon: SvgPicture.asset(
              'assets/images/dashboard.svg',
              colorFilter: ColorFilter.mode(
                Colors.grey.shade600,
                BlendMode.srcIn,
              ),
            ),
            title: "Dashboard",
            activeForegroundColor: themeController.primaryColor.value,
            inactiveForegroundColor: Colors.grey.shade600,
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        PersistentTabConfig(
          screen: const ActiveFiles(
            key: ValueKey('leads_screen'),
            title: 'Leads',
            status: -1,
            isShowBack: false,
            isDrawer: true,
          ),
          item: ItemConfig(
            icon: SvgPicture.asset(
              'assets/images/leads.svg',
              colorFilter: ColorFilter.mode(
                themeController.primaryColor.value,
                BlendMode.srcIn,
              ),
            ),
            inactiveIcon: SvgPicture.asset(
              'assets/images/leads.svg',
              colorFilter: ColorFilter.mode(
                Colors.grey.shade600,
                BlendMode.srcIn,
              ),
            ),
            title: "Leads",
            activeForegroundColor: themeController.primaryColor.value,
            inactiveForegroundColor: Colors.grey.shade600,
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        PersistentTabConfig(
          screen: const DialerScreen(key: ValueKey('dialer_screen')),
          item: ItemConfig(
            icon: CircleAvatar(
              backgroundColor: themeController.primaryColor.value,
              child: SvgPicture.asset(
                'assets/images/phone_call.svg',
                color: AppColors.appBarTextColor,
                fit: BoxFit.contain,
              ),
            ),
            // SvgPicture.asset(
            //   'assets/images/fab.svg',
            //   fit: BoxFit.contain,
            // ),
            iconSize: 50,
            title: "DIALER",
            textStyle:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            activeColorSecondary: Colors.transparent,
            inactiveBackgroundColor: Colors.transparent,
          ),
        ),
        PersistentTabConfig(
          screen: const CallLogPage(
            key: ValueKey('call_log_screen'),
            title: 'Call Log',
          ),
          // FollowBackListScreen(key: const ValueKey('call_log_screen')),
          item: ItemConfig(
            icon: SvgPicture.asset(
              'assets/images/clock_fast_forward.svg',
              colorFilter: ColorFilter.mode(
                themeController.primaryColor.value,
                BlendMode.srcIn,
              ),
            ),
            inactiveIcon: SvgPicture.asset(
              'assets/images/clock_fast_forward.svg',
              colorFilter: ColorFilter.mode(
                Colors.grey.shade600,
                BlendMode.srcIn,
              ),
            ),
            title: "Call Log",
            activeForegroundColor: themeController.primaryColor.value,
            inactiveForegroundColor: Colors.grey.shade600,
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        PersistentTabConfig(
          screen: LoginRequestScreen(
            key: const ValueKey('hrm_screen'),
            title: 'Login Request',
            isShowBack: false,
            isDrawer: true,
            //key: const ValueKey('hrm_screen')
          ),
          item: ItemConfig(
            icon: SvgPicture.asset(
              'assets/images/user_plus_grey.svg',
              colorFilter: ColorFilter.mode(
                themeController.primaryColor.value,
                BlendMode.srcIn,
              ),
            ),
            inactiveIcon: SvgPicture.asset(
              'assets/images/user_plus_grey.svg',
              colorFilter: ColorFilter.mode(
                Colors.grey.shade600,
                BlendMode.srcIn,
              ),
            ),
            // icon: const Icon(Icons.co_present_outlined, size: 24),
            // inactiveIcon: const Icon(Icons.co_present_outlined, size: 24),
            title: "Request",
            activeForegroundColor: themeController.primaryColor.value,
            inactiveForegroundColor: Colors.grey.shade600,
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ];
    } else {
      return [
        PersistentTabConfig(
          screen: const DashboardScreen(),
          item: ItemConfig(
            icon: SvgPicture.asset(
              'assets/images/dashboard.svg',
              colorFilter: ColorFilter.mode(
                themeController.primaryColor.value,
                BlendMode.srcIn,
              ),
            ),
            inactiveIcon: SvgPicture.asset(
              'assets/images/dashboard.svg',
              colorFilter: ColorFilter.mode(
                Colors.grey.shade600,
                BlendMode.srcIn,
              ),
            ),
            title: "Dashboard",
            activeForegroundColor: themeController.primaryColor.value,
            inactiveForegroundColor: Colors.grey.shade600,
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        PersistentTabConfig(
          screen: const ActiveFiles(
            key: ValueKey('leads_screen'),
            title: 'Leads',
            status: -1,
            isShowBack: false,
            isDrawer: true,
          ),
          item: ItemConfig(
            icon: SvgPicture.asset(
              'assets/images/leads.svg',
              colorFilter: ColorFilter.mode(
                themeController.primaryColor.value,
                BlendMode.srcIn,
              ),
            ),
            inactiveIcon: SvgPicture.asset(
              'assets/images/leads.svg',
              colorFilter: ColorFilter.mode(
                Colors.grey.shade600,
                BlendMode.srcIn,
              ),
            ),
            title: "Leads",
            activeForegroundColor: themeController.primaryColor.value,
            inactiveForegroundColor: Colors.grey.shade600,
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (_secureType.value == 0)
          PersistentTabConfig(
            screen: ListingScreen(
              key: const ValueKey('listing_screen '),
              title: 'Listing',
              isShowBack: false,
              isDrawer: true,
              //key: const ValueKey('hrm_screen')
            ),
            item: ItemConfig(
              icon: SvgPicture.asset(
                'assets/images/drawer.svg',
                colorFilter: ColorFilter.mode(
                  themeController.primaryColor.value,
                  BlendMode.srcIn,
                ),
              ),
              inactiveIcon: SvgPicture.asset(
                'assets/images/drawer.svg',
                colorFilter: ColorFilter.mode(
                  Colors.grey.shade600,
                  BlendMode.srcIn,
                ),
              ),
              // icon: const Icon(Icons.co_present_outlined, size: 24),
              // inactiveIcon: const Icon(Icons.co_present_outlined, size: 24),
              title: "Listing ",
              activeForegroundColor: themeController.primaryColor.value,
              inactiveForegroundColor: Colors.grey.shade600,
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        PersistentTabConfig(
          screen: LoginRequestScreen(
            key: const ValueKey('hrm_screen'),
            title: 'Login Request',

            isShowBack: false,
            isDrawer: true,
            //key: const ValueKey('hrm_screen')
          ),
          item: ItemConfig(
            icon: SvgPicture.asset(
              'assets/images/user_plus_grey.svg',
              colorFilter: ColorFilter.mode(
                themeController.primaryColor.value,
                BlendMode.srcIn,
              ),
            ),
            inactiveIcon: SvgPicture.asset(
              'assets/images/user_plus_grey.svg',
              colorFilter: ColorFilter.mode(
                Colors.grey.shade600,
                BlendMode.srcIn,
              ),
            ),
            // icon: const Icon(Icons.co_present_outlined, size: 24),
            // inactiveIcon: const Icon(Icons.co_present_outlined, size: 24),
            title: "Request ",
            activeForegroundColor: themeController.primaryColor.value,
            inactiveForegroundColor: Colors.grey.shade600,
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Obx(
          () => PersistentTabView(
            tabs: _buildTabs(),
            gestureNavigationEnabled: true,
            controller: _controller,
            navBarBuilder: (navBarConfig) =>
                StaticStoredData.roleName != 'telecaller'
                    ? Style4BottomNavBar(
                        navBarConfig: navBarConfig,
                        height: 70,
                        navBarDecoration: const NavBarDecoration(
                          padding: EdgeInsets.zero,
                          color: Colors.white12,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                        ),
                      )
                    : Style15BottomNavBar(
                        navBarConfig: navBarConfig,
                        height: 70,
                        navBarDecoration: const NavBarDecoration(
                          padding: EdgeInsets.zero,
                          color: Colors.white12,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                        ),
                      ),
            backgroundColor: Colors.white,
            onTabChanged: _onTabChanged,
            keepNavigatorHistory: false,
            stateManagement:
                true, // ⚠️ Changed to true for better state handling
            navBarOverlap: const NavBarOverlap.custom(),
            handleAndroidBackButtonPress: true,
            avoidBottomPadding: false,
            //     confineInSafeArea: true, // ⚠️ ADD THIS for safety
            screenTransitionAnimation: const ScreenTransitionAnimation(
              //     animateTabTransition: true,
              curve: Curves.ease,
              duration: Duration(milliseconds: 200),
            ),
          ),
        ),
      ),
    );
  }

  void _onTabChanged(int newIndex) async {
    final tab = getTabFromIndex(newIndex);

    final tabService = Get.find<MainTabService>();

    if (tabService.currentTab.value == tab) return;

    // 🔥 Clear Filters
    Get.find<ActiveFilesController>().filterController.clearFilters();
    Get.find<ChartCardsController>().selectedIndex.value = 0;
    Get.find<CommonFilterController>().clearDateFilter();
    Get.find<DataController>().fetchDataEntryList();
    Get.find<AuthController>().handlePlanExpiry();

    handleWorkers(tab);

    final ok = await _ensureLoggedIn();
    if (!ok) return;

    await refreshTab(tab);
    tabService.updateTab(newIndex, tab);

    tabService.currentTab.value = tab;
    final isLoggedOut = await _ensureLoggedOnAnotherDevice();
    if (isLoggedOut) return;
  }

  // void _onTabChanged(int newIndex) async {
  //   if (newIndex == _previousIndex) return;

  //   if (newIndex != _previousIndex) {
  //     Get.find<ActiveFilesController>().filterController.clearFilters();
  //     Get.find<ChartCardsController>().selectedIndex.value = 0;
  //   }

  //   if (newIndex == 1) {
  //     Get.find<ActiveFilesController>().startWorker();
  //     Get.find<FollowBackFormController>().stopWorker();
  //   }

  //   if (newIndex == 3) {
  //     Get.find<FollowBackFormController>().startWorker();
  //     Get.find<ActiveFilesController>().stopWorker();
  //   }

  //   final ok = await _ensureLoggedIn();
  //   if (!ok) {
  //     Future.microtask(() {
  //       if (mounted && _controller.index != _previousIndex) {
  //         _controller.jumpToTab(_previousIndex);
  //       }
  //     });
  //     return;
  //   }

  //   switch (newIndex) {
  //     case 0:
  //       Get.find<DashboardController>().refreshDashboard();
  //       break;

  //     case 1:
  //       Get.find<DataController>().refreshData();
  //       break;

  //     case 3:
  //       Get.find<FollowBackFormController>().fetchFollowBackList();
  //       break;
  //   }

  //   _commonFilterController.clearDateFilter();

  //   _previousIndex = newIndex;
  // }

  // void _onTabChanged(int newIndex) async {
  //   if (newIndex == _previousIndex) return;

  //   final ok = await _ensureLoggedIn();
  //   if (!ok) {
  //     // Jump back to the previous tab if not authenticated
  //     Future.microtask(() {
  //       if (mounted && _controller.index != _previousIndex) {
  //         _controller.jumpToTab(_previousIndex);
  //       }
  //     });
  //     return;
  //   }
  //   if (newIndex == 0) {
  //     Get.find<DashboardController>().onInit();
  //   }
  //   if (newIndex == 1) {
  //     Get.find<ActiveFilesController>().loadData();
  //   }
  //   if (newIndex == 3) {
  //     Get.find<FollowBackFormController>().fetchFollowBackList();
  //   }
  //   _previousIndex = newIndex;
  // }

  MainTab getTabFromIndex(int index) {
    final isTelecaller = StaticStoredData.roleName == 'telecaller';

    if (isTelecaller) {
      switch (index) {
        case 0:
          return MainTab.dashboard;
        case 1:
          return MainTab.leads;
        case 2:
          return MainTab.dialer;
        case 3:
          return MainTab.callLog;
        case 4:
          return MainTab.request;
        default:
          return MainTab.dashboard;
      }
    } else {
      switch (index) {
        case 0:
          return MainTab.dashboard;
        case 1:
          return MainTab.leads;

        case 2:
          return MainTab.listing;

        case 3:
          return MainTab.request;
        default:
          return MainTab.dashboard;
      }
    }
  }

  Future<void> refreshTab(MainTab tab) async {
    final tabService = Get.find<MainTabService>();

    if (!tabService.shouldRefresh(tab)) return;

    switch (tab) {
      case MainTab.dashboard:
        await Get.find<DashboardController>().refreshDashboard();
        break;

      case MainTab.leads:
        await Get.find<ActiveFilesController>().refreshData();
        break;

      case MainTab.callLog:
        await Get.find<FollowBackFormController>().fetchFollowBackList();
        break;

      case MainTab.listing:
        await Get.find<PincodeController>().fetchPincodes();
        break;

      case MainTab.request:
        await Get.find<LoginRequestController>().getLoginRequestList();
        break;

      case MainTab.dialer:
        break;
    }

    tabService.markRefreshed(tab);
  }

  void handleWorkers(MainTab tab) {
    final active = Get.find<ActiveFilesController>();
    final follow = Get.find<FollowBackFormController>();

    active.stopWorker();
    follow.stopWorker();

    if (tab == MainTab.leads) {
      active.startWorker();
    }

    if (tab == MainTab.callLog) {
      follow.startWorker();
    }
  }
}
