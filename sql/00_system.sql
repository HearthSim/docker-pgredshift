-- Additional pg_attribute columns
ALTER TABLE pg_attribute ADD COLUMN IF NOT EXISTS attisdistkey boolean;
ALTER TABLE pg_attribute ADD COLUMN IF NOT EXISTS attencrypttype smallint;
ALTER TABLE pg_attribute ADD COLUMN IF NOT EXISTS attencodingtype smallint;
ALTER TABLE pg_attribute ADD COLUMN IF NOT EXISTS attispreloaded boolean;
ALTER TABLE pg_attribute ADD COLUMN IF NOT EXISTS attsortkeyword integer;
