# Appinion

A SwiftUI app that searches App Store apps and generates AI-powered summaries of customer reviews using OpenAI.

![RocketSim_Recording_iPhone_16_Pro_6 3_2025-06-25_15 45 54](https://github.com/user-attachments/assets/78ffee99-f833-43e1-a48d-8d922dcefe83)

## Features

🔍 **Universal Search** - Find any public App Store app  
🤖 **AI Summaries** - GPT-powered review analysis  
💾 **Smart Caching** - Local storage with SwiftData  
⚡ **Simple Setup** - Just add your OpenAI API key

## Quick Start

1. **Clone & Setup**
   ```bash
   git clone <repository-url>
   cd Appinion
   ./setup.sh
   ```

2. **Add API Key**
   - Get your key: [OpenAI Platform](https://platform.openai.com/api-keys)
   - Edit `Appinion/Config.plist` 
   - Replace `YOUR_OPENAI_API_KEY_HERE` with your key

3. **Build**
   - Open `Appinion.xcodeproj` in Xcode 16.0+
   - Add `Config.plist` to project (right-click → Add Files)
   - Build & Run (⌘+R)

## Architecture

- **SwiftUI + MVVM** - Modern iOS patterns
- **SwiftData** - Local persistence (iOS 18.5+)
- **iTunes APIs** - Public app search & reviews (no auth required)
- **OpenAI GPT** - Review summarization

## Security

Your API key is automatically protected:
- `Config.plist` is git-ignored
- Keys never committed to repository
- Easy contributor onboarding with template

## Requirements

- iOS 18.5+ / Xcode 16.0+
- OpenAI API key (only external dependency)

## License

MIT License - see [LICENSE](LICENSE) file for details.

---

**Questions?** Check the troubleshooting section in the code or create an issue.
