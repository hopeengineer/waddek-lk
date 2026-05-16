-- Enable realtime broadcast for chat tables.
--
-- Without this, the `.stream()` calls in ChatRepository do an initial
-- SELECT but receive no live updates — sent messages don't echo back
-- to the sender, and the conversations list doesn't reorder when
-- activity happens. Adding both tables to the supabase_realtime
-- publication so the existing Flutter streams start working.
ALTER PUBLICATION supabase_realtime ADD TABLE messages;
ALTER PUBLICATION supabase_realtime ADD TABLE conversations;
