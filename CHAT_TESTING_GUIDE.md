# 🧪 Chat Feature - Testing Guide

## Pre-Testing Checklist

### Environment Setup
- [ ] Flutter SDK installed and updated
- [ ] Supabase account with access to database
- [ ] Message table created in Supabase (see SUPABASE_MESSAGE_TABLE_SETUP.md)
- [ ] RLS policies configured on message table
- [ ] Realtime enabled for INSERT events
- [ ] Test data in profiles table (for user lookups)
- [ ] At least 2 test user accounts created

### Code Verification
- [ ] ChatListScreen created: `lib/fitur/chat/screens/chat_list_screen.dart`
- [ ] ChatDetailScreen created: `lib/fitur/chat/screens/chat_detail_screen.dart`
- [ ] Bottom navbar updated with "Pesan" button
- [ ] Dashboard_screen updated with ChatListScreen import and navigation
- [ ] No compilation errors: `flutter analyze`
- [ ] Dependencies resolved: `flutter pub get`

## Unit Testing

### Test 1: Component Rendering

```dart
// Test: ChatListScreen renders without errors
testWidgets('ChatListScreen renders', (WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(
    home: ChatListScreen(),
  ));
  
  expect(find.byType(Scaffold), findsOneWidget);
  expect(find.byType(AppBar), findsOneWidget);
  expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  expect(find.byType(TextField), findsOneWidget); // Search bar
});

// Test: ChatDetailScreen renders
testWidgets('ChatDetailScreen renders', (WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(
    home: ChatDetailScreen(
      receiverId: 'test-user-id',
      receiverType: 'user',
      receiverName: 'Test User',
    ),
  ));
  
  expect(find.byType(Scaffold), findsOneWidget);
  expect(find.byType(TextField), findsOneWidget); // Message input
  expect(find.byIcon(Icons.send), findsOneWidget);
});
```

### Test 2: Navigation

```dart
// Test: Tapping "Pesan" button navigates to ChatListScreen
testWidgets('Pesan button navigates to chat', (WidgetTester tester) async {
  // Setup and build DashboardScreen
  // ...
  
  // Find "Pesan" button (should be index 2 in navbar)
  await tester.tap(find.byIcon(Icons.chat_bubble_outline_rounded));
  await tester.pumpAndSettle();
  
  expect(find.byType(ChatListScreen), findsOneWidget);
});
```

## Integration Testing

### Test 1: Basic Chat Flow

**Steps:**
1. Launch app
2. Login with test account 1
3. Navigate to Dashboard
4. Tap "Pesan" button
5. Verify ChatListScreen appears

**Expected Results:**
- ✅ Navigation bar shows "Pesan" button
- ✅ ChatListScreen renders with AppBar title "Pesan"
- ✅ Search bar is visible
- ✅ Empty state shows "Ada Pertanyaan? Hubungi Bobi!"

**Pass/Fail:** ___

### Test 2: Loading Conversations

**Setup:**
- Login with account that has existing messages
- Or create test messages manually in Supabase

**Steps:**
1. Navigate to ChatListScreen
2. Wait for messages to load
3. Verify conversations appear

**Expected Results:**
- ✅ Conversations load in < 2 seconds
- ✅ Each conversation shows participant avatar (user/org icon)
- ✅ Last message preview visible
- ✅ Time display correct (5m, 1h, 3d format)
- ✅ Ordered by most recent first

**Pass/Fail:** ___

### Test 3: Search Functionality

**Steps:**
1. Have multiple conversations loaded
2. Type partial name in search bar
3. Verify filtering works
4. Clear search
5. Verify all conversations reappear

**Expected Results:**
- ✅ Search filters instantly (no delay)
- ✅ Case-insensitive matching
- ✅ Partial name matches
- ✅ Clear search shows all again

**Test Cases:**
- [ ] Search with 1 character
- [ ] Search with full name
- [ ] Search with special characters
- [ ] Search with non-existent name
- [ ] Empty search shows all

**Pass/Fail:** ___

### Test 4: Open Conversation

**Steps:**
1. Tap on a conversation in the list
2. Wait for ChatDetailScreen to load
3. Verify messages appear

**Expected Results:**
- ✅ ChatDetailScreen opens within 1 second
- ✅ AppBar shows correct recipient name
- ✅ Back button visible and functional
- ✅ Message history loads

**Pass/Fail:** ___

### Test 5: Send Message (User-to-User)

**Setup:**
- Two test accounts logged in on different devices/emulators
- Open ChatDetailScreen on both devices

**Steps:**
1. On Device A: Type message "Test message 1"
2. On Device A: Tap send button
3. Verify message appears on Device A
4. Verify message appears on Device B in real-time
5. On Device B: Type reply "Reply from B"
6. On Device B: Tap send
7. Verify message appears on Device B
8. Verify message appears on Device A

