# App Updates & Maintenance Plan
## Requirement R&U7: Planning App Updates and Maintenance

**Application:** WFH Tracker  
**Version:** 1.0.0  
**Planning Date:** January 28, 2026  
**Maintenance Strategy:** Agile with Continuous Improvement

---

## 1. Maintenance Philosophy

The WFH Tracker follows a **proactive maintenance approach** with regular updates to ensure:
- **Backward compatibility** with older app versions
- **Security patches** applied promptly
- **Bug fixes** released within 48 hours of discovery
- **Feature updates** deployed quarterly
- **Performance monitoring** continuous

---

## 2. Version Numbering Strategy

### Semantic Versioning (SemVer)
Format: `MAJOR.MINOR.PATCH` (e.g., 1.0.0)

- **MAJOR:** Breaking changes, major features (1.0.0 → 2.0.0)
- **MINOR:** New features, backward compatible (1.0.0 → 1.1.0)
- **PATCH:** Bug fixes, security patches (1.0.0 → 1.0.1)

### Current Roadmap:
- **v1.0.0** (Current): Initial release with core features
- **v1.1.0** (Q2 2026): Scheduled notifications
- **v1.2.0** (Q3 2026): Work session timer
- **v2.0.0** (Q4 2026): Cloud sync & multi-device support

---

## 3. Backward Compatibility Strategy

### 3.1 Data Migration
**Challenge:** Updating SharedPreferences structure without losing user data

**Solution:**
```dart
// v1.0.0: Simple goal storage
SharedPreferences.setString('work_goal', goal);

// v1.1.0: Enhanced goal with timestamp (backward compatible)
Future<void> migrateGoalData() async {
  final prefs = await SharedPreferences.getInstance();
  
  // Check if old format exists
  if (prefs.containsKey('work_goal') && !prefs.containsKey('work_goal_v2')) {
    String oldGoal = prefs.getString('work_goal') ?? '';
    
    // Migrate to new format with timestamp
    Map<String, dynamic> newGoal = {
      'text': oldGoal,
      'timestamp': DateTime.now().toIso8601String(),
      'version': 2
    };
    
    await prefs.setString('work_goal_v2', jsonEncode(newGoal));
    // Keep old data for rollback capability
  }
}
```

**Benefits:**
- Users won't lose saved goals after update
- Old app versions can still read basic goal text
- Rollback possible if issues occur

### 3.2 API Versioning
**For Firebase Analytics Events:**
```dart
// Maintain event compatibility
await analytics.logEvent(
  name: 'check_battery_v2',  // Versioned event name
  parameters: {
    'battery_level': result,
    'event_version': 2,  // Track event version
    'app_version': '1.1.0'
  }
);
```

### 3.3 Notification Channel Updates
**Android Notification Channels:**
- Create new channels instead of modifying existing ones
- Deprecated channels remain functional for 2 major versions
- Users can manually migrate to new channels

---

## 4. Planned Updates

### Phase 1: Q2 2026 (v1.1.0)
**Features:**
- ✨ **Scheduled Notifications:** Automatic break reminders every 2 hours
- ✨ **Dark Mode:** Theme switching capability
- 🔧 **Improved Permission Handling:** Better UX for permission requests

**Backward Compatibility:**
- All existing data persists
- Old notification channel remains active
- No breaking API changes

**Testing Required:**
- Upgrade testing from v1.0.0 to v1.1.0
- Rollback testing
- Data migration verification

---

### Phase 2: Q3 2026 (v1.2.0)
**Features:**
- ✨ **Work Session Timer:** Track focused work periods
- ✨ **Weekly Reports:** Analytics dashboard for productivity
- ✨ **Goal Templates:** Pre-defined goal options

