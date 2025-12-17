# Chat Feature Implementation Documentation

## Overview

Fitur chat telah diimplementasikan untuk memungkinkan pengguna berkomunikasi satu sama lain atau dengan organisasi. Fitur ini menyimpan semua pesan di database Supabase table `message`.

## Architecture

### Components

1. **ChatListScreen** (`lib/fitur/chat/screens/chat_list_screen.dart`)
   - Menampilkan daftar semua percakapan aktif pengguna
   - Mengelompokkan pesan berdasarkan pasangan pengirim-penerima
   - Mendukung pencarian percakapan
   - Menampilkan preview pesan terakhir dan waktu
   - Real-time sync dengan database

2. **ChatDetailScreen** (`lib/fitur/chat/screens/chat_detail_screen.dart`)
   - Menampilkan thread pesan dengan user/organisasi tertentu
   - Input field untuk mengirim pesan baru
   - Real-time listener untuk pesan baru
   - Auto-scroll ke pesan terbaru
   - Diferensiasi visual antara pesan sent dan received

3. **Bottom Navigation Bar Update** (`lib/fitur/widgets/bottom_navbar.dart`)
   - Ditambahkan button "Pesan" (Message) di navbar
   - Index 2 (setelah Donasi)
   - Icon: `Icons.chat_bubble_outline_rounded`

4. **Dashboard Integration** (`lib/fitur/dashboard/dashboard_screen.dart`)
   - Navigasi ke ChatListScreen saat button "Pesan" ditekan
   - Updated import untuk ChatListScreen
   - Updated _onNavTap handler untuk case 2 (Pesan)

## Database Schema

### Message Table

Struktur table `message` di Supabase:

```sql
CREATE TABLE message (
  id BIGINT PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id UUID NOT NULL REFERENCES auth.users(id),
  receiver_id UUID, -- NULL jika receiver_type = 'organization'
  receiver_type TEXT NOT NULL CHECK (receiver_type IN ('user', 'organization')),
  organization_id UUID, -- NULL jika receiver_type = 'user'
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  read_at TIMESTAMP,
  
  -- Indexes untuk performa query
  INDEX idx_sender (sender_id),
  INDEX idx_receiver (receiver_id),
  INDEX idx_receiver_type (receiver_type),
  INDEX idx_organization (organization_id),
  INDEX idx_created_at (created_at DESC)
);
```

## Features

### 1. Chat List View
- **Load Conversations**: Query all messages where user is sender OR receiver
- **Grouping**: Group messages by unique sender-receiver pairs
- **Load Names**: Fetch participant names dari `profiles` table untuk users atau `organization_request` table untuk orgs
- **Search**: Filter conversations by participant name
- **Sort**: Sort by most recent message time
- **Empty State**: Show message "Ada Pertanyaan? Hubungi Bobi!"

### 2. Chat Detail View
- **Load Messages**: Query messages between specific users/orgs
- **Real-time Updates**: Subscribe to new INSERT events on message table
- **Display**: Show messages with timestamps, differentiate sent vs received
- **Send Message**: Insert new message dengan proper sender/receiver/type fields
- **Auto-scroll**: Automatically scroll to latest message
- **Input Field**: Text input dengan send button dan attachment placeholder

### 3. Navigation Flow

```
Dashboard Screen (with updated navbar)
    ↓
    (User clicks "Pesan" button - index 2)
    ↓
Chat List Screen
    ↓
    (User selects conversation)
    ↓
Chat Detail Screen
    ↓
    (User sends message → saved to database)
    ↓
    (Realtime listener updates UI)
```

## File Changes

### Created Files
- `lib/fitur/chat/screens/chat_list_screen.dart` (344 lines)
- `lib/fitur/chat/screens/chat_detail_screen.dart` (421 lines)

### Modified Files

1. **lib/fitur/widgets/bottom_navbar.dart**
   - Added "Pesan" button to navigation
   - Shifted indexes: Aksi (2→3), Profil (3→4)

2. **lib/fitur/dashboard/dashboard_screen.dart**
   - Added import: `package:bersatubantu/fitur/chat/screens/chat_list_screen.dart`
   - Updated _onNavTap method:
     - Added case 2 for Pesan navigation
     - Updated case 3 for Aksi screen
     - Updated case 4 for Profil screen

