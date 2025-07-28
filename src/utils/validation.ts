import { z } from 'zod';
import sqlFormatter from 'sql-formatter';

// SQL code validation schema
const sqlSchema = z.string()
  .min(1, 'SQL code cannot be empty')
  .refine(
    (code) => {
      // Basic SQL injection prevention checks
      const dangerous = [
        'DROP DATABASE',
        'DROP TABLE',
        'DELETE FROM',
        'TRUNCATE TABLE',
        'ALTER USER',
        'CREATE USER',
        'GRANT ALL',
        ';--',
        '1=1',
        'OR 1=1'
      ];
      return !dangerous.some(pattern => 
        code.toUpperCase().includes(pattern)
      );
    },
    'Potentially dangerous SQL detected'
  );

// Database connection validation schema
export const connectionSchema = z.object({
  type: z.enum(['sybase', 'oracle']),
  host: z.string().min(1, 'Host is required'),
  port: z.string().regex(/^\d+$/, 'Port must be a number'),
  username: z.string().min(1, 'Username is required'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
  database: z.string().min(1, 'Database name is required'),
  connectionString: z.string().optional()
});

// Validate and sanitize SQL code
export const validateAndSanitizeSQL = (code: string) => {
  // Validate the SQL code
  sqlSchema.parse(code);
  
  // Format and sanitize the SQL
  const sanitized = sqlFormatter.format(code, {
    language: 'tsql', // or 'plsql' for Oracle
    uppercase: true,
    linesBetweenQueries: 2
  });
  
  return sanitized;
};

// Validate database connection
export const validateConnection = (connection: unknown) => {
  return connectionSchema.parse(connection);
};

// Validate file upload
export const validateFileUpload = (file: File) => {
  // Check file size (max 10MB)
  if (file.size > 10 * 1024 * 1024) {
    throw new Error('File size exceeds 10MB limit');
  }
  
  // Check file extension
  const allowedExtensions = ['.sql', '.txt'];
  const ext = '.' + file.name.split('.').pop()?.toLowerCase();
  if (!allowedExtensions.includes(ext)) {
    throw new Error('Invalid file type. Only .sql and .txt files are allowed');
  }
  
  return true;
}; 