# Organization Verification Flow - Quick Testing Guide

## 🚀 How to Test the Complete Flow

### Step 1: Start the App
```bash
cd d:\Kuliah\Semester 5\TekBer\FP\BersatuBantu
flutter run
```

### Step 2: Navigate to Organization Verification
1. On role selection screen, tap **"Organisasi"** button
2. You should see organization login screen with "Hi! Good People" greeting

### Step 3: Organization Login Screen
**Visual Check:**
- ✅ Purple gradient background
- ✅ White rounded card with form
- ✅ Email/Password input fields
- ✅ "Ingat Saya" checkbox
- ✅ "Lupa Password?" link
- ✅ "Daftar" button visible

**Action:**
- Tap "Daftar" button → Should navigate to Step 1

---

## 📝 Step 1: Owner Data (Pemilik Organisasi)

### Visual Elements to Verify
- ✅ Back arrow button (top-left)
- ✅ Title: "Lengkapi Data"
- ✅ Two-column name inputs (Nama Depan, Nama Belakang)
- ✅ Phone number input
- ✅ Email input
- ✅ Progress dots: ● ○ ○ (1 filled, 2 empty)
- ✅ Buttons: "Keluar" (gray outline) | "Selanjutnya" (purple filled)

### Test Actions
1. Fill in all fields:
   - First Name: "John"
   - Last Name: "Doe"
   - Phone: "+62812345678"
   - Email: "john@example.com"
2. Tap "Selanjutnya" → Should go to Step 2
3. Tap "Kembali" (back arrow) → Should stay on Step 1
4. Tap "Keluar" → Should close verification flow

---

## 🏢 Step 2: Organization Data (Data Organisasi)

### Visual Elements to Verify
- ✅ Back arrow button
- ✅ Title: "Lengkapi Data Organisasi"
- ✅ Organization name input
- ✅ Organization phone input
- ✅ Organization email input
- ✅ Progress dots: ○ ● ○ (2 filled, 1 empty)
- ✅ Buttons: "Kembali" (gray outline) | "Selanjutnya" (purple filled)

### Test Actions
1. Fill in all fields:
   - Org Name: "PT Bantu Indonesia"
   - Org Phone: "+62212222222"
   - Org Email: "info@bantu.id"
2. Tap "Selanjutnya" → Should go to Step 3
3. Tap "Kembali" → Should go back to Step 1
4. Verify data from Step 1 is still there

---

## 📄 Step 3: Document Upload (Upload Dokumen)

### Visual Elements to Verify
- ✅ Back arrow button
- ✅ Title: "Upload Dokumen"
- ✅ Three document cards:
  - "Akta Pendirian Organisasi" (Akta .pdf)
  - "NPWP Organisasi" (NPWP .pdf)
  - "Surat Keterangan Domisili Sekretariat" (Surat Keterangan .pdf)
- ✅ Upload status icons (+ when pending, ✓ when uploaded)
- ✅ Progress dots: ○ ○ ● (3 filled, all completed)
- ✅ Buttons: "Kembali" (gray outline) | "Selanjutnya" (purple filled)

### Test Actions
1. Tap first document card:
   - Modal should appear with "Pilih dari Galeri" and "Pilih File" options
   - Tap either option
   - Should show success message and update icon to green checkmark
2. Repeat for other two documents
3. Tap "Selanjutnya" → Should go to Step 4
4. Tap "Kembali" → Should go back to Step 2

---

## ⏳ Step 4: Verification (Verifying)

### Visual Elements to Verify
- ✅ Full screen purple gradient background
- ✅ Centered mascot image (assets/bersatubantu.png)
- ✅ Image has scaling animation (grows/shrinks smoothly)
- ✅ Text: "Verifikasi Sedang Diproses..." or similar loading text
- ✅ No buttons visible (automatic progression)

### Behavior to Verify
- ✅ Animation plays smoothly
- ✅ After 3 seconds, automatically advances to Step 5
- ✅ If asset missing, should show fallback text

### Expected Action
- Wait ~3 seconds → Auto-transitions to Step 5

---

## ✨ Step 5: Success (Selesai)

### Visual Elements to Verify
- ✅ Full screen purple gradient background
- ✅ Back arrow button (top-left, white color)
- ✅ Centered mascot image with animation
- ✅ Title: "Yeay! Organisasi Anda Berhasil Terdaftar"
- ✅ White button "Masuk" with purple text
- ✅ Proper spacing and centering

### Test Actions
1. Tap back arrow → Should go back to Step 4 (verifying)
2. Tap "Masuk" button → Should navigate to home screen ('/home')

---

## 🔄 Navigation Flow Test