## Implementation Details

### ChatListScreen Key Methods

```dart
_loadChatList() async
  → Query message table with sender_id OR receiver_id = current user
  → Group by conversation pair
  → Load participant names from database
  → Sort by created_at DESC

_filteredChats
  → Filter conversations by search query
  → Returns filtered list or all if query empty
```

### ChatDetailScreen Key Methods

```dart
_loadMessages() async
  → Query messages between specific users/orgs
  → Handle both user-to-user and user-to-org queries
  → Order by created_at ASC (oldest first)

_setupRealtimeListener()
  → Subscribe to INSERT events on message table
  → Calls _loadMessages() when new message received

_sendMessage() async
  → Validate input
  → Insert to message table with proper fields
  → Clear input field
  → Reload messages
  → Auto-scroll to bottom

_scrollToBottom()
  → Delay 100ms for message to be added to UI
  → Animate to bottom of list
```

## Usage

### For Users

1. From Dashboard, tap "Pesan" in bottom navbar
2. View list of all active conversations
3. Search for specific conversation using search bar
4. Tap on conversation to open chat
5. Type message and tap send button
6. Messages appear in real-time

### For Developers

To integrate with different message types:

```dart
// User-to-user chat
ChatDetailScreen(
  receiverId: userId,
  receiverType: 'user',
  organizationId: null,
  receiverName: userName,
)

// User-to-organization chat
ChatDetailScreen(
  receiverId: organizationId,
  receiverType: 'organization',
  organizationId: organizationId,
  receiverName: organizationName,
)
```

## Future Enhancements

- [ ] Message read status indicators
- [ ] Typing indicators
- [ ] Message typing notifications
- [ ] File/attachment uploads
- [ ] Message editing and deletion
- [ ] Conversation archiving
- [ ] User online/offline status
- [ ] Message notifications
- [ ] Message reactions/emojis
- [ ] Group chats

## Testing Checklist

- [ ] Can view empty chat list (no messages yet)
- [ ] Can see message from another user in list
- [ ] Can search for conversations by name
- [ ] Can tap conversation and see messages
- [ ] Can send new message
- [ ] Message appears immediately in sender's view
- [ ] Message appears in real-time in receiver's view (if they have app open)
- [ ] Messages persist after app restart
- [ ] Admin users can also access chat
- [ ] Organization messages are stored correctly
- [ ] Timestamps format correctly
- [ ] Auto-scroll works when message received

## Supabase Setup Requirements

### Table Permissions

Ensure table `message` has proper RLS policies:

```sql
-- Users can select messages where they are sender or receiver
CREATE POLICY "Users can view their messages" ON message
  FOR SELECT USING (
    auth.uid() = sender_id OR 
    (auth.uid() = receiver_id AND receiver_type = 'user')
  );

-- Users can insert their own messages
CREATE POLICY "Users can insert messages" ON message
  FOR INSERT WITH CHECK (
    auth.uid() = sender_id
  );

-- Users can update read_at for messages they received
CREATE POLICY "Users can mark messages as read" ON message
  FOR UPDATE USING (
    auth.uid() = receiver_id AND receiver_type = 'user'
  );
```

### Realtime Enablement

Ensure the `message` table has Realtime enabled in Supabase dashboard:
- Go to Tables → message → Realtime
- Enable INSERT events

## Troubleshooting

### Messages not appearing in list
- Check user is authenticated
- Verify message table has data
- Check RLS policies allow SELECT

### Chat not loading
- Verify receiver_id is not null for user-to-user chats
- Verify organization_id is set for organization chats
- Check receiver_type is correct

### Real-time updates not working
- Verify Realtime is enabled on message table
- Check subscription is established
- Verify no RLS policy blocking access

### Performance Issues
- Add indexes on frequently queried columns
- Limit initial message load to last 50
- Implement pagination for older messages

## Notes

- All timestamps are in ISO 8601 format
- Avatar icons differentiate between user (person icon) and organization (business icon)
- Color scheme follows app theme: primary color #768BBD for sent messages
- Message bubbles have different styling for sent (blue) vs received (gray)
