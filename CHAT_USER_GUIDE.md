# 💬 Fitur Chat - Panduan Penggunaan

## Quick Start

### Untuk User Aplikasi

1. **Buka aplikasi BersatuBantu**
   - Login dengan akun Anda

2. **Akses Chat**
   - Di halaman Dashboard, lihat bottom navigation bar
   - Klik tombol "Pesan" (icon chat bubble)

3. **Lihat Percakapan**
   - ChatListScreen akan menampilkan semua percakapan aktif Anda
   - Percakapan diurutkan berdasarkan pesan terbaru

4. **Cari Percakapan**
   - Gunakan search bar untuk mencari orang atau organisasi tertentu
   - Ketik nama dan hasil akan di-filter secara real-time

5. **Buka Percakapan**
   - Tap pada percakapan untuk membuka ChatDetailScreen
   - Anda akan melihat semua pesan dengan orang/organisasi tersebut

6. **Kirim Pesan**
   - Ketik pesan di input field
   - Tap tombol send (icon pesawat kertas)
   - Pesan akan langsung muncul di aplikasi Anda
   - Penerima akan melihat pesan secara real-time

7. **Kembali**
   - Tap tombol back (arrow) untuk kembali ke chat list
   - Chat list akan refresh otomatis untuk menampilkan pesan terbaru

## Fitur-Fitur

### ChatListScreen Features

| Fitur | Deskripsi |
|-------|-----------|
| **Conversation List** | Menampilkan daftar semua percakapan aktif |
| **Last Message Preview** | Menunjukkan isi pesan terakhir dari setiap percakapan |
| **Time Display** | Menampilkan waktu pesan terakhir (5m, 1h, 3d, etc.) |
| **Search/Filter** | Cari percakapan berdasarkan nama pengguna/organisasi |
| **Avatar Icons** | Icon user untuk person-to-person, icon business untuk organisasi |
| **Sort by Recent** | Percakapan otomatis diurutkan berdasarkan pesan terbaru |

### ChatDetailScreen Features

| Fitur | Deskripsi |
|-------|-----------|
| **Message History** | Menampilkan semua pesan dengan orang/organisasi tersebut |
| **Message Bubbles** | Pesan yang Anda kirim (biru), pesan terima (abu) |
| **Timestamps** | Waktu setiap pesan ditampilkan |
| **Auto-scroll** | Otomatis scroll ke pesan terbaru |
| **Real-time Updates** | Pesan baru muncul secara real-time |
| **Send Message** | Input field untuk mengetik pesan baru |
| **File Attachment** | Placeholder untuk upload file (coming soon) |

## Tipe Percakapan

### 1. User-to-User Chat
- Chat antara dua pengguna aplikasi
- Receiver ID tidak null, receiver_type = 'user'
- Hanya kedua pengguna yang bisa melihat percakapan

### 2. User-to-Organization Chat
- Chat antara pengguna dan organisasi
- Organization ID tidak null, receiver_id = null
- Receiver_type = 'organization'
- Organisasi bisa melihat dan membalas

## UI Guide

### Layout ChatListScreen

```
┌──────────────────────────────────────┐
│ ← Pesan                            ✓ │ ← AppBar
├──────────────────────────────────────┤
│ 🔍 Cari pesan...                   | │ ← Search Bar
├──────────────────────────────────────┤
│                                      │
│ 👤 John Doe                   5m    │ ← Conversation Item
│    Halo, apa kabar?                 │
│                                      │
│ 🏢 Organisasi ABC              1h  │ ← Organization Chat
│    Terima kasih atas donasinya     │
│                                      │
│ 👤 Jane Smith                  3d  │
│    OK, sampai jumpa minggu depan   │
│                                      │
├──────────────────────────────────────┤
│                                      │
│    Ada Pertanyaan?                  │ ← Empty State
│    Hubungi Bobi!                    │
│                                      │
└──────────────────────────────────────┘
```

### Layout ChatDetailScreen

```
┌──────────────────────────────────────┐
│ ← John Doe                        ⋯  │ ← AppBar with Options
├──────────────────────────────────────┤
│                                      │
│              Halo! 10:30            │ ← Received Message
│              Apa kabar? 10:31       │
│                                      │
│                    Halo juga! 10:32 │ ← Sent Message
│                    Baik-baik 10:33  │
│                                      │
│              Bagaimana denganmu? 10:34 │
│                                      │
│                         Sama saja! 10:35 │
│                                      │
├──────────────────────────────────────┤
│ ✎ Tulis pesan...        📎    📤   │ ← Input Area
└──────────────────────────────────────┘
```

## Navigation Flow

### Complete Navigation Path

```
Login Screen (or existing Dashboard)
        ↓
    Dashboard Screen (Beranda tab)
        ↓
    [User taps "Pesan" in navbar]
        ↓
    ChatListScreen
        ├─ [User can search here]
        ├─ [User can see all conversations]
        └─ [User taps on a conversation]
            ↓
        ChatDetailScreen
            ├─ [User can see message history]
            ├─ [User types message]
            ├─ [User taps send]
            └─ [User taps back]
                ↓
            ChatListScreen (with updated message)
                ↓
                [User can repeat with different conversation]
```

## Database Integration

### What Happens When You Send a Message

1. **You type message** → Text stored in input field
2. **You tap send** → Message validated
3. **Insert to DB** → Message saved to `message` table:
   ```
   {
     sender_id: your_user_id,
     receiver_id: other_user_id (or null for orgs),
     receiver_type: 'user' or 'organization',
     organization_id: org_id (or null for users),
     content: your_message_text,
     created_at: current_time
   }
   ```
4. **UI Updates** → Message appears on your screen
5. **Real-time Sync** → Receiver's app gets notified via Realtime subscription
6. **Receiver Sees** → Message appears on their screen automatically

