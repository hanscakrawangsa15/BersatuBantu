# Supabase Message Table Setup Guide

## Prerequisites

Sebelum menggunakan fitur chat, pastikan tabel `message` sudah terbuat di Supabase dengan struktur yang tepat.

## SQL Schema

Jalankan SQL berikut di Supabase SQL Editor untuk membuat table:

```sql
-- Create message table
CREATE TABLE IF NOT EXISTS public.message (
  id BIGSERIAL PRIMARY KEY,
  sender_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  receiver_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  receiver_type TEXT NOT NULL DEFAULT 'user' CHECK (receiver_type IN ('user', 'organization')),
  organization_id UUID,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  read_at TIMESTAMP WITH TIME ZONE,
  
  -- Constraints
  CONSTRAINT valid_receiver CHECK (
    (receiver_type = 'user' AND receiver_id IS NOT NULL AND organization_id IS NULL) OR
    (receiver_type = 'organization' AND organization_id IS NOT NULL AND receiver_id IS NULL)
  )
);

-- Create indexes for performance
CREATE INDEX idx_message_sender_id ON public.message(sender_id);
CREATE INDEX idx_message_receiver_id ON public.message(receiver_id);
CREATE INDEX idx_message_organization_id ON public.message(organization_id);
CREATE INDEX idx_message_receiver_type ON public.message(receiver_type);
CREATE INDEX idx_message_created_at ON public.message(created_at DESC);

-- Composite index for common queries
CREATE INDEX idx_message_conversation ON public.message(
  sender_id, receiver_id, receiver_type
) WHERE receiver_type = 'user';

CREATE INDEX idx_message_org_conversation ON public.message(
  sender_id, organization_id, receiver_type
) WHERE receiver_type = 'organization';

-- Enable Row Level Security
ALTER TABLE public.message ENABLE ROW LEVEL SECURITY;
```

## Row Level Security (RLS) Policies

RLS sangat penting untuk keamanan. Setup policies berikut:

```sql
-- Policy 1: Users can see messages where they are sender or receiver
CREATE POLICY "Users can view their own messages"
ON public.message
FOR SELECT
USING (
  auth.uid() = sender_id OR 
  (auth.uid() = receiver_id AND receiver_type = 'user')
);

-- Policy 2: Users can insert messages they send
CREATE POLICY "Users can send messages"
ON public.message
FOR INSERT
WITH CHECK (
  auth.uid() = sender_id
);

-- Policy 3: Users can update read_at timestamp for messages they received
CREATE POLICY "Users can mark messages as read"
ON public.message
FOR UPDATE
USING (
  auth.uid() = receiver_id AND receiver_type = 'user'
)
WITH CHECK (
  auth.uid() = receiver_id AND receiver_type = 'user'
);

-- Policy 4: Allow deletion of own messages (optional)
CREATE POLICY "Users can delete their own messages"
ON public.message
FOR DELETE
USING (
  auth.uid() = sender_id
);
```

### Note on Organization Messages

Untuk mendukung pesan antar organisasi, Anda mungkin perlu menambahkan role-based RLS policies:

```sql
-- Policy untuk organization members melihat pesan ke org mereka
CREATE POLICY "Organization members can view org messages"
ON public.message
FOR SELECT
USING (
  receiver_type = 'organization' AND
  EXISTS (
    SELECT 1 FROM organization_request
    WHERE organization_request.request_id = message.organization_id
    AND organization_request.user_id = auth.uid()
  )
);
```

## Realtime Subscriptions

Untuk real-time chat messaging, pastikan Realtime diaktifkan:

1. Buka Supabase Dashboard
2. Klik pada "Tables" → "message"
3. Di tab "Realtime", pastikan "Realtime" diaktifkan
4. Pilih events yang ingin dimonitor: `INSERT`, `UPDATE` (untuk read_at)

## Tables yang Dibutuhkan

Pastikan tables berikut sudah tersedia untuk lookup data:

### 1. auth.users
- Sudah default dari Supabase
- Berisi user authentication data

### 2. profiles
```sql
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  full_name TEXT,
  avatar_url TEXT,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 3. organization_request
```sql
CREATE TABLE IF NOT EXISTS public.organization_request (
  request_id UUID PRIMARY KEY,
  nama_organisasi TEXT NOT NULL,
  user_id UUID NOT NULL REFERENCES auth.users(id),
  -- ... other fields
);
```

## Testing the Setup

Gunakan script SQL berikut untuk testing:

```sql
-- Test 1: Insert sample message
INSERT INTO public.message (sender_id, receiver_id, receiver_type, content)
SELECT 
  auth.uid(),
  (SELECT id FROM auth.users LIMIT 1),
  'user',
  'Test message'
