import express from 'express';
import cors from 'cors';
import rateLimit from 'express-rate-limit';
import { GoogleGenerativeAI } from "@google/generative-ai";

const app = express();

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});

app.use(cors({
  origin: process.env.FRONTEND_URL,
  credentials: true
}));
app.use(limiter);
app.use(express.json());

// Secure API endpoints
app.post('/api/convert', async (req, res) => {
  try {
    const { code, model } = req.body;
    
    // Input validation
    if (!code || typeof code !== 'string') {
      return res.status(400).json({ error: 'Invalid code input' });
    }
    
    // Initialize Gemini AI with server-side API key
    const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
    
    // Process conversion
    const result = await processConversion(genAI, code, model);
    
    res.json(result);
  } catch (error) {
    console.error('Conversion error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
}); 