### What Happens When Someone Sends You a Message

1. **Sender sends message** → Inserted to database
2. **Your Realtime Listener** → Detects new INSERT event
3. **Automatic Refresh** → App loads new messages
4. **UI Updates** → Message appears in your chat screen
5. **You see it** → Message visible with timestamp

## Color Scheme

- **Sent Messages**: `#8FA3CC` (Primary Blue) with white text
- **Received Messages**: `Colors.grey[200]` (Light Gray) with black text
- **AppBar**: `#768BBD` (Dark Blue)
- **Text**: CircularStd font family
- **Icons**: Material Design icons

## Input Validation

### Message Requirements
- ✅ Not empty
- ✅ Max length: No limit (but UI shows max ~500 chars visible)
- ✅ Can contain emoji
- ✅ Can contain special characters
- ✅ Can contain line breaks

### Before Sending
```dart
if (messageController.text.trim().isEmpty) {
  // Don't send
  return;
}
```

## Troubleshooting

### I don't see the "Pesan" button
- [ ] Check if you're viewing the Dashboard (not other screens)
- [ ] Scroll navigation bar if it's not visible
- [ ] Try restarting the app

### My messages aren't showing up
- [ ] Verify you're connected to internet
- [ ] Check receiver is correct
- [ ] Try sending simple message first (no emoji)
- [ ] Restart the app

### I don't see new messages in real-time
- [ ] Refresh the screen (pull-down)
- [ ] Check internet connection
- [ ] Verify other person has the app open
- [ ] Try sending message back to trigger refresh

### Can't find a conversation
- [ ] Use search to find by name
- [ ] Scroll up in the chat list
- [ ] Check if you've had conversations before
- [ ] Try restarting app

### Messages are loading slowly
- [ ] Check internet connection speed
- [ ] Try clearing app cache
- [ ] Close other apps using internet
- [ ] Restart the app

## Tips & Tricks

### 💡 Pro Tips

1. **Search Power**: Search works on both user names and organization names
2. **Auto-scroll**: Messages auto-scroll to bottom when new message arrives
3. **Quick Send**: Press Enter/Send on keyboard to send message
4. **Time Format**: 
   - "5m" = 5 minutes ago
   - "1h" = 1 hour ago
   - "3d" = 3 days ago
   - "15/11" = specific date

5. **Last Message Preview**: Shows first 60 characters of last message

### 🎨 Customization Options (for developers)

To customize appearance:

1. **Change Colors**:
   ```dart
   // In ChatListScreen/ChatDetailScreen
   Color(0xFF8FA3CC)  // Change sent message color
   Colors.grey[200]   // Change received message color
   Color(0xFF768BBD)  // Change AppBar color
   ```

2. **Change Fonts**:
   ```dart
   fontFamily: 'CircularStd'  // Change to different font
   ```

3. **Change Icons**:
   ```dart
   Icons.chat_bubble_outline_rounded  // "Pesan" icon
   Icons.person  // User avatar icon
   Icons.business  // Organization avatar icon
   ```

## Keyboard Shortcuts (Web/Desktop)

If using web version:
- `Ctrl+Enter` or `Cmd+Enter`: Send message
- `Tab`: Move focus between fields
- `Escape`: Close attachments menu

## Accessibility

- All buttons have proper labels
- Text colors have sufficient contrast
- Touch targets are 48x48 minimum
- Screen reader compatible (for supported devices)

## Performance Notes

### Optimizations Implemented
- ✅ Chat list uses `AutomaticKeepAliveClientMixin` for state persistence
- ✅ Messages loaded with pagination (initial 50, more on scroll)
- ✅ Real-time updates use efficient subscriptions
- ✅ Search is instantaneous (client-side filtering)

### Expected Performance
- **Chat List Load**: < 2 seconds
- **Open Chat Detail**: < 1 second
- **Send Message**: < 1 second
- **Real-time Update**: < 500ms

## Privacy & Security

### Your Data
- ✅ Messages are encrypted in transit (HTTPS)
- ✅ Messages stored securely in Supabase
- ✅ Only you and recipient can see messages
- ✅ RLS policies prevent unauthorized access

### What We Can't See
- ✅ We won't read your messages
- ✅ Messages are not monitored
- ✅ Data is only visible to you and recipient

## Limitations

### Current Version
- ❌ Can't edit messages after sending
- ❌ Can't delete messages
- ❌ Can't share files/images (placeholder only)
- ❌ No group chats
- ❌ No voice messages
- ❌ No video calls

### Planned for Future
- 📅 Message editing
- 📅 Message deletion
- 📅 File/image sharing
- 📅 Typing indicators
- 📅 Read receipts
- 📅 User online status
- 📅 Group chats

## Getting Help

### Report Issues
- Describe what you were doing
- Screenshot if possible
- Mention device type and OS version
- Include error messages if any

### Contact Support
- [Support Email]
- [Support Form]
- [Discord/Chat Community]

## FAQ

**Q: Can I use chat without internet?**
A: No, chat requires active internet connection to send/receive messages.

**Q: Are old messages deleted?**
A: No, all messages are preserved forever (unless manually deleted by admin).

**Q: Can I block someone?**
A: Block feature not yet available. Please contact support if you receive unwanted messages.

**Q: What if I accidentally send a message?**
A: You can't delete messages yet, but contact support for urgent cases.

**Q: Can I search old conversations?**
A: Yes, search bar filters all conversations by name.

**Q: How many messages can I send per day?**
A: No limit currently, but may be added in future for spam prevention.

**Q: Is chat available on web?**
A: Currently only available on mobile app.

---

**Last Updated**: [Current Date]
**Version**: 1.0
**Status**: ✅ Live & Ready to Use
