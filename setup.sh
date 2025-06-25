#!/bin/bash

# Appinion Setup Script

echo "🚀 Setting up Appinion..."

# Check if Config.plist already exists
if [ -f "Appinion/Config.plist" ]; then
    echo "⚠️  Config.plist already exists. Skipping..."
else
    # Copy the example configuration
    if [ -f "Appinion/Config.plist.example" ]; then
        cp "Appinion/Config.plist.example" "Appinion/Config.plist"
        echo "✅ Created Config.plist from example"
        echo ""
        echo "📝 Next steps:"
        echo "1. Get your OpenAI API key: https://platform.openai.com/api-keys"
        echo "2. Edit Appinion/Config.plist and replace YOUR_OPENAI_API_KEY_HERE"
        echo "3. Add Config.plist to Xcode project"
        echo "4. Build & run!"
        echo ""
        echo "🔒 Your API key stays secure (git-ignored)"
    else
        echo "❌ Error: Config.plist.example not found"
        exit 1
    fi
fi

echo ""
echo "🎉 Setup complete!"
echo "   • Open Appinion.xcodeproj in Xcode"
echo "   • Add Config.plist to project"
echo "   • Build and run"
