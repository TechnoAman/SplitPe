# ⚡ SplitPe - viksit version 
### 0% MDR Arbitrage & Algorithmic UPI Bill-Tranching System

An experimental fintech application built with Flutter & CRED NeoPOP Design System.  
**Live App**: [viksit-garg.github.io/SplitPe/](https://viksit-garg.github.io/SplitPe/)

---

> [!WARNING]
> ### ⚖️ Educational & Research Purpose Disclaimer
> SplitPe is developed strictly for academic demonstration, educational research, and algorithmic simulation purposes. It serves as an open-source technical proof-of-concept exploring how UPI deep-linking schemas, NPCI interchange threshold rules, and client-side payment state machines interact.

---

## 💡 The Concept: 0% MDR Arbitrage

Under current Indian digital payments guidelines (NPCI & CBIC), single merchant UPI transactions exceeding ₹2,000 attract interchange/MDR fees (up to 0.4% - 1.1%) plus an additional 18% GST on the MDR service fee, while transactions of ₹2,000 or under remain 100% free (0% MDR & 0% GST).

For small kirana merchants, restaurants, and bill payers, high-ticket transactions incur compounding gateway fees and unclaimable GST. SplitPe programmatically solves this by algorithmically tranching any arbitrary bill (e.g. ₹6,800) into optimal sub-₹2,000 compliant micro-slices:

$$\text{Total Bill} = \sum_{i=1}^{n} \text{Tranche}_i \quad \text{where} \quad \forall i, \; \text{Tranche}_i \le ₹1,999.00$$

$$\text{Net Surcharge Paid} = 0$$

---

## ✨ Features

- ⚡ **Algorithmic Tranching Engine**: Automatically slices bills into compliant sub-₹2,000 micro-payments with distinct transaction reference keys.
- 🎨 **CRED NeoPOP 3D UI**: Built using the official NeoPOP neo-brutalist design framework with tactile depth, tilted elevation buttons, and obsidian dark mode.
- 🔊 **Soundbox Audio Simulator**: Emulates real-time merchant audio confirmations ("Payment of ₹X received via SplitPe") using an integrated speaker widget.
- 🍻 **Group Bill Splitter**: Splits dining and group bills with friends, generating instant 0% MDR share links for WhatsApp.
- 📷 **Integrated QR Scanner**: Fast mobile camera scanner decoding UPI payment intents (`pa`, `pn`, `am`, `tr`, `tn`).
- 📊 **Interactive MDR Roast Calculator**: Visualizes annual surcharge losses vs. zero-fee savings.

---

## 🛠️ Tech Stack & Architecture

- **Framework**: Flutter (Dart)
- **Design System**: Official neopop (CRED Design Framework)
- **State & Architecture**: Clean MVC / Service Architecture
- **Scanner**: mobile_scanner
- **QR Generation**: qr_flutter
- **Typography**: Google Fonts (Space Grotesk & Inter)
- **Sharing & Intents**: url_launcher, share_plus

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

This project is licensed under the MIT License — see the LICENSE file for details.

---

Built with Antigravity by [Byebye](https://github.com/VIKSIT-GARG) · Forked from [https://github.com/TechnoAman/SplitPe](https://github.com/TechnoAman/SplitPe)

**Credits**: [https://github.com/TechnoAman/SplitPe](https://github.com/TechnoAman/SplitPe)