WHERE auth.uid() IS NOT NULL;

-- Test 2: Query messages
SELECT * FROM public.message 
WHERE sender_id = auth.uid() OR receiver_id = auth.uid()
ORDER BY created_at DESC
LIMIT 10;

-- Test 3: Check RLS is working (should see only own messages)
SELECT COUNT(*) as message_count FROM public.message;
```

## Troubleshooting

### Issue: "Permission denied" when inserting messages

**Solution:**
- Verify user is authenticated
- Check RLS policies allow INSERT
- Ensure sender_id matches auth.uid()

```sql
-- Check current user
SELECT auth.uid();

-- Check RLS policies on message table
SELECT * FROM pg_policies 
WHERE tablename = 'message';
```

### Issue: Messages not appearing in list

**Solution:**
- Verify RLS policy allows SELECT
- Check receiver_id is not null for user messages
- Verify organization_id is set for org messages

```sql
-- Check table structure
\d public.message

-- Check data exists
SELECT * FROM public.message LIMIT 5;
```

### Issue: Real-time updates not working

**Solution:**
- Verify Realtime is enabled for message table
- Check INSERT event is selected
- Verify user has read access via RLS

```sql
-- Check table has Realtime enabled via dashboard
-- Or via SQL (if supported by your Supabase version)
-- SELECT * FROM realtime.subscriptions;
```

### Issue: Performance is slow

**Solution:**
- Ensure all indexes are created
- Consider limiting initial load to recent messages
- Add pagination for older messages

```sql
-- Check indexes
SELECT * FROM pg_indexes 
WHERE tablename = 'message';

-- Analyze query performance
EXPLAIN ANALYZE
SELECT * FROM public.message 
WHERE sender_id = 'user-uuid' OR receiver_id = 'user-uuid'
ORDER BY created_at DESC
LIMIT 50;
```

## Migration from Existing Chat System

Jika sudah ada sistem chat lama, migrasikan dengan:

```sql
-- Backup data
CREATE TABLE message_backup AS SELECT * FROM old_message_table;

-- Transform and insert
INSERT INTO public.message (sender_id, receiver_id, receiver_type, content, created_at)
SELECT 
  sender_id,
  receiver_id,
  'user' as receiver_type,
  content,
  created_at
FROM message_backup
WHERE receiver_id IS NOT NULL;

-- Verify
SELECT COUNT(*) FROM public.message;
```

## Monitoring and Analytics

```sql
-- Message count per user
SELECT 
  sender_id,
  COUNT(*) as messages_sent
FROM public.message
GROUP BY sender_id
ORDER BY messages_sent DESC;

-- Daily message statistics
SELECT 
  DATE(created_at) as date,
  COUNT(*) as message_count,
  COUNT(DISTINCT sender_id) as unique_senders
FROM public.message
GROUP BY DATE(created_at)
ORDER BY date DESC;

-- Most active conversations
SELECT 
  CASE 
    WHEN sender_id < receiver_id THEN CONCAT(sender_id, '-', receiver_id)
    ELSE CONCAT(receiver_id, '-', sender_id)
  END as conversation,
  COUNT(*) as message_count
FROM public.message
WHERE receiver_type = 'user'
GROUP BY conversation
ORDER BY message_count DESC;
```

## Best Practices

1. **Always use Prepared Statements** - Prevent SQL injection
2. **Implement RLS** - Secure user data
3. **Add Indexes** - Improve query performance
4. **Monitor Storage** - Old messages take space
5. **Implement Archiving** - Move old messages to separate table
6. **Log Errors** - Debug issues in production
7. **Rate Limit** - Prevent message spam
8. **Validate Input** - Sanitize message content

## Production Checklist

- [ ] Message table created with correct schema
- [ ] All indexes created
- [ ] RLS policies configured
- [ ] Realtime enabled for INSERT
- [ ] Test user can send/receive messages
- [ ] Test RLS prevents unauthorized access
- [ ] Verify performance with sample data
- [ ] Backup strategy in place
- [ ] Monitoring alerts configured
- [ ] Documentation updated for team

## Additional Resources

- [Supabase Database Docs](https://supabase.com/docs/guides/database)
- [Supabase Realtime Docs](https://supabase.com/docs/guides/realtime)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [PostgreSQL Performance Tips](https://www.postgresql.org/docs/current/sql-performance.html)
