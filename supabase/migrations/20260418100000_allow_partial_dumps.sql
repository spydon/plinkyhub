-- Allow dumps to store only one flash region (internal or external).
-- Previously both paths were required, but users sometimes only want to
-- capture one region (e.g. to debug a specific flash chip).
alter table dumps alter column internal_flash_path drop not null;
alter table dumps alter column external_flash_path drop not null;
