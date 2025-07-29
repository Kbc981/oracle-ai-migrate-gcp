const nodemailer = require('nodemailer');

exports.handler = async function(event, context) {
  if (event.httpMethod !== 'POST') {
    return { statusCode: 405, body: JSON.stringify({ error: 'Method not allowed' }) };
  }

  try {
    const { name, email, subject, message } = JSON.parse(event.body);
    
    if (!name || !email || !subject || !message) {
      return { 
        statusCode: 400, 
        body: JSON.stringify({ error: 'Missing required fields' }) 
      };
    }

    // Create transporter using environment variables
    const transporter = nodemailer.createTransporter({
      service: 'gmail',
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
      }
    });

    // Email content
    const mailOptions = {
      from: process.env.EMAIL_USER,
      to: 'cheggkaushik7@gmail.com',
      subject: `Contact Form: ${subject}`,
      html: `
        <h2>New Contact Form Submission</h2>
        <p><strong>Name:</strong> ${name}</p>
        <p><strong>Email:</strong> ${email}</p>
        <p><strong>Subject:</strong> ${subject}</p>
        <p><strong>Message:</strong></p>
        <p>${message.replace(/\n/g, '<br>')}</p>
        <hr>
        <p><em>This message was sent from the Oracle AI Migration Tool contact form.</em></p>
      `
    };

    // Send email
    await transporter.sendMail(mailOptions);

    return { 
      statusCode: 200, 
      body: JSON.stringify({ 
        success: true, 
        message: 'Message sent successfully' 
      }) 
    };

  } catch (err) {
    console.error('Contact form error:', err);
    return { 
      statusCode: 500, 
      body: JSON.stringify({ 
        error: 'Failed to send message. Please try again later.' 
      }) 
    };
  }
}; 