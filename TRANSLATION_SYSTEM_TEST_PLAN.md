# Translation System Test Plan

## Database Setup Tests

### Test 1: Verify Database Table Structure
**Steps:**
1. Connect to PostgreSQL database
2. Query: `SELECT * FROM commodity_translations LIMIT 5;`
3. Verify columns: id, commodity_id, language_code, translated_name

**Expected Result:**
- Table exists
- Columns have correct types
- Unique constraint on (commodity_id, language_code)

### Test 2: Verify Sample Data
**Steps:**
1. Insert sample translations:
   ```sql
   INSERT INTO commodity_translations (commodity_id, language_code, translated_name) VALUES
   (1, 'ml', 'തക്കാളി'),
   (1, 'hi', 'टमाटर'),
   (2, 'ml', 'വെണ്ണ'),
   (2, 'hi', 'प्याज');
   ```
2. Verify data is inserted correctly

## Backend API Tests

### Test 3: Test Commodities Endpoint
**Endpoint:** `GET /commodities`

**Expected Response:**
```json
[
  {
    "id": 1,
    "name": "Tomato",
    "translations": [
      {
        "id": 1,
        "commodity_id": 1,
        "language_code": "ml",
        "translated_name": "തക്കാളി"
      },
      {
        "id": 2,
        "commodity_id": 1,
        "language_code": "hi",
        "translated_name": "टमाटर"
      }
    ]
  }
]
```

### Test 4: Test Mandi Prices with English Language
**Endpoint:** `GET /mandi-prices?language=en&page=1&page_size=10`

**Expected Response:**
- Each item contains both "commodity" (English) and "translated_name" (null for English)

### Test 5: Test Mandi Prices with Malayalam Language
**Endpoint:** `GET /mandi-prices?language=ml&page=1&page_size=10`

**Expected Response:**
- Each item contains "commodity" (English) and "translated_name" (Malayalam if available)

### Test 6: Test Mandi Prices Search with English Name
**Endpoint:** `GET /mandi-prices?commodity=tomato&language=en`

**Expected Result:**
- Returns results with "Tomato" commodity

### Test 7: Test Mandi Prices Search with Malayalam Name
**Endpoint:** `GET /mandi-prices?commodity=തക്കാളി&language=ml`

**Expected Result:**
- Returns results with Tomato (തക്കാളി)

### Test 8: Test Mandi Prices Search with Hindi Name
**Endpoint:** `GET /mandi-prices?commodity=टमाटर&language=hi`

**Expected Result:**
- Returns results with Tomato (टमाटर)

## Flutter Widget Tests

### Test 9: Test Home Screen Commodity Display
**Steps:**
1. Launch app in English locale
2. Navigate to Home Screen
3. View commodity cards

**Expected Result:**
- Commodity names displayed in English (e.g., "Tomato")

### Test 10: Test Home Screen with Malayalam Locale
**Steps:**
1. Change app language to Malayalam in settings
2. Navigate to Home Screen
3. View commodity cards

**Expected Result:**
- Commodity names displayed in Malayalam (e.g., "തക്കാളി")
- Cards remain clickable and functional

### Test 11: Test Home Screen with Hindi Locale
**Steps:**
1. Change app language to Hindi
2. Navigate to Home Screen
3. View commodity cards

**Expected Result:**
- Commodity names displayed in Hindi (e.g., "टमाटर")

### Test 12: Test Filter Results Screen
**Steps:**
1. In English: Apply filter for "Tomato"
2. Verify results show "Tomato" in commodity tag
3. Switch to Malayalam language
4. Results should show "തക്കാളി"

**Expected Result:**
- Filter results display correct language based on app locale
- Selection/filtering still works with IDs

### Test 13: Test Market Detail Screen
**Steps:**
1. In English: Click on a commodity card to open details
2. Verify title shows English name
3. Switch to Malayalam
4. Click another commodity
5. Title should show Malayalam name

**Expected Result:**
- Market detail header displays correct language
- Price chart and other details unaffected

### Test 14: Test Onboarding Screen - Crop Selection
**Steps:**
1. Open Onboarding Screen
2. In English: Open crop dropdown
3. Verify commodity names in English
4. Switch language to Malayalam
5. Verify commodity names in Malayalam
6. Select a crop and verify chip shows Malayalam name

**Expected Result:**
- Dropdown items show correct language
- Selected chip displays correct language
- Selection IDs remain unchanged

### Test 15: Test Profile Screen - Preferred Crops
**Steps:**
1. Go to Profile Screen
2. In English: View preferred crops
3. Should show English names
4. Switch to Malayalam
5. Refresh or re-navigate to Profile
6. Should show Malayalam names

**Expected Result:**
- Preferred crops display correct language
- No errors or missing displays

## Search Functionality Tests

