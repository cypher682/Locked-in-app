<?php

namespace App\Services\Storage;

class StorageService
{
    private string $supabaseUrl;
    private string $supabaseKey;
    private string $bucketName = 'checkins';

    public function __construct()
    {
        $this->supabaseUrl = $_ENV['SUPABASE_URL'];
        $this->supabaseKey = $_ENV['SUPABASE_SERVICE_KEY'];
    }

    /**
     * Upload photo from base64 data
     * Returns the public URL of the uploaded photo
     */
    public function uploadPhoto(string $base64Data, string $userId): ?string
    {
        try {
            // Validate and decode base64
            if (!preg_match('/^data:image\/(\w+);base64,/', $base64Data, $matches)) {
                throw new \Exception('Invalid image format');
            }

            $imageType = $matches[1];
            $base64Data = substr($base64Data, strpos($base64Data, ',') + 1);
            $imageData = base64_decode($base64Data);

            if ($imageData === false) {
                throw new \Exception('Base64 decode failed');
            }

            // Validate image type
            $allowedTypes = ['jpeg', 'jpg', 'png', 'webp'];
            if (!in_array(strtolower($imageType), $allowedTypes)) {
                throw new \Exception('Invalid image type. Allowed: jpeg, jpg, png, webp');
            }

            // Validate file size (max 5MB)
            $maxSize = 5 * 1024 * 1024; // 5MB
            if (strlen($imageData) > $maxSize) {
                throw new \Exception('Image size exceeds 5MB limit');
            }

            // Generate unique filename
            $filename = $userId . '/' . uniqid() . '.' . $imageType;

            // Upload to Supabase Storage
            $url = $this->supabaseUrl . '/storage/v1/object/' . $this->bucketName . '/' . $filename;

            $ch = curl_init($url);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, $imageData);
            curl_setopt($ch, CURLOPT_HTTPHEADER, [
                'Authorization: Bearer ' . $this->supabaseKey,
                'Content-Type: image/' . $imageType,
            ]);

            $response = curl_exec($ch);
            $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            curl_close($ch);

            if ($httpCode !== 200 && $httpCode !== 201) {
                throw new \Exception('Upload failed: ' . $response);
            }

            // Return public URL
            return $this->supabaseUrl . '/storage/v1/object/public/' . $this->bucketName . '/' . $filename;

        } catch (\Exception $e) {
            error_log('Photo upload error: ' . $e->getMessage());
            return null;
        }
    }

    /**
     * Delete photo from storage
     */
    public function deletePhoto(string $photoUrl): bool
    {
        try {
            // Extract filename from URL
            $pattern = '/\/storage\/v1\/object\/public\/' . $this->bucketName . '\/(.*)/';
            if (!preg_match($pattern, $photoUrl, $matches)) {
                return false;
            }

            $filename = $matches[1];

            // Delete from Supabase Storage
            $url = $this->supabaseUrl . '/storage/v1/object/' . $this->bucketName . '/' . $filename;

            $ch = curl_init($url);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'DELETE');
            curl_setopt($ch, CURLOPT_HTTPHEADER, [
                'Authorization: Bearer ' . $this->supabaseKey,
            ]);

            $response = curl_exec($ch);
            $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            curl_close($ch);

            return $httpCode === 200;

        } catch (\Exception $e) {
            error_log('Photo delete error: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * Validate photo URL belongs to this app
     */
    public function isValidPhotoUrl(string $url): bool
    {
        $pattern = '/^' . preg_quote($this->supabaseUrl, '/') . '\/storage\/v1\/object\/public\/' . $this->bucketName . '\//';
        return preg_match($pattern, $url) === 1;
    }
}
