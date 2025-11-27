# 🏗️ BersatuBantu Template Architecture & System Design

## 📐 System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                      APPLICATION LAYER                          │
│  (Fitur Features: Auth, Donasi, Aktivitas, Welcome)           │
└─────────────────────────────────────────────────────────────────┘
                              ↓ Uses
┌─────────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                         │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────┐  │
│  │  Auth Screens    │  │  List Screens    │  │ Detail Screen│  │
│  │  (Form Template) │  │ (List Template)  │  │  (Template)  │  │
│  └──────────────────┘  └──────────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              ↓ Uses
┌─────────────────────────────────────────────────────────────────┐
│                     COMPONENT LAYER                             │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ Core Components (lib/core/widgets)                      │   │
│  │                                                         │   │
│  │ ┌─────────────┐  ┌────────────────┐  ┌──────────────┐ │   │
│  │ │ AppButton   │  │ AppTextField   │  │ AppScaffold  │ │   │
│  │ │ (5 vars,3sz)│  │(validation,err)│  │(base layout) │ │   │
│  │ └─────────────┘  └────────────────┘  └──────────────┘ │   │
│  │                                                         │   │
│  │ ┌─────────────┐  ┌────────────────┐  ┌──────────────┐ │   │
│  │ │ FormLayout  │  │ ActionCard     │  │FeatureCard   │ │   │
│  │ │(form layout)│  │(clickable card)│  │(card w/ img) │ │   │
│  │ └─────────────┘  └────────────────┘  └──────────────┘ │   │
│  │                                                         │   │
│  │ ┌─────────────┐  ┌────────────────┐  ┌──────────────┐ │   │
│  │ │ AppBadge    │  │ AppDialog      │  │AppSnackBar   │ │   │
│  │ │(status tag) │  │(confirmation)  │  │(notification)│ │   │
│  │ └─────────────┘  └────────────────┘  └──────────────┘ │   │
│  │                                                         │   │
│  │ ┌────────────────────────────────────────────────────┐ │   │
│  │ │ ListItemCard - List item dengan title+subtitle    │ │   │
│  │ └────────────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              ↓ Uses
┌─────────────────────────────────────────────────────────────────┐
│                    DESIGN SYSTEM LAYER                          │
│  ┌──────────────────┐  ┌───────────────────┐  ┌─────────────┐  │
│  │  AppColors       │  │  AppTextStyle     │  │ AppTheme    │  │
│  │  • 45+ Colors    │  │  • 15+ Styles     │  │ • Light     │  │
│  │  • Hex Values    │  │  • Font Sizes     │  │ • Dark (TBD)│  │
│  │  • Gradients     │  │  • Font Weights   │  │ • Material  │  │
│  │  • Opacity vars  │  │  • Line Heights   │  │   Config    │  │
│  └──────────────────┘  └───────────────────┘  └─────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Constants & Standards                                    │  │
│  │ • Border Radius: 10-16px                               │  │
│  │ • Padding: 16px (default), 12px (items), 8px (compact)│  │
│  │ • Animation Duration: 200ms                            │  │
│  │ • Shadow: Subtle elevation                             │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🧩 Component Dependency Graph

```
┌────────────────────────────────┐
│   Application Features          │
│ (auth, donasi, aktivitas)       │
└────────────────────────────────┘
              ↓
       ┌──────────────┐
       │ Screen Pages │
       │ (UI Layer)   │
       └──────────────┘
         ↓        ↓        ↓
    ┌────┴────┬───┴──┬────┴─────┐
    │          │      │          │
┌─────────┐┌──────┐┌──────┐┌──────────┐
│FormLayout││ListSc││Detail││GridView │
│  Layout  ││Screen││Screen│+Cards    │
└─────────┘└──────┘└──────┘└──────────┘
    │       │       │         │
    └───┬───┴───┬───┴─────┬───┘
        │       │         │
  ┌─────┴────┬──┴──┬──────┴──────────┐
  │           │     │                 │
┌──────────┐┌──────────┐┌──────────┐┌──────────┐
│AppButton ││AppTextField││ActionCard││FeatureCard
└──────────┘└──────────┘└──────────┘└──────────┘
  │         │          │              │
  └─────┬───┴──────┬───┴──────────┬───┘
        │          │              │
  ┌─────┴──┬──────┴──┬───────┬────┴───────┐
  │        │        │       │            │
┌──────┐┌──────┐┌────────┐┌────────┐┌──────────┐
│Button││Label ││Icon    ││Image   ││Container │
│Style ││Style ││Color   ││Effect  ││Border    │
└──────┘└──────┘└────────┘└────────┘└──────────┘
        ↓              ↓                ↓
  ┌─────────────┬─────────────────┬─────────────┐
  │             │                 │             │
┌──────────┐┌───────────────┐┌──────────────────┐
│AppColors ││AppTextStyle   ││AppTheme (Material)
└──────────┘└───────────────┘└──────────────────┘
```

---

## 🔄 Data Flow in Screen Implementation