**Backward Compatibility:**
- Timer data stored separately from goals
- Reports generated from existing analytics data
- Templates are additive (don't affect existing functionality)

**Database Schema:**
```dart
// New tables added (existing data unchanged)
- work_sessions (id, start_time, end_time, duration)
- weekly_reports (week, total_hours, goals_completed)
- goal_templates (id, template_text, category)
```

---

### Phase 3: Q4 2026 (v2.0.0 - MAJOR)
**Features:**
- ✨ **Cloud Sync:** Firebase Firestore integration
- ✨ **Multi-Device Support:** Sync across devices
- ✨ **User Accounts:** Authentication system
- ⚠️ **Breaking Change:** Requires user migration to cloud storage

**Migration Strategy:**
```dart
// Graceful migration path
Future<void> migrateToCloud() async {
  // Step 1: Prompt user (optional migration)
  bool userConsent = await showMigrationDialog();
  
  if (userConsent) {
    // Step 2: Upload local data to cloud
    await uploadLocalDataToFirestore();
    
    // Step 3: Keep local backup for 30 days
    await prefs.setInt('migration_date', DateTime.now().millisecondsSinceEpoch);
  }
  
  // Local storage remains functional for users who decline
}
```

**Backward Compatibility:**
- Local-only mode still available
- v1.x.x apps continue working (no forced upgrade)
- Data export option for users wanting to stay local

---

## 5. Security Updates

### Security Patch Process:
1. **Critical Vulnerabilities:** Patch within 24 hours
2. **High Priority:** Patch within 1 week
3. **Medium Priority:** Include in next minor release
4. **Low Priority:** Include in quarterly update

### Recent Security Considerations:
- ✅ **Android 13+ Notification Permissions:** Implemented in v1.0.0
- ✅ **Firebase Security Rules:** Configured for v2.0.0 launch
- 🔄 **Dependency Updates:** Quarterly security audit

### Dependency Monitoring:
```yaml
# Automated dependency scanning via GitHub Actions
name: Security Audit
on:
  schedule:
    - cron: '0 0 * * 0'  # Weekly on Sunday
jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Flutter pub outdated
        run: flutter pub outdated
```

---

## 6. Bug Fix Strategy

### Bug Severity Levels:
- **P0 (Critical):** App crashes, data loss → Hotfix within 24h
- **P1 (High):** Feature broken, major UX issue → Fix within 3 days
- **P2 (Medium):** Minor bugs, cosmetic issues → Fix in next minor release
- **P3 (Low):** Feature requests, enhancements → Planned updates

### Hotfix Process:
```bash
# Emergency hotfix workflow
git checkout main
git checkout -b hotfix/v1.0.1
# Apply fix
flutter test  # Verify fix
git commit -m "Hotfix: Critical battery crash on Android 12"
git tag v1.0.1
git push origin hotfix/v1.0.1 --tags
# Deploy to stores
```

---

## 7. Testing Strategy for Updates

### Pre-Release Testing Checklist:
- ✅ **Upgrade Testing:** Test upgrade from all previous versions
- ✅ **Fresh Install Testing:** Clean install on new device
- ✅ **Data Migration Testing:** Verify no data loss
- ✅ **Backward Compatibility Testing:** Old features still work
- ✅ **Rollback Testing:** Can revert to previous version
- ✅ **Performance Testing:** No performance regression

### Device Testing Matrix:
- Android 10, 11, 12, 13, 14
- Emulator + Physical devices
- Different screen sizes (phone, tablet)

---

## 8. App Store Release Process

### Release Checklist:
1. ✅ **Version Bump:** Update `pubspec.yaml` version
2. ✅ **Changelog:** Update `CHANGELOG.md` with changes
3. ✅ **Build:** Generate signed release APK/AAB
4. ✅ **Testing:** Full regression test suite
5. ✅ **Store Listing:** Update screenshots, description
6. ✅ **Staged Rollout:** 10% → 50% → 100% over 7 days
7. ✅ **Monitor:** Watch crash reports and analytics

### Rollback Plan:
- Staged rollout allows stopping at any percentage
- Previous APK remains available for emergency rollback
- Firebase Remote Config can disable new features remotely

---

## 9. User Communication Strategy

### Update Notifications:
```dart
// In-app update prompt (non-intrusive)
if (newVersionAvailable) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => AlertDialog(
      title: Text('Update Available'),
      content: Text('Version 1.1.0 includes:\n• Scheduled notifications\n• Dark mode\n• Bug fixes'),
      actions: [
        TextButton(child: Text('Later'), onPressed: () => Navigator.pop(context)),
        TextButton(child: Text('Update'), onPressed: () => launchAppStore()),
      ],
    ),
  );
}
```

### Changelog Format:
```markdown
## v1.1.0 - 2026-04-15
### Added
- Scheduled break reminders
- Dark mode theme option

### Fixed
- Battery level crash on Android 12
- Location permission flow on iOS 16

### Changed
- Improved notification design
```

---

## 10. Monitoring & Feedback

### Analytics Tracking:
- **Crash Rate:** Target <0.1%
- **ANR Rate:** Target <0.01%
- **Active Users:** Track daily/monthly
- **Feature Usage:** Track which features are used most
- **Update Adoption:** Monitor update rollout success

### User Feedback Channels:
- In-app feedback form
- GitHub Issues for bug reports
- Email support: support@wfhtracker.app
- Analytics event for feature requests

---

## 11. Deprecation Policy

### Feature Deprecation Process:
1. **Announce:** Notify users 3 months before removal
2. **Mark Deprecated:** Add warning in UI
3. **Provide Alternative:** Offer replacement feature
4. **Grace Period:** Maintain for 2 major versions
5. **Remove:** Clean removal after grace period

### Example Deprecation Notice:
```dart
// v1.0.0: Old notification system
// v1.1.0: Deprecated (still works)
// v1.2.0: Deprecated (show migration prompt)
// v2.0.0: Removed (replaced with new system)
```

---

## 12. Disaster Recovery Plan

### Backup Strategy:
- **User Data:** Automatic cloud backup (v2.0.0+)
- **Source Code:** GitHub with multiple remotes
- **Build Artifacts:** Store last 5 versions
- **Analytics Data:** Firebase automatic retention

### Critical Failure Response:
1. **Detect:** Automated crash monitoring alerts
2. **Assess:** Determine severity and scope
3. **Communicate:** In-app banner + social media update
4. **Fix:** Deploy hotfix or rollback
5. **Verify:** Confirm issue resolved
6. **Post-Mortem:** Document and prevent recurrence

---

## 13. Conclusion

The WFH Tracker maintenance plan ensures:
- ✅ **Backward Compatibility:** Users never lose data during updates
- ✅ **Security:** Rapid response to vulnerabilities
- ✅ **Reliability:** Staged rollouts minimize risk
- ✅ **User Experience:** Clear communication and smooth updates
- ✅ **Sustainability:** Long-term maintenance strategy

This plan will be reviewed quarterly and updated based on user feedback, platform changes, and emerging best practices.

---

**Prepared By:** VXSnipe  
**Review Date:** January 28, 2026  
**Next Review:** April 28, 2026  
**Status:** ✅ Active Maintenance Plan
