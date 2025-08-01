#!/bin/bash

# AI-Powered Sybase to Oracle Migration Tool - Architecture Documentation Generator
# This script generates both HTML and PDF versions of the comprehensive architecture documentation

echo "🚀 Generating Architecture Documentation for Hackathon Submission..."
echo "=================================================="

# Set colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory of the script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
DOCS_DIR="$SCRIPT_DIR"

echo -e "${BLUE}📂 Working directory: $DOCS_DIR${NC}"

# Check if required files exist
if [ ! -f "$DOCS_DIR/HACKATHON_ARCHITECTURE.md" ]; then
    echo -e "${RED}❌ Error: HACKATHON_ARCHITECTURE.md not found!${NC}"
    exit 1
fi

if [ ! -f "$DOCS_DIR/HACKATHON_ARCHITECTURE.html" ]; then
    echo -e "${RED}❌ Error: HACKATHON_ARCHITECTURE.html not found!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Found required documentation files${NC}"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Try to generate PDF using various methods
generate_pdf() {
    local html_file="$1"
    local pdf_file="$2"
    
    echo -e "${YELLOW}📄 Attempting to generate PDF: $pdf_file${NC}"
    
    # Method 1: Try wkhtmltopdf (most reliable for complex HTML)
    if command_exists wkhtmltopdf; then
        echo -e "${BLUE}🔧 Using wkhtmltopdf...${NC}"
        wkhtmltopdf \
            --page-size A4 \
            --margin-top 1in \
            --margin-bottom 1in \
            --margin-left 0.8in \
            --margin-right 0.8in \
            --enable-local-file-access \
            --print-media-type \
            "$html_file" "$pdf_file"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ PDF generated successfully with wkhtmltopdf!${NC}"
            return 0
        else
            echo -e "${YELLOW}⚠️  wkhtmltopdf failed, trying next method...${NC}"
        fi
    fi
    
    # Method 2: Try Puppeteer (Chrome headless)
    if command_exists npx; then
        echo -e "${BLUE}🔧 Trying Puppeteer...${NC}"
        
        # Create a simple Node.js script for PDF generation
        cat > "$DOCS_DIR/generate-pdf.js" << 'EOF'
const puppeteer = require('puppeteer');
const path = require('path');

(async () => {
  try {
    const browser = await puppeteer.launch();
    const page = await browser.newPage();
    
    const htmlPath = path.resolve(process.argv[2]);
    const pdfPath = path.resolve(process.argv[3]);
    
    await page.goto(`file://${htmlPath}`, { waitUntil: 'networkidle0' });
    
    await page.pdf({
      path: pdfPath,
      format: 'A4',
      margin: {
        top: '1in',
        bottom: '1in',
        left: '0.8in',
        right: '0.8in'
      },
      printBackground: true
    });
    
    await browser.close();
    console.log('✅ PDF generated successfully with Puppeteer!');
  } catch (error) {
    console.error('❌ Error generating PDF:', error);
    process.exit(1);
  }
})();
EOF
        
        # Check if puppeteer is available
        if npx puppeteer --version >/dev/null 2>&1; then
            node "$DOCS_DIR/generate-pdf.js" "$html_file" "$pdf_file"
            
            if [ $? -eq 0 ]; then
                rm -f "$DOCS_DIR/generate-pdf.js"
                echo -e "${GREEN}✅ PDF generated successfully with Puppeteer!${NC}"
                return 0
            else
                echo -e "${YELLOW}⚠️  Puppeteer failed, trying next method...${NC}"
            fi
        else
            echo -e "${YELLOW}⚠️  Puppeteer not available, trying next method...${NC}"
        fi
        
        rm -f "$DOCS_DIR/generate-pdf.js"
    fi
    
    # Method 3: Try Chrome/Chromium headless
    for chrome_cmd in google-chrome chromium-browser chromium chrome; do
        if command_exists $chrome_cmd; then
            echo -e "${BLUE}🔧 Using $chrome_cmd headless...${NC}"
            $chrome_cmd \
                --headless \
                --disable-gpu \
                --print-to-pdf="$pdf_file" \
                --print-to-pdf-no-header \
                --virtual-time-budget=10000 \
                "file://$html_file"
            
            if [ $? -eq 0 ] && [ -f "$pdf_file" ]; then
                echo -e "${GREEN}✅ PDF generated successfully with $chrome_cmd!${NC}"
                return 0
            else
                echo -e "${YELLOW}⚠️  $chrome_cmd failed, trying next method...${NC}"
            fi
        fi
    done
    
    # Method 4: Try Prince XML (if available)
    if command_exists prince; then
        echo -e "${BLUE}🔧 Using Prince XML...${NC}"
        prince "$html_file" -o "$pdf_file"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ PDF generated successfully with Prince XML!${NC}"
            return 0
        else
            echo -e "${YELLOW}⚠️  Prince XML failed...${NC}"
        fi
    fi
    
    return 1
}