```
User Input
    ↓
┌─────────────────────┐
│ State Management    │
│ • TextControllers   │
│ • Loading flags     │
│ • Error states      │
└─────────────────────┘
    ↓
┌─────────────────────┐
│ Validation Logic    │
│ • Check empty       │
│ • Check format      │
│ • Show error msgs   │
└─────────────────────┘
    ↓
┌─────────────────────┐
│ Component Updates   │
│ • Render UI         │
│ • Show errors       │
│ • Apply styling     │
└─────────────────────┘
    ↓
┌─────────────────────┐
│ User Sees Results   │
│ • Validated input   │
│ • Error feedback    │
│ • Success state     │
└─────────────────────┘
```

---

## 📊 Component Usage Matrix

| Component | Form | List | Detail | Dashboard |
|-----------|------|------|--------|-----------|
| AppButton | ✅   | ✅   | ✅     | ✅        |
| AppTextField | ✅ | ⚠️   | ❌     | ❌        |
| FormLayout | ✅  | ❌   | ❌     | ❌        |
| ActionCard | ❌  | ✅   | ❌     | ✅        |
| FeatureCard | ❌ | ✅   | ✅     | ✅        |
| ListItemCard | ❌ | ✅   | ⚠️     | ❌        |
| AppBadge | ⚠️   | ✅   | ✅     | ✅        |
| AppDialog | ✅  | ✅   | ✅     | ✅        |
| AppSnackBar | ✅ | ✅   | ✅     | ✅        |

Legend: ✅ Recommended | ⚠️ Optional | ❌ Not typical

---

## 🎨 Design Token Hierarchy

```
Level 1: Foundation
├── Hue (Blue, Green, Red, etc)
├── Saturation (Pure, Muted, etc)
└── Brightness (Light, Dark, etc)
    ↓
Level 2: Semantic Tokens
├── Primary (UI element color)
├── Secondary (Alternative color)
├── Error (Error states)
├── Success (Success states)
└── Warning (Warning states)
    ↓
Level 3: Component Tokens
├── Button Primary
├── Button Secondary
├── Input Field
├── Card
└── Text
    ↓
Level 4: Implementation
└── Actual component usage
```

---

## 🔐 State Management Pattern

```
Screen State
    ├── UI State (loading, error, success)
    ├── Form State (field values, validation errors)
    ├── Data State (list items, detail data)
    └── Navigation State (current route, params)

State Management Flow:
1. User Action → 2. State Update → 3. Widget Rebuild → 4. UI Update
```

---

## 📱 Responsive Design Strategy

```
Mobile (360-400px)  |  Tablet (600-800px)  |  Desktop (1000px+)
─────────────────────────────────────────────────────────────
Single Column       |  2-Column Layout     |  3+ Column Layout
Full Width Cards    |  Constrained Width   |  Sidebar + Content
Stack Vertically    |  Grid Layout         |  Flexible Grid
─────────────────────────────────────────────────────────────

Implementation in Components:
• Use MediaQuery for breakpoints
• Use LayoutBuilder for constraints
• Use Flexible/Expanded for layouts
• Test at multiple widths
```

---

## ♿ Accessibility Architecture

```
Component Level
    ├── Semantic Labels
    ├── Color Contrast (WCAG AA)
    ├── Focus Indicators
    ├── Gesture Support
    └── Text Size Options

Screen Level
    ├── Logical Tab Order
    ├── Meaningful Error Messages
    ├── Clear Call-to-Action
    ├── Consistent Navigation
    └── Sufficient Spacing

App Level
    ├── Keyboard Navigation
    ├── Screen Reader Support
    ├── High Contrast Mode
    ├── Text Scaling
    └── Accessible Colors
```

---

## 🎯 Color System Architecture

```
Primary Color System (Blue)
├── Primary Blue (#5B6EFF)
├── Primary Dark (#4A54D9) → For pressed/hover
└── Primary Light (#7B8EFF) → For subtle elements

Accent Colors
├── Green (#10B981) → Success/positive
├── Red (#EF4444) → Danger/negative
├── Orange (#F97316) → Warning/caution
└── Yellow (#FCD34D) → Highlight/alert

Neutral Colors
├── Text Colors
│   ├── Primary (#1F2937)
│   ├── Secondary (#6B7280)
│   ├── Tertiary (#9CA3AF)
│   └── Disabled (#D1D5DB)
├── Background Colors
│   ├── Primary (#FFFFFF)
│   ├── Secondary (#F3F4F6)
│   ├── Tertiary (#E5E7EB)
│   └── Dark (#111827)
└── Border Colors
    ├── Light (#E5E7EB)
    ├── Medium (#D1D5DB)
    └── Dark (#9CA3AF)
```

---

## 📐 Spacing & Layout System

