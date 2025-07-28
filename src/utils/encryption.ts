import { AES, enc } from 'crypto-js';

// Get encryption key from environment variable
const ENCRYPTION_KEY = import.meta.env.VITE_ENCRYPTION_KEY || 'default-dev-key-change-in-production';

/**
 * Encrypts sensitive data using AES encryption
 * @param data - The data to encrypt
 * @returns Encrypted string
 */
export const encrypt = (data: string): string => {
  if (!data) return '';
  try {
    return AES.encrypt(data, ENCRYPTION_KEY).toString();
  } catch (error) {
    console.error('Encryption error:', error);
    throw new Error('Failed to encrypt data');
  }
};

/**
 * Decrypts encrypted data using AES decryption
 * @param encryptedData - The encrypted data to decrypt
 * @returns Decrypted string
 */
export const decrypt = (encryptedData: string): string => {
  if (!encryptedData) return '';
  try {
    const bytes = AES.decrypt(encryptedData, ENCRYPTION_KEY);
    return bytes.toString(enc.Utf8);
  } catch (error) {
    console.error('Decryption error:', error);
    throw new Error('Failed to decrypt data');
  }
}; 