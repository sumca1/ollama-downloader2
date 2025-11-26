# ollama-downloader2
# 🦙 Ollama Offline Downloader

> הורדת מודלי Ollama דרך GitHub Actions - **עוקף NetFree וחסימות אחרות**

## 🎯 למה זה נחוץ?

אם אתה מאחורי **NetFree**, **חומת אש ארגונית**, או **חסימת אינטרנט**:
- ❌ `ollama.ai` חסום
- ❌ `huggingface.co` חסום
- ❌ הורדה ישירה לא עובדת

**הפתרון:**  
GitHub Actions מוריד את הקבצים בשבילך (על שרתי GitHub ללא חסימות),  
ואתה מוריד מ-GitHub Releases (בדרך כלל לא חסום)! 🚀

---

## 📋 מה זה עושה?

1. **אתה:** לוחץ כפתור "Run workflow" ב-GitHub
2. **GitHub Actions:** מוריד מודל ענק מ-HuggingFace (על שרתי GitHub)
3. **GitHub Actions:** מעלה אותו ל-Releases שלך
4. **אתה:** מוריד מ-Releases ישירות למחשב 💾

---

## 🚀 התחלה מהירה

### שלב 1️⃣: Fork את ה-Repository

1. לחץ על **Fork** (פינה ימנית עליונה)
2. זה יוצר עותק שלך מהפרויקט

### שלב 2️⃣: הפעל את GitHub Actions

1. לך לטאב **Actions** ב-repository שלך
2. לחץ **I understand my workflows, go ahead and enable them**
3. בחר **Download Ollama Models** מהרשימה
4. לחץ **Run workflow** (כפתור ימני)
5. בחר מודל:
   - `mistral` - מומלץ למתחילים (4.1GB)
   - `llama3` - הכי טוב לעברית (4.7GB)
   - `gemma2` - קטן ומהיר (1.6GB)
   - `phi3` - Microsoft (2.3GB)
6. לחץ **Run workflow** (כפתור ירוק)

### שלב 3️⃣: המתן להורדה

- ⏱️ **ההורדה לוקחת 5-15 דקות** (תלוי במודל)
- תראה ✅ ירוק כשמוכן
- אם יש ❌ אדום - לחץ עליו לראות מה הבעיה

### שלב 4️⃣: הורד את הקבצים

1. לך לטאב **Releases** (בצד ימין)
2. לחץ על ה-Release האחרון
3. בקטע **Assets** תראה:
   - 📦 `mistral-7b-q4.gguf` - המודל
   - 🔒 `mistral-7b-q4.gguf.sha256` - Checksum
   - 💻 `ollama-windows.exe` - Ollama
4. הורד את כל הקבצים למחשב שלך

---

## 💻 התקנה במחשב Windows

### שלב 1: הכן תיקייה
```powershell
# פתח PowerShell והרץ:
New-Item -ItemType Directory -Path "$HOME\ollama" -Force
cd "$HOME\ollama"

# העבר את הקבצים שהורדת לתיקייה הזו
```

### שלב 2: הפעל את Ollama
```powershell
# הפעל את Ollama (שרת רקע)
.\ollama-windows.exe serve
```

### שלב 3: טען מודל (בחלון PowerShell נפרד)
```powershell
cd "$HOME\ollama"

# העתק את המודל למיקום הנכון
$ollamaModelsDir = "$env:USERPROFILE\.ollama\models\blobs"
New-Item -ItemType Directory -Path $ollamaModelsDir -Force

# העתק את הקובץ
Copy-Item "mistral-7b-q4.gguf" "$ollamaModelsDir\sha256-xxxxx"

# או פשוט הרץ ישירות
.\ollama-windows.exe run mistral
```

### שלב 4: נסה!
```powershell
# שאל שאלה
.\ollama-windows.exe run mistral "מה זה Python?"
```

---

## 🔧 שימוש מתקדם

### הרצה על שרת מרוחק (10.0.0.116)

```powershell
# הגדר Ollama לקבל בקשות מהרשת
$env:OLLAMA_HOST = "0.0.0.0:11434"
.\ollama-windows.exe serve
```

### גישה מכל מחשב ברשת
```python
import requests

response = requests.post('http://10.0.0.116:11434/api/generate',
    json={
        'model': 'mistral',
        'prompt': 'שלום עולם!',
        'stream': False
    })
print(response.json()['response'])
```

### יצירת שירות Windows (לרוץ תמיד)

צור קובץ `ollama-service.bat`:
```batch
@echo off
set OLLAMA_HOST=0.0.0.0:11434
C:\Users\Koperberg\ollama\ollama-windows.exe serve
```

הרץ אותו כ-Startup Task או עם NSSM.

---

## 📊 מודלים זמינים (מעודכן למודלים איכותיים!)

### 🏆 מודלים מומלצים