```
Spacing Scale (pixel-based)
├── 4px → Micro spacing (badges, small gaps)
├── 8px → Small spacing (compact items)
├── 12px → Medium spacing (items in list)
├── 16px → Standard spacing (padding, margin)
├── 24px → Large spacing (section breaks)
└── 32px → Extra large spacing (major sections)

Common Patterns
├── Screen padding: 16px on all sides
├── Between sections: 24px
├── Between items: 12px
├── Inside cards: 12-16px
├── Between form fields: 16px

Layout Components
├── SizedBox(height: 16) → Vertical spacing
├── SizedBox(width: 8) → Horizontal spacing
├── Padding(16) → Container padding
├── EdgeInsets.symmetric(h: 16, v: 12) → Symmetric padding
└── EdgeInsets.only(...) → Custom padding
```

---

## 🎬 Animation Strategy

```
Component Animations
├── Button Tap
│   └── Scale: 1.0 → 0.95 (200ms, easeInOut)
├── Card Tap
│   └── Scale: 1.0 → 0.98 (200ms, easeInOut)
├── Fade In
│   └── Opacity: 0 → 1 (300ms)
└── Slide In
    └── Translate + Opacity (200-300ms)

Principles
├── Subtle animations only
├── Under 300ms duration
├── Use meaningful motion
└── Accessible (respect prefers-reduced-motion)
```

---

## 🔄 Component Lifecycle

```
Component Creation
    ↓
┌─────────────────────┐
│ initState (if State)│
│ • Setup controllers │
│ • Init listeners    │
│ • Load initial data │
└─────────────────────┘
    ↓
┌─────────────────────┐
│ build()             │
│ • Render UI         │
│ • Apply styling     │
│ • Handle state      │
└─────────────────────┘
    ↓
┌─────────────────────┐
│ User Interactions   │
│ • Tap, Type, Scroll │
│ • setState updates  │
└─────────────────────┘
    ↓
┌─────────────────────┐
│ dispose()           │
│ • Cleanup listeners │
│ • Dispose resources │
│ • Close streams     │
└─────────────────────┘
```

---

## 🚀 Performance Optimization

```
Build Optimization
├── Use const constructors where possible
├── Break widgets into smaller components
├── Use CustomPaint for complex UI
├── Avoid rebuilding in build()

List Optimization
├── Use ListView.builder for large lists
├── Use addAutomaticKeepAlives for cached items
├── Implement pagination/infinite scroll
├── Profile with DevTools

Animation Optimization
├── Use AnimationController with vsync
├── Avoid expensive computations in animation
├── Use RepaintBoundary for complex widgets

Memory Management
├── Dispose all controllers
├── Remove listeners in dispose
├── Use WeakReferences when needed
└── Profile with DevTools memory
```

---

## 🧪 Testing Architecture

```
Unit Tests
├── Component property tests
├── Color correctness
├── Text style correctness
└── Logic validation

Widget Tests
├── Component rendering
├── User interaction
├── State updates
└── Navigation

Integration Tests
├── Full screen flows
├── Form submission
├── Error handling
└── User journeys
```

---

## 📦 Deployment Checklist

```
Pre-Release
├── [ ] All components tested
├── [ ] Documentation updated
├── [ ] Examples verified
├── [ ] Code reviewed
├── [ ] Colors verified on device
├── [ ] Typography verified on device

Release
├── [ ] Version number updated
├── [ ] Changelog updated
├── [ ] Team notified
├── [ ] Documentation published

Post-Release
├── [ ] Monitor usage
├── [ ] Collect feedback
├── [ ] Fix issues
├── [ ] Plan next release
```

---

## 🔄 Update & Maintenance Cycle

```
Monthly Review
├── Collect feedback from developers
├── Monitor component usage
├── Identify pain points
└── Plan improvements

Quarterly Release
├── Bug fixes
├── Performance improvements
├── New components or features
└── Documentation updates

Yearly Overhaul
├── Major version updates
├── Design system refresh
├── Architecture improvements
└── Long-term planning
```

---

## 📊 Metrics & KPIs

```
Usage Metrics
├── % of screens using template
├── # of components per screen
├── Average component usage
└── Component adoption rate

Quality Metrics
├── # of bugs related to styling
├── Design consistency score
├── Accessibility compliance %
└── Performance score

Productivity Metrics
├── Development time per screen
├── Code review time
├── Onboarding time for new devs
└── Time to fix design issues
```

---

## 🎓 Knowledge Management

```
Documentation Tiers
├── Level 1: Overview (5 min read)
│   └── TEMPLATE_SUMMARY.md
├── Level 2: Quick Reference (10 min)
│   └── TEMPLATE_QUICK_REFERENCE.md
├── Level 3: Comprehensive (60 min)
│   └── TEMPLATE_GUIDE.md
└── Level 4: Deep Dive (120+ min)
    ├── Component source code
    ├── Implementation examples
    └── Architecture docs

Developer Onboarding
├── Day 1: Overview → Quick Reference
├── Day 2: First implementation
├── Day 3: Code review & feedback
└── Week 2: Independent development
```

---

**Created:** 27 November 2024
**Version:** 1.0.0
**Status:** Documentation Complete ✅
