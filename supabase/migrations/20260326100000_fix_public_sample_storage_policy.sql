-- Fix the public sample files read policy.
-- The old policy compared samples.file_path to samples.name (both from the
-- samples table) instead of matching storage.objects.name to samples.file_path.
DROP POLICY "Anyone can read public sample files" ON storage.objects;

CREATE POLICY "Anyone can read public sample files" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'samples'
    AND EXISTS (
      SELECT 1 FROM samples
      WHERE samples.file_path = storage.objects.name
        AND samples.is_public = true
    )
  );