| מודל | גודל | זמן* | תיאור | שימוש |
|------|------|------|--------|-------|
| **llama3.1-70b** 🏆 | 40GB | ~60 דקות | **הכי חזק** | עברית מצוינת, IVR, שידוכים |
| **mixtral-8x7b** ⚡ | 26GB | ~40 דקות | 8 מומחים | מהיר+חכם, רב תחומי |
| **llava-13b** 👁️ | 10GB | ~20 דקות | **ראייה AI** | OCR, תמונות, מסמכים |
| **codellama-34b** 💻 | 20GB | ~30 דקות | תכנות | כתיבת קוד מתקדם |
| **qwen2.5-72b** 🌏 | 42GB | ~65 דקות | סיני מתקדם | רב לשוני, עברית+סינית |
| **deepseek-coder-33b** 🚀 | 19GB | ~30 דקות | GPT-4 לקוד | אלגוריתמים מורכבים |
| **llama3.1-8b** ⚖️ | 4.9GB | ~10 דקות | מאוזן | התחלה מומלצת |
| **mistral-7b** 🏃 | 4.1GB | ~8 דקות | קל | בדיקות מהירות |

*זמן הורדה ב-GitHub Actions (לא במחשב שלך)

### 💡 איזה מודל לבחור?

**יש לך 65GB RAM (כמו השרת שלך):**
- ✅ תוכל להריץ את **כל המודלים!**
- ✅ אפילו כמה מודלים **במקביל!**
- 🏆 מומלץ: **llama3.1-70b** + **llava-13b**

**למערכת IVR + שידוכים:**
```powershell
# הכי טוב - אם יש זמן
ollama-downloader → בחר llama3.1-70b

# מהיר ואיכותי
ollama-downloader → בחר mixtral-8x7b
```

**ל-OCR וניתוח תמונות:**
```powershell
# חובה למי שצריך OCR!
ollama-downloader → בחר llava-13b
# ראה מדריך מפורט: OCR_GUIDE.md
```

**לתכנות:**
```powershell
# הכי טוב לקוד
ollama-downloader → בחר deepseek-coder-33b
```

---

## ❓ פתרון בעיות

### ❌ GitHub Actions נכשל
**בדוק:**
1. Actions מופעל? (Settings → Actions → Allow all actions)
2. Repository הוא Public? (חייב להיות Public)
3. יש מקום? (GitHub נותן 2GB אחסון חינם)

**פתרון:**  
לחץ על ❌ האדום → ראה את השגיאה → Google אותה

### 📦 Ollama לא עובד
```powershell
# בדוק שהוא רץ
Get-Process ollama

# אם לא - הפעל מחדש
.\ollama-windows.exe serve
```

### 🔒 NetFree חוסם גם GitHub?
1. נסה דרך **Hotspot של הטלפון**
2. או: הורד במחשב אחר והעבר ב-USB
3. או: בקש אישור זמני מנטפרי ל-`github.com`

---

## 🔐 אבטחה והרשאות

### למה צריך GITHUB_TOKEN?
- ה-Actions צריך להעלות קבצים ל-Releases
- GitHub מספק את זה אוטומטית
- **אין צורך ליצור Token ידנית!** (זה נוצר אוטומטית)

### האם זה בטוח?
- ✅ הכל רץ על שרתי GitHub (לא במחשב שלך)
- ✅ הקוד פתוח - תוכל לראות מה הוא עושה
- ✅ אין סיסמאות או מידע פרטי

---

## 📈 שדרוגים עתידיים

- [ ] תמיכה במודלים נוספים (70B, mixtral)
- [ ] פיצול קבצים גדולים (עוקף מגבלת 2GB של GitHub)
- [ ] הורדה ישירה ל-Google Drive / OneDrive
- [ ] UI ידידותי במקום GitHub

---

## 💡 טיפים

### חיסכון במקום:
```powershell
# מחק release ישן אחרי שהורדת
# Settings → Releases → Delete
```

### ריבוי מודלים:
```powershell
# הרץ workflow מספר פעמים עם מודלים שונים
# כל מודל יהיה Release נפרד
```

### גיבוי:
```powershell
# גבה את המודלים
Copy-Item -Recurse "$HOME\ollama" "I:\Backups\ollama_$(Get-Date -F 'yyyy-MM-dd')"
```

---

## 🤝 תרומה

מצאת bug? יש רעיון לשיפור?
1. פתח **Issue**
2. או עשה **Pull Request**
3. או כתוב ב-**Discussions**

---

## 📜 רישיון

MIT License - חופשי לשימוש, שינוי והפצה

---

## 🙏 תודות

- [Ollama](https://ollama.ai) - הפרויקט המקורי
- [HuggingFace](https://huggingface.co) - אחסון המודלים
- [GitHub Actions](https://github.com/features/actions) - התשתית

---

## 📞 עזרה

תקוע? שאל:
1. פתח **Issue** בפרויקט הזה
2. [Ollama Discord](https://discord.gg/ollama)
3. [Stack Overflow](https://stackoverflow.com/questions/tagged/ollama)

---

**בהצלחה! 🎉**

*הורד AI לוקלי גם מאחורי חומת אש* 🔥🚀