**Expected Results:**
- ✅ Message sends without error
- ✅ Message appears immediately on sender's screen (blue bubble, right-aligned)
- ✅ Receiver sees message in real-time (gray bubble, left-aligned)
- ✅ Timestamps are correct
- ✅ Messages appear in correct order
- ✅ Auto-scroll to new message works

**Test Cases:**
- [ ] Simple ASCII message
- [ ] Message with emoji 😊
- [ ] Message with special chars @#$%^&*
- [ ] Message with numbers 12345
- [ ] Long message (> 100 chars)
- [ ] Message with line breaks
- [ ] Very long message (> 500 chars)

**Pass/Fail:** ___

### Test 6: Empty Message Prevention

**Steps:**
1. Open message input field
2. Leave blank and try to send
3. Tap send button with just spaces
4. Verify message isn't sent

**Expected Results:**
- ✅ Empty message not sent
- ✅ Whitespace-only message not sent
- ✅ No error shown (silent prevention)
- ✅ Message stays in input field

**Pass/Fail:** ___

### Test 7: Back Navigation

**Steps:**
1. Open ChatDetailScreen
2. Send a message
3. Tap back button
4. Verify ChatListScreen appears
5. Verify new message is shown in preview

**Expected Results:**
- ✅ Back button works
- ✅ Returns to ChatListScreen
- ✅ Message preview updated
- ✅ Conversation moved to top (most recent)

**Pass/Fail:** ___

### Test 8: Organization Messages

**Setup:**
- Account has message with organization
- Organization exists in organization_request table

**Steps:**
1. Find organization conversation in list
2. Verify organization icon (business icon)
3. Tap to open
4. Send message
5. Verify message saved correctly

**Expected Results:**
- ✅ Organization shown with business icon
- ✅ Organization name loads correctly
- ✅ Can send message to organization
- ✅ Message saved with correct organization_id

**Pass/Fail:** ___

### Test 9: Persistence

**Steps:**
1. Send a message
2. Close the app completely
3. Reopen the app
4. Navigate to the same conversation
5. Verify message is still there

**Expected Results:**
- ✅ Message persists after app restart
- ✅ Message loads from database
- ✅ Correct sender/receiver shown
- ✅ Timestamp preserved

**Pass/Fail:** ___

### Test 10: Error Handling

**Steps:**
1. Open ChatDetailScreen with invalid receiver ID
2. Try to send message with network disabled
3. Re-enable network and try sending again
4. Check error handling

**Expected Results:**
- ✅ Error shown if sending fails
- ✅ Message doesn't send twice
- ✅ Can retry after reconnecting
- ✅ App doesn't crash

**Error Cases to Test:**
- [ ] No internet connection
- [ ] Supabase temporarily down
- [ ] Invalid receiver ID
- [ ] Invalid organization ID
- [ ] RLS policy denies access
- [ ] Database full (unlikely but test)

**Pass/Fail:** ___

## Performance Testing

### Test 1: Load Time

**Measure:**
- ChatListScreen load time
- ChatDetailScreen load time
- Message send time
- Real-time update time

**Setup:**
1. Use logcat/console to timestamp events
2. Look for print statements: `[ChatList]`, `[ChatDetail]`

**Sample Code to Add:**
```dart
// In _loadChatList()
final startTime = DateTime.now();
// ... loading code ...
final endTime = DateTime.now();
print('ChatList load time: ${endTime.difference(startTime).inMilliseconds}ms');
```

**Expected Results:**
- ✅ ChatListScreen: < 2000ms (with 100 conversations)
- ✅ ChatDetailScreen: < 1000ms (with 50 messages)
- ✅ Send message: < 1000ms
- ✅ Real-time update: < 500ms

**Results:**
- ChatListScreen: ___ ms
- ChatDetailScreen: ___ ms
- Send message: ___ ms
- Real-time update: ___ ms

**Pass/Fail:** ___

### Test 2: Memory Usage

**Before Testing:**
- Note baseline memory usage

**During Testing:**
- Open and close ChatListScreen 10 times
- Open and close ChatDetailScreen 10 times
- Send 20 messages

**After Testing:**
- Check if memory is released
- Look for memory leaks

**Results:**
- Memory increase: ___ MB
- Memory properly released: Yes / No

**Pass/Fail:** ___

### Test 3: Scrolling Performance

**Steps:**
1. Open ChatDetailScreen with 100+ messages
2. Scroll up and down smoothly
3. Check for stuttering or lag

**Expected Results:**
- ✅ Smooth scrolling (no jank)
- ✅ FPS >= 60
- ✅ No lag when auto-scrolling

**Pass/Fail:** ___

## Database Testing

### Test 1: Message Table Structure

