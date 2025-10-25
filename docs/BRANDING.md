<!--
SPDX-FileCopyrightText: 2025 hexaTune LLC
SPDX-License-Identifier: MIT
-->

# hexaGenApp Branding Guide

This document defines the visual identity, design system, and branding guidelines for hexaGenApp.

---

## 📋 Table of Contents

- [Color Palette](#color-palette)
- [Typography](#typography)
- [Theme Variants](#theme-variants)
- [Component Styling](#component-styling)
- [Design Principles](#design-principles)
- [Usage Guidelines](#usage-guidelines)

---

## 🎨 Color Palette

hexaGenApp uses a vibrant, modern color scheme built on Material Design 3 principles with custom hexaTune brand colors.

### Primary Colors - Yellow/Gold

The primary color represents frequency generation, energy, and precision.

| Usage | Light Mode | Dark Mode | Hex |
|-------|-----------|-----------|-----|
| **Primary** | Dark Gold | Cream Yellow | `#705d00` / `#fffff5dc` |
| **Primary Container** | Bright Yellow | Bright Yellow | `#ffd600` |
| **On Primary** | White | Dark Brown | `#ffffff` / `#3a3000` |
| **On Primary Container** | Dark Gold | Dark Gold | `#705d00` |

**Accent Shades:**
- Primary Fixed: `#ffe170`
- Primary Fixed Dim: `#e9c400`
- Surface Tint: `#e9c400`

### Secondary Colors - Cyan/Blue

The secondary color represents connectivity, communication, and MIDI signals.

| Usage | Light Mode | Dark Mode | Hex |
|-------|-----------|-----------|-----|
| **Secondary** | Deep Blue | Light Cyan | `#006684` / `#99deff` |
| **Secondary Container** | Bright Cyan | Bright Cyan | `#00c8ff` |
| **On Secondary** | White | Dark Blue | `#ffffff` / `#003546` |
| **On Secondary Container** | Dark Blue | Dark Blue | `#005068` |

**Accent Shades:**
- Secondary Fixed: `#bee9ff`
- Secondary Fixed Dim: `#68d3ff`

### Tertiary Colors - Purple/Magenta

The tertiary color represents creativity, innovation, and premium features.

| Usage | Light Mode | Dark Mode | Hex |
|-------|-----------|-----------|-----|
| **Tertiary** | Deep Purple | Light Purple | `#70008b` / `#f3aeff` |
| **Tertiary Container** | Material Purple | Material Purple | `#8e24aa` |
| **On Tertiary** | White | Dark Purple | `#ffffff` / `#55006a` |
| **On Tertiary Container** | Light Pink | Light Pink | `#f7bcff` |

**Accent Shades:**
- Tertiary Fixed: `#fdd6ff`
- Tertiary Fixed Dim: `#f3aeff`

### Error Colors

| Usage | Light Mode | Dark Mode | Hex |
|-------|-----------|-----------|-----|
| **Error** | Deep Red | Light Red | `#ba002c` / `#ffb3b3` |
| **Error Container** | Bright Red | Red Orange | `#e9003a` / `#ff525f` |
| **On Error** | White | Dark Red | `#ffffff` / `#680014` |

### Surface Colors

#### Light Mode
- **Surface**: `#fdf8f8` (Off-white)
- **Surface Dim**: `#ddd9d8`
- **Surface Bright**: `#fdf8f8`
- **Surface Container Lowest**: `#ffffff`
- **Surface Container Low**: `#f7f3f2`
- **Surface Container**: `#f1edec`
- **Surface Container High**: `#ebe7e6`
- **Surface Container Highest**: `#e5e2e1`
- **On Surface**: `#1c1b1b` (Near black)
- **On Surface Variant**: `#46464a`

#### Dark Mode
- **Surface**: `#141313` (Near black, OLED-friendly)
- **Surface Dim**: `#141313`
- **Surface Bright**: `#3a3939`
- **Surface Container Lowest**: `#0e0e0e`
- **Surface Container Low**: `#1c1b1b`
- **Surface Container**: `#201f1f`
- **Surface Container High**: `#2b2a2a`
- **Surface Container Highest**: `#353434`
- **On Surface**: `#e5e2e1` (Off-white)
- **On Surface Variant**: `#c7c6ca`

### Outline Colors

| Usage | Light Mode | Dark Mode |
|-------|-----------|-----------|
| **Outline** | `#77777b` | `#919095` |
| **Outline Variant** | `#c7c6ca` | `#46464a` |

### Additional System Colors

- **Shadow**: `#000000` (All modes)
- **Scrim**: `#000000` (All modes)
- **Inverse Surface**: `#313030` (Light) / `#e5e2e1` (Dark)
- **Inverse Primary**: `#e9c400` (Light) / `#705d00` (Dark)

---

## ✍️ Typography

hexaGenApp uses a dual-font system for optimal readability and visual hierarchy.

### Font Families

#### **Inter** - Body Text & UI Elements
- **Usage**: Body text, labels, buttons, form inputs
- **Characteristics**: Humanist sans-serif, optimized for screen readability
- **Weights Available**: Regular (400), Medium (500), SemiBold (600), Bold (700)
- **File Locations**: 
  - `assets/fonts/Inter-Regular.ttf`
  - `assets/fonts/Inter-Medium.ttf`
  - `assets/fonts/Inter-SemiBold.ttf`
  - `assets/fonts/Inter-Bold.ttf`

**Applied to:**
- `bodyLarge`, `bodyMedium`, `bodySmall`
- `labelLarge`, `labelMedium`, `labelSmall`

#### **Rajdhani** - Headings & Titles
- **Usage**: Display text, headlines, titles, navigation
- **Characteristics**: Geometric sans-serif with technical aesthetic
- **Weights Available**: Regular (400), Medium (500), SemiBold (600), Bold (700)
- **File Locations**:
  - `assets/fonts/Rajdhani-Regular.ttf`
  - `assets/fonts/Rajdhani-Medium.ttf`
  - `assets/fonts/Rajdhani-SemiBold.ttf`
  - `assets/fonts/Rajdhani-Bold.ttf`

**Applied to:**
- `displayLarge`, `displayMedium`, `displaySmall`
- `headlineLarge`, `headlineMedium`, `headlineSmall`
- `titleLarge`, `titleMedium`, `titleSmall`

### Typography Scale

Flutter's Material Design 3 typography scale is used with custom font assignments:

| Style | Font Family | Usage Example |
|-------|-------------|---------------|
| **Display Large** | Rajdhani | Hero text, splash screens |
| **Display Medium** | Rajdhani | Large headings |
| **Display Small** | Rajdhani | Section headers |
| **Headline Large** | Rajdhani | Page titles |
| **Headline Medium** | Rajdhani | Card titles |
| **Headline Small** | Rajdhani | List section headers |
| **Title Large** | Rajdhani | Dialog titles |
| **Title Medium** | Rajdhani | List item titles |
| **Title Small** | Rajdhani | Dense titles |
| **Body Large** | Inter | Primary body text |
| **Body Medium** | Inter | Secondary body text |
| **Body Small** | Inter | Captions, metadata |
| **Label Large** | Inter | Prominent buttons |
| **Label Medium** | Inter | Standard buttons |
| **Label Small** | Inter | Small UI labels |

---

## 🌓 Theme Variants

hexaGenApp supports three theme modes to accommodate different user preferences and accessibility needs.

### 1. Light Mode
**Default theme for daytime use**

- High brightness for outdoor visibility
- Warm surface colors (`#fdf8f8`)
- High contrast ratios for readability
- Vibrant primary colors

**Best for:**
- Bright environments
- Outdoor use
- Users who prefer light interfaces

### 2. Dark Mode
**OLED-optimized for battery efficiency**

- True black surface (`#141313`)
- Reduces eye strain in low light
- Battery-efficient on OLED screens
- Desaturated colors to prevent bloom

**Best for:**
- Night usage
- Battery conservation
- Reduced eye strain
- OLED devices

### 3. High Contrast Mode (Light & Dark)

**Accessibility-focused variants**

#### Light High Contrast
- Deeper primary colors (`#362b00`)
- Stronger outline definition
- Maximum color separation
- WCAG AAA compliant

#### Dark High Contrast
- Brighter accent colors
- Increased outline visibility
- Enhanced surface differentiation
- Suitable for visual impairments

**Best for:**
- Users with visual impairments
- High ambient light conditions
- Critical data monitoring
- Accessibility compliance

### Medium Contrast Variants

Intermediate options between standard and high contrast for users who need slightly enhanced differentiation without full high-contrast mode.

---

## 🎯 Component Styling

### Material Design 3 Components

All UI components follow Material Design 3 specifications with hexaGenApp color theming:

#### Buttons
- **Filled Button**: Primary color background, high emphasis
- **Outlined Button**: Outline color border, medium emphasis
- **Text Button**: No background, low emphasis

#### Cards
- **Elevated Card**: Surface + shadow
- **Filled Card**: Surface container color
- **Outlined Card**: Surface + outline

#### Navigation
- **Bottom Navigation Bar**: Surface container with primary indicators
- **Navigation Rail**: For larger screens
- **Tab Bar**: Primary color for active tabs

#### Input Fields
- **Filled TextField**: Surface container background
- **Outlined TextField**: Outline border
- **Validation**: Error color for invalid states

#### Floating Action Button (FAB)
- **Primary FAB**: Primary container color
- **Extended FAB**: Primary container with label
- **Usage**: Start/stop frequency generation

---

## 🎨 Design Principles

### 1. Technical Precision
Visual design reflects the precision of frequency generation through:
- Sharp geometric shapes
- Exact alignment and spacing
- Grid-based layouts
- Technical font (Rajdhani) for headings

### 2. Energy & Vibrance
Color palette conveys energy and innovation:
- Bright yellow primary for energy
- Cyan accents for signal flow
- Purple highlights for premium features

### 3. Clarity & Readability
Information hierarchy ensures usability:
- High contrast text
- Clear typography scale
- Sufficient whitespace
- Status color coding (green/blue/red)

### 4. Accessibility First
Design accommodates all users:
- WCAG 2.1 AA minimum (AAA for high contrast)
- Multiple theme variants
- Clear focus indicators
- Scalable text sizes

### 5. Consistency
Unified experience across platforms:
- Shared color system
- Consistent component behavior
- Platform-appropriate interactions
- Material Design 3 foundation

---

## 📐 Usage Guidelines

### Color Usage

#### Do's ✅
- Use primary yellow for main actions (generation control)
- Use secondary cyan for device/MIDI indicators
- Use tertiary purple for premium/advanced features
- Use error red only for errors and destructive actions
- Maintain contrast ratios: 4.5:1 minimum for text
- Test colors in both light and dark modes

#### Don'ts ❌
- Don't use primary color for non-critical elements
- Don't mix yellow and red (confusing signal)
- Don't use custom colors outside the defined palette
- Don't reduce contrast for aesthetic purposes
- Don't use color as the only indicator (accessibility)

### Typography Usage

#### Do's ✅
- Use Rajdhani for all headings and titles
- Use Inter for all body text and UI labels
- Follow Material Design 3 typography scale
- Maintain minimum 16px for body text
- Use appropriate font weights for hierarchy

#### Don'ts ❌
- Don't use system fonts (breaks consistency)
- Don't mix fonts arbitrarily
- Don't use font sizes below 12px
- Don't use too many font weight variations
- Don't stretch or condense fonts

### Theme Selection

#### Automatic Theme Switching
- Respect system theme preference by default
- Allow manual override in settings
- Persist user selection

#### Theme Transitions
- Smooth animated transitions between themes
- Avoid jarring color shifts
- Maintain element positions during transition

---

## 🖼️ Brand Assets

### App Icon
- **Location**: `assets/icon/app_icon.png`
- **Sizes**: Platform-specific (iOS, Android, etc.)
- **Design**: Incorporates hexaTune branding with frequency wave motif

### Splash Screen
- Uses primary brand colors
- hexaTune logo centered
- Clean, minimalist design

---

## 📱 Platform Adaptations

### Android
- Material Design 3 components
- System navigation gestures
- Dynamic color support (optional)

### iOS
- Cupertino widgets where appropriate
- iOS-specific navigation patterns
- Respect iOS Human Interface Guidelines

### Desktop (Linux, macOS, Windows)
- Larger touch targets
- Keyboard navigation
- Responsive layouts for larger screens

### Web
- Responsive design
- Progressive Web App (PWA) support
- Browser-specific optimizations

---

## 🔧 Implementation

### Theme Files
- **Main Theme**: `lib/src/core/theme/freq.dart`
- **Text Theme**: `lib/src/core/utils/theme.dart`
- **Font Assets**: `assets/fonts/`

### Code Example

```dart
// Accessing theme colors
final primary = Theme.of(context).colorScheme.primary;
final surface = Theme.of(context).colorScheme.surface;

// Accessing typography
final headlineStyle = Theme.of(context).textTheme.headlineLarge;
final bodyStyle = Theme.of(context).textTheme.bodyMedium;

// Theme switching (via StorageService)
await StorageService().setThemeMode(ThemeMode.dark);
```

---

## 📬 Questions?

For branding inquiries, design questions, or usage permissions:

- **Email**: [info@hexatune.com](mailto:info@hexatune.com)
- **Website**: [hexatune.com](https://hexatune.com)
- **GitHub**: [github.com/hTuneSys/hexaGenApp](https://github.com/hTuneSys/hexaGenApp)

---

## 📄 Maintained by **hexaTune LLC**

Built by [hexaTune LLC](https://hexatune.com) · GitHub: [hTuneSys/hexaGenApp](https://github.com/hTuneSys/hexaGenApp) · License: [MIT](https://opensource.org/license/mit/)