# Generate PDF
HTML_FILE="$DOCS_DIR/HACKATHON_ARCHITECTURE.html"
PDF_FILE="$DOCS_DIR/HACKATHON_ARCHITECTURE.pdf"

if generate_pdf "$HTML_FILE" "$PDF_FILE"; then
    echo -e "${GREEN}🎉 Success! Architecture documentation generated:${NC}"
    echo -e "   📝 Markdown: $(basename "$DOCS_DIR/HACKATHON_ARCHITECTURE.md")"
    echo -e "   🌐 HTML: $(basename "$HTML_FILE")"
    echo -e "   📄 PDF: $(basename "$PDF_FILE")"
else
    echo -e "${RED}❌ Failed to generate PDF automatically.${NC}"
    echo -e "${YELLOW}📋 Manual PDF generation options:${NC}"
    echo ""
    echo "1. Open the HTML file in your browser and use 'Print to PDF':"
    echo "   file://$HTML_FILE"
    echo ""
    echo "2. Install wkhtmltopdf and run:"
    echo "   sudo apt-get install wkhtmltopdf  # Ubuntu/Debian"
    echo "   brew install wkhtmltopdf          # macOS"
    echo "   then run this script again"
    echo ""
    echo "3. Use online HTML to PDF converters"
    echo ""
    echo -e "${GREEN}✅ HTML documentation is ready for viewing and manual PDF conversion!${NC}"
fi

# Generate a README for the documentation
cat > "$DOCS_DIR/README_ARCHITECTURE.md" << 'EOF'
# Architecture Documentation

This directory contains comprehensive architecture documentation for the AI-Powered Sybase to Oracle Migration Tool hackathon project.

## Files

- `HACKATHON_ARCHITECTURE.md` - Complete markdown documentation
- `HACKATHON_ARCHITECTURE.html` - Formatted HTML version for viewing/printing
- `HACKATHON_ARCHITECTURE.pdf` - PDF version (if generated)
- `generate-docs.sh` - Script to generate documentation formats

## Viewing the Documentation

### Markdown Version
Open `HACKATHON_ARCHITECTURE.md` in any markdown viewer or editor.

### HTML Version
Open `HACKATHON_ARCHITECTURE.html` in any web browser. This version includes:
- Professional styling and formatting
- Table of contents with navigation
- Responsive design
- Print-optimized CSS

### PDF Version
If the PDF was generated automatically, open `HACKATHON_ARCHITECTURE.pdf`.

If not generated, you can create a PDF by:
1. Opening the HTML file in a browser
2. Using Print → Save as PDF
3. Adjusting print settings for best results

## Content Overview

The documentation covers:

- 🎯 Executive Summary
- 🏗️ System Architecture Overview
- 🔧 Technology Stack
- 🗄️ Database Architecture
- 🔄 Data Flow Architecture
- 🧠 AI Processing Architecture
- 🔐 Security Architecture
- 🚀 Deployment Architecture
- 📊 Performance & Scalability
- 🎨 User Experience Architecture
- 📈 Analytics & Monitoring
- 🔧 API Architecture
- 🎯 Business Logic Architecture
- 🔍 Testing Architecture
- 🚀 Future Enhancements & Roadmap
- 📊 Success Metrics & KPIs
- 🔗 Integration Ecosystem
- 📚 Conclusion

## For Hackathon Judges

This documentation demonstrates:
- Comprehensive technical planning
- Enterprise-grade architecture thinking
- AI-first approach to problem solving
- Scalability and security considerations
- Real-world implementation feasibility
EOF

echo ""
echo -e "${BLUE}📖 Generated README_ARCHITECTURE.md for documentation overview${NC}"
echo ""
echo -e "${GREEN}🎯 Architecture documentation package complete!${NC}"
echo -e "${YELLOW}💡 Tip: The HTML version provides the best viewing experience with professional styling.${NC}"

# Display file sizes
echo ""
echo -e "${BLUE}📊 File sizes:${NC}"
ls -lh "$DOCS_DIR"/HACKATHON_ARCHITECTURE.* "$DOCS_DIR"/README_ARCHITECTURE.md 2>/dev/null | awk '{print "   " $9 ": " $5}'

echo ""
echo -e "${GREEN}🚀 Ready for hackathon submission! 🏆${NC}"