# 👁️ מדריך OCR עם LLaVA + Ollama

> **LLaVA = Large Language and Vision Assistant**  
> מודל AI שיכול לראות ולהבין תמונות!

## 🎯 מה אפשר לעשות?

### ✅ OCR (זיהוי טקסט בתמונות)
- קריאת טקסט מספרים, מסמכים
- תמלול כתב יד
- זיהוי טקסט עברי, אנגלי, ידיש

### ✅ תיאור תמונות
- "מה יש בתמונה הזו?"
- זיהוי אנשים, מקומות, אובייקטים
- הסבר מפורט של סצנות

### ✅ ניתוח מסמכים
- הבנת טבלאות ודוחות
- חילוץ מידע ממסמכים סרוקים
- סיכום תוכן חזותי

### ✅ עזרה בקידוד
- צילום מסך של קוד → הסבר
- תיקון באגים מצילום מסך
- המרת UI לקוד

---

## 📦 התקנת LLaVA

### שלב 1: הורד את המודל דרך GitHub Actions

1. בחר **llava-13b** ב-workflow
2. המתן ~15 דקות (2 קבצים: 8GB + 2GB)
3. הורד מ-Releases:
   - `llava-13b-q4.gguf` (המודל)
   - `llava-13b-mmproj.gguf` (מקרן הראייה)
   - `ollama-windows.exe` (אם עדיין לא הורדת)

### שלב 2: התקן במחשב

```powershell
# צור תיקייה
New-Item -ItemType Directory -Path "$HOME\ollama" -Force
cd "$HOME\ollama"

# העתק את שני הקבצים:
# - llava-13b-q4.gguf
# - llava-13b-mmproj.gguf
```

### שלב 3: צור Modelfile

צור קובץ `Modelfile-llava`:

```dockerfile
FROM ./llava-13b-q4.gguf
ADAPTER ./llava-13b-mmproj.gguf

PARAMETER temperature 0.7
PARAMETER num_ctx 4096

SYSTEM """אתה עוזר AI שיכול לראות ולהבין תמונות.
אתה מדבר עברית וא angלית.
תאר תמונות בפירוט, זהה טקסט, וענה על שאלות על התוכן החזותי."""
```

### שלב 4: צור את המודל ב-Ollama

```powershell
# הפעל את Ollama (חלון 1)
.\ollama-windows.exe serve

# חלון 2: צור את המודל
.\ollama-windows.exe create llava -f Modelfile-llava
```

✅ **מוכן!** עכשיו יש לך מודל ראייה.

---

## 🚀 שימוש ב-LLaVA

### OCR - קריאת טקסט מתמונה

```powershell
# שיטה 1: ישירות מהטרמינל
.\ollama-windows.exe run llava "מה הטקסט בתמונה?" image.jpg

# שיטה 2: אינטראקטיבי
.\ollama-windows.exe run llava
>>> מה כתוב בתמונה?
>>> (הוסף תמונה: גרור לטרמינל או שם הקובץ)
```

### תיאור תמונות

```powershell
.\ollama-windows.exe run llava "תאר מה אתה רואה" family_photo.jpg
```

### ניתוח טבלאות

```powershell
.\ollama-windows.exe run llava "חלץ את הנתונים מהטבלה" table_scan.png
```

---

## 🐍 Python API - OCR אוטומטי

### התקנה

```powershell
pip install ollama pillow
```

### קוד לOCR

```python
import ollama
from PIL import Image

def extract_text_from_image(image_path):
    """
    מחלץ טקסט מתמונה באמצעות LLaVA
    """
    response = ollama.chat(
        model='llava',
        messages=[{
            'role': 'user',
            'content': 'קרא את כל הטקסט שאתה רואה בתמונה. החזר רק את הטקסט, ללא הסברים.',
            'images': [image_path]
        }]
    )
    
    return response['message']['content']

# שימוש
text = extract_text_from_image('document.jpg')
print(text)
```

### OCR לעברית + תרגום

```python
def ocr_hebrew_with_translation(image_path):
    """
    OCR לעברית עם תרגום לאנגלית
    """
    response = ollama.chat(
        model='llava',
        messages=[{
            'role': 'user',
            'content': '''קרא את הטקסט העברי בתמונה.
            החזר בפורמט:
            עברית: <הטקסט בעברית>
            English: <translation to English>
            ''',
            'images': [image_path]
        }]
    )
    
    return response['message']['content']

# שימוש
result = ocr_hebrew_with_translation('hebrew_doc.jpg')
print(result)
```