**Check:**
```sql
-- Verify table structure
\d message

-- Verify indexes
SELECT * FROM pg_indexes WHERE tablename = 'message';

-- Verify RLS policies
SELECT * FROM pg_policies WHERE tablename = 'message';
```

**Expected Results:**
- ✅ Table exists with all required columns
- ✅ Indexes are created
- ✅ RLS policies are active

**Pass/Fail:** ___

### Test 2: Data Integrity

**Test:**
```sql
-- Check for null values
SELECT COUNT(*) FROM message WHERE sender_id IS NULL;
SELECT COUNT(*) FROM message WHERE receiver_type IS NULL;
SELECT COUNT(*) FROM message WHERE content IS NULL;

-- Check constraint violations
SELECT * FROM message WHERE NOT (
  (receiver_type = 'user' AND receiver_id IS NOT NULL) OR
  (receiver_type = 'organization' AND organization_id IS NOT NULL)
);
```

**Expected Results:**
- ✅ No null sender_id
- ✅ No null receiver_type
- ✅ No null content
- ✅ No constraint violations

**Pass/Fail:** ___

### Test 3: RLS Policies

**Test:**
```dart
// Login as user A
// Query should return only their messages

// Login as user B
// Should not see user A's private messages

// Verify organization members can see org messages
```

**Expected Results:**
- ✅ User A sees only their messages
- ✅ User B doesn't see User A's messages
- ✅ Organization members see org messages

**Pass/Fail:** ___

## Edge Cases

### Test 1: Very Long Message

**Input:** Message with 1000+ characters

**Expected:** Message sends and displays correctly

**Pass/Fail:** ___

### Test 2: Special Characters

**Inputs:**
- Message with emojis: "Hello 👋 🎉 😊"
- Message with accents: "Hällö wörld"
- Message with symbols: "Price: $99.99 @ 50% off!"
- Message with quotes: 'He said "Hello"'

**Expected:** All messages send and display correctly

**Pass/Fail:** ___

### Test 3: Rapid Messages

**Test:** Send 10 messages rapidly without waiting

**Expected:**
- ✅ All messages are sent
- ✅ All messages appear in correct order
- ✅ No duplicates
- ✅ Correct timestamps

**Pass/Fail:** ___

### Test 4: Offline/Poor Network

**Test:**
1. Enable airplane mode while typing
2. Try to send
3. Disable airplane mode
4. Retry sending

**Expected:**
- ✅ Shows error when offline
- ✅ Message doesn't send
- ✅ Can retry after reconnecting
- ✅ No duplicate messages

**Pass/Fail:** ___

### Test 5: Concurrent Operations

**Test:**
- User A and User B send messages simultaneously
- Verify both messages appear correctly

**Expected:**
- ✅ Both messages sent successfully
- ✅ Correct order maintained
- ✅ No data corruption

**Pass/Fail:** ___

## Browser/Platform Testing

### Mobile Platforms

#### Android
- [ ] Test on Android 8 (minimum)
- [ ] Test on Android 12 (latest)
- [ ] Test on various screen sizes (5", 6", 7")
- [ ] Test with portrait and landscape

#### iOS
- [ ] Test on iOS 14 (minimum)
- [ ] Test on iOS 17 (latest)
- [ ] Test on iPhone SE, iPhone Pro Max

### Tablets
- [ ] Test on iPad
- [ ] Test on Android tablet

## Regression Testing

### After Any Code Change

- [ ] Run `flutter analyze` - no errors
- [ ] Run all unit tests - all pass
- [ ] Test chat list loads
- [ ] Test send message works
- [ ] Test real-time updates work

## Test Results Summary

| Test Category | Total Tests | Passed | Failed | Status |
|---|---|---|---|---|
| Component Rendering | 2 | __ | __ | ⬜ |
| Navigation | 1 | __ | __ | ⬜ |
| Chat Flow | 10 | __ | __ | ⬜ |
| Performance | 3 | __ | __ | ⬜ |
| Database | 3 | __ | __ | ⬜ |
| Edge Cases | 5 | __ | __ | ⬜ |
| **TOTAL** | **24** | __ | __ | ⬜ |

## Known Issues (If Found)

### Issue #1
- **Description**: [Issue here]
- **Steps to Reproduce**: [Steps]
- **Severity**: Critical / High / Medium / Low
- **Status**: Open / In Progress / Fixed
- **Notes**: [Additional notes]

### Issue #2
- **Description**: [Issue here]
- **Steps to Reproduce**: [Steps]
- **Severity**: Critical / High / Medium / Low
- **Status**: Open / In Progress / Fixed
- **Notes**: [Additional notes]

## Sign-Off

**Tested By**: _________________ **Date**: _________

**Approved By**: _________________ **Date**: _________

**Notes**: 
```
[Add any additional notes or observations here]




```

---

**Test Plan Version**: 1.0
**Last Updated**: [Date]
**Next Review Date**: [Date]
