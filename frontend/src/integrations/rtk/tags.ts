// =============================================================
// FILE: src/integrations/rtk/tags.ts
// RTK Query cache/tag listesi (Ensotek modülleri)
// =============================================================

export const tags = [
  'Auth',
  'User',
  'AdminUsers',
  'Profiles',
  'Profile',
  'UserRoles',
  'DbSnapshot',
  'DashboardAnalytics',
  'DbAdmin',
  'DbModule',
  'DbManifest',
  'Products',
  'AdminProducts',
  'LocationsDistricts',
  'LocationsCities',
  'Orders',
  'AdminOrders',
  'DriverOrders',
  'Assignments',
  'AdminAssignments',
  'IncentivePlans',
  'IncentiveRules',
  'IncentiveLedger',
  'MyIncentives',
  'ReportsKpi',
  'ReportsUsersPerformance',
  'ReportsLocations',
  'Notifications',
] as const;

export type Tag = (typeof tags)[number];