### ניתוח מסמך מורכב

```python
def analyze_document(image_path):
    """
    ניתוח מסמך: זיהוי סוג, חילוץ מידע
    """
    response = ollama.chat(
        model='llava',
        messages=[{
            'role': 'user',
            'content': '''נתח את המסמך בתמונה:
            1. סוג המסמך (חשבונית, טופס, מכתב, וכו')
            2. שדות חשובים (תאריך, סכומים, שמות)
            3. תוכן עיקרי
            
            החזר בפורמט JSON.
            ''',
            'images': [image_path]
        }]
    )
    
    return response['message']['content']
```

### OCR אצווה (Batch)

```python
import os

def batch_ocr(folder_path, output_file='ocr_results.txt'):
    """
    OCR לכל התמונות בתיקייה
    """
    results = []
    
    for filename in os.listdir(folder_path):
        if filename.lower().endswith(('.png', '.jpg', '.jpeg', '.bmp')):
            image_path = os.path.join(folder_path, filename)
            print(f"Processing: {filename}")
            
            text = extract_text_from_image(image_path)
            results.append(f"\n=== {filename} ===\n{text}\n")
    
    # שמירה לקובץ
    with open(output_file, 'w', encoding='utf-8') as f:
        f.writelines(results)
    
    print(f"Saved to {output_file}")
    return results

# שימוש
batch_ocr('C:/scanned_docs')
```

---

## 🔧 שימושים מתקדמים

### 1. OCR + חיפוש במסמכים

```python
def search_in_scanned_docs(folder_path, search_term):
    """
    חיפוש מילה במסמכים סרוקים
    """
    matches = []
    
    for filename in os.listdir(folder_path):
        if filename.lower().endswith(('.png', '.jpg', '.jpeg')):
            image_path = os.path.join(folder_path, filename)
            text = extract_text_from_image(image_path)
            
            if search_term.lower() in text.lower():
                matches.append({
                    'file': filename,
                    'text': text
                })
    
    return matches

# דוגמה: מצא מסמכים שמזכירים "חשבונית"
results = search_in_scanned_docs('C:/docs', 'חשבונית')
for r in results:
    print(f"Found in: {r['file']}")
```

### 2. המרת כתב יד לדיגיטלי

```python
def handwriting_to_text(image_path):
    """
    המרת כתב יד לטקסט דיגיטלי
    """
    response = ollama.chat(
        model='llava',
        messages=[{
            'role': 'user',
            'content': 'קרא את הכתב יד בתמונה. תמלל אותו במדויק.',
            'images': [image_path]
        }]
    )
    
    return response['message']['content']
```

### 3. זיהוי טבלאות ויצוא ל-Excel

```python
import pandas as pd
import json

def table_to_excel(image_path, output_excel='output.xlsx'):
    """
    חילוץ טבלה מתמונה ויצוא ל-Excel
    """
    response = ollama.chat(
        model='llava',
        messages=[{
            'role': 'user',
            'content': '''חלץ את הטבלה מהתמונה.
            החזר בפורמט JSON עם שדות:
            {
              "headers": ["עמודה1", "עמודה2", ...],
              "rows": [["ערך1", "ערך2", ...], ...]
            }
            ''',
            'images': [image_path]
        }]
    )
    
    # המרה ל-DataFrame
    data = json.loads(response['message']['content'])
    df = pd.DataFrame(data['rows'], columns=data['headers'])
    
    # יצוא ל-Excel
    df.to_excel(output_excel, index=False)
    print(f"Saved to {output_excel}")
    
    return df
```

### 4. OCR למערכת IVR

```python
def process_id_card(image_path):
    """
    חילוץ מידע מתעודת זהות
    """
    response = ollama.chat(
        model='llava',
        messages=[{
            'role': 'user',
            'content': '''חלץ מידע מתעודת הזהות:
            - שם פרטי
            - שם משפחה
            - מספר זהות
            - תאריך לידה
            - כתובת
            
            החזר JSON עם השדות האלה.
            ''',
            'images': [image_path]
        }]
    )
    
    return json.loads(response['message']['content'])

# שילוב במערכת
id_data = process_id_card('id_scan.jpg')
print(f"שם: {id_data['first_name']} {id_data['last_name']}")
print(f"ת.ז: {id_data['id_number']}")
```

