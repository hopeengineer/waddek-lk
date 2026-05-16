-- Allow either party to create a conversation where they're listed
-- as customer or worker. The original schema (00004_create_rls_policies)
-- only added a SELECT policy ("Conversations: parties can view"),
-- which meant INSERTs were blocked by default — surfaced as
-- "new row violates row-level security policy for table 'conversations'"
-- (42501) the moment the customer tapped "Message" on a worker's
-- profile and findOrCreateConversationWith tried to insert.
CREATE POLICY "Conversations: party can insert"
  ON conversations FOR INSERT
  WITH CHECK (auth.uid() = customer_id OR auth.uid() = worker_id);