### Test 16: Search in English
**Steps:**
1. In English locale
2. On Home or Filter screen
3. Search "tom" for "Tomato"

**Expected Result:**
- Results found for "Tomato"

### Test 17: Search in Malayalam
**Steps:**
1. In Malayalam locale
2. Search "തക്ക" for "തക്കാളി"

**Expected Result:**
- Results found for Tomato (മലയാളം)

### Test 18: Search in Hindi
**Steps:**
1. In Hindi locale
2. Search "टमा" for "टमाटर"

**Expected Result:**
- Results found for Tomato (हिन्दी)

### Test 19: Partial Search
**Steps:**
1. Search partial names like "मा" or "ട്ട"

**Expected Result:**
- Results found with partial matches

## Filtering Tests

### Test 20: Commodity Filter by ID
**Steps:**
1. Select a commodity from dropdown
2. Apply filter
3. Results show only that commodity
4. Switch language
5. Verify same commodity shown in new language

**Expected Result:**
- Filtering works correctly
- Display changes with language
- IDs remain consistent

### Test 21: Combined Filters
**Steps:**
1. Select multiple filters (state, district, commodity)
2. Verify each shows in correct language
3. Results filter correctly
4. Switch language
5. Verify filters still applied with new language

**Expected Result:**
- All filters work together
- Language change doesn't affect filtering

## Performance Tests

### Test 22: Load Time with Translations
**Steps:**
1. Load mandi prices page
2. Measure load time
3. Verify no N+1 queries
4. Check database query count

**Expected Result:**
- Fast load time
- Single or minimal database queries
- No performance degradation

### Test 23: Memory Usage
**Steps:**
1. Load app with translations
2. Monitor memory usage
3. Scroll through lists
4. Verify memory remains stable

**Expected Result:**
- Reasonable memory usage
- No memory leaks

## Edge Cases

### Test 24: Missing Translations
**Steps:**
1. For commodity with no Malayalam translation
2. Switch to Malayalam language
3. View in UI

**Expected Result:**
- Falls back to English name
- No errors or crashes

### Test 25: Unsupported Language
**Steps:**
1. Try to access translation for language 'xx' that doesn't exist
2. Backend should return null
3. UI shows English name

**Expected Result:**
- Graceful fallback to English
- No errors

### Test 26: Empty Translation Value
**Steps:**
1. Manually insert translation with empty translated_name
2. Query with that language

**Expected Result:**
- Either shows empty string or falls back to English
- No crashes

## Backwards Compatibility Tests

### Test 27: Existing Data
**Steps:**
1. Verify existing commodities still work
2. Verify existing filters still work
3. Verify existing favorites still work
4. Verify existing preferences still saved

**Expected Result:**
- No breaking changes
- All existing features work

### Test 28: API Response Format
**Steps:**
1. Check old mandi prices endpoint
2. Verify both "commodity" and "translated_name" present
3. Old clients can still work

**Expected Result:**
- API backwards compatible
- Old response fields still present

## Integration Tests

### Test 29: End-to-End Workflow in English
**Steps:**
1. Login
2. Complete onboarding with commodity selection in English
3. View home screen with commodities in English
4. Filter by commodity in English
5. View details in English

**Expected Result:**
- Complete workflow works
- All text in English

### Test 30: End-to-End Workflow with Language Change
**Steps:**
1. Complete workflow in English
2. Change language to Malayalam
3. Navigate back to screens
4. Verify all commodities now in Malayalam

**Expected Result:**
- Smooth language switching
- All updates correct

### Test 31: Language Persistence
**Steps:**
1. Change language to Malayalam
2. Close and reopen app
3. Verify language is still Malayalam

**Expected Result:**
- Language preference persisted
- App reopens in selected language

## Regression Tests

### Test 32: Authentication
**Steps:**
1. Login with credentials
2. Verify auth still works
3. Tokens still valid

**Expected Result:**
- Authentication unchanged
- No new auth issues

### Test 33: Profile Updates
**Steps:**
1. Update profile information
2. Verify updates saved correctly
3. No conflicts with translations

**Expected Result:**
- Profile updates work
- No data loss

### Test 34: Favorites
**Steps:**
1. If favorites feature exists
2. Add/remove favorites
3. Verify work correctly

**Expected Result:**
- Favorites work as before
- Translations don't affect ID-based operations

## Documentation Tests

### Test 35: API Documentation
**Steps:**
1. Review API docs
2. Verify language parameter documented
3. Verify response schema documents translations

**Expected Result:**
- Clear documentation
- Examples provided

### Test 36: UI Changes Documented
**Steps:**
1. Review UI changes
2. Screenshot comparison before/after
3. Document UI flow changes

**Expected Result:**
- Clear documentation of UI changes
- Guidelines for future features