---

## 🌐 API Server ל-OCR

### יצירת שרת OCR

```python
from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse
import ollama
import tempfile

app = FastAPI(title="LLaVA OCR Server")

@app.post("/ocr")
async def ocr_endpoint(file: UploadFile = File(...)):
    """
    Endpoint ל-OCR
    """
    # שמירה זמנית
    with tempfile.NamedTemporaryFile(delete=False, suffix='.jpg') as tmp:
        tmp.write(await file.read())
        tmp_path = tmp.name
    
    # OCR
    response = ollama.chat(
        model='llava',
        messages=[{
            'role': 'user',
            'content': 'קרא את הטקסט בתמונה',
            'images': [tmp_path]
        }]
    )
    
    return JSONResponse({
        'text': response['message']['content'],
        'filename': file.filename
    })

@app.post("/describe")
async def describe_endpoint(file: UploadFile = File(...)):
    """
    תיאור תמונה
    """
    with tempfile.NamedTemporaryFile(delete=False, suffix='.jpg') as tmp:
        tmp.write(await file.read())
        tmp_path = tmp.name
    
    response = ollama.chat(
        model='llava',
        messages=[{
            'role': 'user',
            'content': 'תאר בפירוט מה בתמונה',
            'images': [tmp_path]
        }]
    )
    
    return JSONResponse({
        'description': response['message']['content']
    })

# הפעלה:
# uvicorn ocr_server:app --host 0.0.0.0 --port 8001
```

### שימוש ב-API

```python
import requests

# OCR
files = {'file': open('document.jpg', 'rb')}
response = requests.post('http://10.0.0.116:8001/ocr', files=files)
print(response.json()['text'])

# תיאור
files = {'file': open('photo.jpg', 'rb')}
response = requests.post('http://10.0.0.116:8001/describe', files=files)
print(response.json()['description'])
```

---

## 📊 השוואת מודלים ל-OCR

| מודל | גודל | מהירות | דיוק OCR | תיאור תמונות | עברית |
|------|------|---------|----------|--------------|-------|
| **LLaVA 13B** | 10GB | בינוני | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| LLaVA 7B | 6GB | מהיר | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ |
| LLaVA 34B | 20GB | איטי | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |

**המלצה:** LLaVA 13B - מאוזן מצוין

---

## ⚡ טיפים לביצועים

### 1. הכן תמונות
```python
from PIL import Image

def optimize_image_for_ocr(input_path, output_path):
    """
    אופטימיזציה של תמונה ל-OCR
    """
    img = Image.open(input_path)
    
    # המרה לשחור-לבן (משפר OCR)
    img = img.convert('L')
    
    # שינוי גודל (מקסימום 1024px)
    img.thumbnail((1024, 1024))
    
    # שמירה
    img.save(output_path, quality=95)
    
optimize_image_for_ocr('scan.jpg', 'scan_optimized.jpg')
```

### 2. Batch processing מקביל
```python
from concurrent.futures import ThreadPoolExecutor

def parallel_ocr(image_paths, max_workers=4):
    """
    OCR מקביל למספר תמונות
    """
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        results = executor.map(extract_text_from_image, image_paths)
    return list(results)

# עיבוד 100 תמונות במקביל
images = [f'scan_{i}.jpg' for i in range(100)]
texts = parallel_ocr(images)
```

---

## 🎯 סיכום

**עם LLaVA + Ollama יש לך:**

✅ **OCR מתקדם** - קריאת טקסט מכל תמונה  
✅ **תיאור תמונות** - AI מבין מה בתמונה  
✅ **ניתוח מסמכים** - חילוץ מידע ממסמכים סרוקים  
✅ **API מקומי** - ללא תלות באינטרנט  
✅ **חינמי** - אין עלויות  
✅ **פרטי** - הכל במחשב שלך  

**זה מתאים למערכת ה-IVR שלך:**
- סריקת תעודות זהות
- קריאת מסמכים
- ארכוב אוטומטי של ניירות
- תמלול כתבי יד

---

**בהצלחה עם ה-OCR! 👁️✨**
