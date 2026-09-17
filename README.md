# ⚡ SplitPe

<div align="center">
  <h3><strong>0% MDR Arbitrage & Algorithmic UPI Bill-Tranching System</strong></h3>
  <p>An experimental fintech application built with Flutter & CRED NeoPOP Design System.</p>

  <p>
    <a href="https://technoaman.github.io/SplitPe/"><img src="https://img.shields.io/badge/🌐_Live_Demo-Visit_SplitPe_Web-00E676?style=for-the-badge&logoColor=black" alt="Live Demo" /></a>
    <a href="https://github.com/TechnoAman/SplitPe"><img src="https://img.shields.io/badge/Reddit-850%2B_Upvotes-FF4500?style=for-the-badge&logo=reddit&logoColor=white" alt="Reddit 850+ Upvotes" /></a>
    <a href="https://github.com/TechnoAman/SplitPe"><img src="https://img.shields.io/badge/Views-169K%2B-FF4500?style=for-the-badge&logo=reddit&logoColor=white" alt="169K+ Views" /></a>
    <a href="https://github.com/TechnoAman/SplitPe"><img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" /></a>
    <a href="https://github.com/TechnoAman/SplitPe"><img src="https://img.shields.io/badge/Design-CRED_NeoPOP-00E676?style=for-the-badge&logo=flutter&logoColor=black" alt="CRED NeoPOP" /></a>
    <a href="https://github.com/TechnoAman/SplitPe"><img src="https://img.shields.io/badge/NPCI_MDR-0%25_Arbitrage-00FF66?style=for-the-badge" alt="0% MDR" /></a>
    <a href="https://github.com/TechnoAman/SplitPe"><img src="https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge" alt="License" /></a>
  </p>

  <p>
    🔗 <strong>Live App:</strong> <a href="https://technoaman.github.io/SplitPe/">https://technoaman.github.io/SplitPe/</a> &nbsp;|&nbsp; 🔺 <strong>850+ Reddit Upvotes</strong> &nbsp;|&nbsp; 👁️ <strong>169K+ Views</strong>
  </p>
</div>

https://github.com/user-attachments/assets/cf6e4d3f-3286-4bcd-9004-080d9a7c6520




---

> [!WARNING]
> ### ⚖️ **Educational & Research Purpose Disclaimer**
> **SplitPe is developed strictly for academic demonstration, educational research, and algorithmic simulation purposes.**
> It serves as an open-source technical proof-of-concept exploring how UPI deep-linking schemas, NPCI interchange threshold rules, and client-side payment state machines interact.

---

## 💡 The Concept: 0% MDR Arbitrage

Under current Indian digital payments guidelines (NPCI), single merchant UPI transactions exceeding **₹2,000** attract interchange/MDR fees (up to 0.4% - 1.1%), while transactions of **₹2,000 or under remain 100% free (0% MDR)**.

For small kirana merchants, restaurants, and bill payers, high-ticket transactions incur compounding gateway fees. **SplitPe** programmatically solves this by algorithmically tranching any arbitrary bill (e.g. ₹6,800) into optimal sub-₹2,000 compliant micro-slices:

$$\text{Total Bill} = \sum_{i=1}^{n} \text{Tranche}_i \quad \text{where} \quad \forall i, \; \text{Tranche}_i \le ₹1,999.00$$

---

## ✨ Features

- ⚡ **Algorithmic Tranching Engine**: Automatically slices bills into compliant sub-₹2,000 micro-payments with distinct transaction reference keys.
- 🎨 **CRED NeoPOP 3D UI**: Built using the official NeoPOP neo-brutalist design framework with tactile depth, tilted elevation buttons, and obsidian dark mode.
- 🔊 **Soundbox Audio Simulator**: Emulates real-time merchant audio confirmations (*"Payment of ₹X received via SplitPe"*) using an integrated speaker widget.
- 🍻 **Group Bill Splitter**: Splits dining and group bills with friends, generating instant 0% MDR share links for WhatsApp.
- 📷 **Integrated QR Scanner**: Fast mobile camera scanner decoding UPI payment intents (`pa`, `pn`, `am`, `tr`, `tn`).
- 📊 **Interactive MDR Roast Calculator**: Visualizes annual surcharge losses vs. zero-fee savings.

---

## 🛠️ Tech Stack & Architecture

- **Framework**: [Flutter](https://flutter.dev) (Dart)
- **Design System**: Official [`neopop`](https://pub.dev/packages/neopop) (CRED Design Framework)
- **State & Architecture**: Clean MVC / Service Architecture
- **Scanner**: [`mobile_scanner`](https://pub.dev/packages/mobile_scanner)
- **QR Generation**: [`qr_flutter`](https://pub.dev/packages/qr_flutter)
- **Typography**: [Google Fonts](https://fonts.google.com) (Space Grotesk & Inter)
- **Sharing & Intents**: [`url_launcher`](https://pub.dev/packages/url_launcher), [`share_plus`](https://pub.dev/packages/share_plus)

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `>=3.3.0`
- Android Studio / VS Code / Xcode

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/TechnoAman/SplitPe.git

# 2. Navigate to project directory
cd SplitPe

# 3. Install dependencies
flutter pub get

# 4. Run the app
flutter run
```

---

## 🧪 Testing

```bash
# Run unit & widget test suites
flutter test

# Run code analyzer
flutter analyze
```

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<div align="center">
  <sub>Built with ⚡ by <a href="https://github.com/TechnoAman">Aman Tiwari</a></sub>
</div>