```
Organization Login
        ↓
   Step 1 ✓
        ↓
   Step 2 ✓
        ↓
   Step 3 ✓
        ↓
   Step 4 ✓ (3 sec auto-advance)
        ↓
   Step 5 ✓ → Home
```

**Test Sequence:**
1. ✅ Forward navigation (Selanjutnya buttons)
2. ✅ Backward navigation (Kembali buttons)
3. ✅ Back arrows work correctly
4. ✅ Data persists when navigating back/forward
5. ✅ Auto-transition on verifying screen

---

## 🎨 Color & Design Verification Checklist

### Colors
- [ ] Purple (#768BBD) used for:
  - Primary buttons
  - Progress dot (filled state)
  - Back arrow
  - Titles
  - Input field focus

- [ ] Gray (#999999) used for:
  - Secondary button text
  - Helper text
  - Input field borders

- [ ] Light Gray (#E0E0E0) used for:
  - Progress dots (empty state)
  - Card borders
  - Dividers

- [ ] Green (#4CAF50) used for:
  - Upload status checkmark

### Typography
- [ ] Titles are 24pt, bold
- [ ] Button text is 16pt, bold
- [ ] Labels are 14pt, bold
- [ ] Helper text is 12-13pt

### Spacing
- [ ] 24px top/bottom padding
- [ ] 12px between form fields
- [ ] 40px before button section
- [ ] 8px between inline elements

---

## 🧪 Edge Case Testing

### Test 1: Missing Asset
- [ ] Remove `assets/bersatubantu.png`
- [ ] Run verifying screen
- [ ] Should show fallback text instead of image
- [ ] Should not crash

### Test 2: Long Input Values
- [ ] Enter very long organization name
- [ ] Verify text wraps correctly
- [ ] Check button positioning

### Test 3: Special Characters
- [ ] Enter special characters in name fields
- [ ] Verify no crashes or display issues
- [ ] Check database storage

### Test 4: Network Errors
- [ ] Disable internet
- [ ] Try to submit documents
- [ ] Verify error handling
- [ ] Check error messages

### Test 5: Rapid Navigation
- [ ] Quickly tap back and next buttons
- [ ] Verify no data loss
- [ ] Check for animation glitches

---

## 📊 Performance Testing

### Animation Performance
- [ ] Verifying screen animation plays at 60 FPS
- [ ] No frame drops during transitions
- [ ] Smooth scaling animation

### Memory Usage
- [ ] Check memory doesn't leak on navigation
- [ ] Controllers properly disposed
- [ ] Listeners properly cleaned up

### Build Time
- [ ] First build completes in reasonable time
- [ ] Hot reload works without errors
- [ ] No compilation warnings

---

## ✅ Accessibility Testing

- [ ] All buttons have sufficient touch target (48x48 minimum)
- [ ] Text contrast is sufficient
- [ ] Form labels are clear and descriptive
- [ ] Error messages are visible and helpful
- [ ] Back navigation works for users who get lost

---

## 📱 Device Testing

Test on multiple devices:
- [ ] Phone (small screen)
- [ ] Tablet (large screen)
- [ ] Landscape orientation
- [ ] Light theme (if applicable)
- [ ] Dark theme (if applicable)

---

## 🐛 Bug Reporting Template

If you find an issue, note:
1. **Screen:** Which step/screen
2. **Action:** What you did
3. **Expected:** What should happen
4. **Actual:** What actually happened
5. **Reproduction:** Steps to reproduce
6. **Device:** Phone model, Android/iOS version
7. **Screenshot:** Visual proof

---

## ✅ Final Sign-Off Checklist

- [ ] All 5 screens render without errors
- [ ] Navigation between all screens works
- [ ] Data persists across navigation
- [ ] All buttons function correctly
- [ ] All animations play smoothly
- [ ] Progress indicators update correctly
- [ ] Colors match design mockup
- [ ] Typography matches specification
- [ ] No compilation errors
- [ ] No runtime errors
- [ ] App doesn't crash when navigating
- [ ] Asset loads or shows fallback
- [ ] Auto-transition on verifying works
- [ ] Final button navigates to home
- [ ] Ready for user testing

---

## 🆘 Troubleshooting

### Issue: Asset not loading
**Solution:** Check `pubspec.yaml` has:
```yaml
flutter:
  assets:
    - assets/bersatubantu.png
```

### Issue: Navigation not working
**Solution:** Check Provider is properly initialized in main.dart

### Issue: Progress dots wrong color
**Solution:** Verify color codes match #768BBD for filled, #E0E0E0 for empty

### Issue: Button text not visible
**Solution:** Check contrast ratio (dark text on light button)

### Issue: Auto-transition not working
**Solution:** Check that verifying_screen.dart has Future.delayed nextStep()

---

**Last Updated:** 2024
**Version:** 2.0
**Ready for Testing:** ✅ YES
