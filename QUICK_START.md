# 🚀 הוראות התקנה מהירות

## תהליך פשוט ב-3 שלבים

### 📋 מה שאתה צריך:
1. חשבון GitHub (חינמי)
2. 5-10 דקות זמן
3. המחשב שלך (Windows)

---

## שלב 1️⃣: צור GitHub Token (פעם אחת בלבד)

### א. היכנס ל-GitHub
1. לך ל: https://github.com/settings/tokens/new
2. התחבר אם צריך

### ב. הגדרות Token
```
Name: Ollama Downloader
Expiration: 90 days
Select scopes:
  ✅ repo (סמן את כל ה-checkbox)
  ✅ workflow
```

### ג. צור ושמור
1. לחץ **Generate token** (בתחתית)
2. **העתק את ה-Token** (ghp_xxxxxxxxxxxx)
3. שמור אותו - לא תראה אותו שוב!

### ד. שמור ב-PowerShell
```powershell
# פתח PowerShell והרץ (החלף את YOUR_TOKEN):
[Environment]::SetEnvironmentVariable("GITHUB_TOKEN", "ghp_xxxxxxxxxxxx", "User")

# בדוק שנשמר:
$env:GITHUB_TOKEN
```

✅ **Token מוכן!** עכשיו תוכל להעלות פרויקטים אוטומטית.

---

## שלב 2️⃣: העלה את הפרויקט ל-GitHub

### א. פתח PowerShell בתיקיית הפרויקט
```powershell
cd C:\Users\Koperberg\ollama-github-project
```

### ב. הרץ את סקריפט ההעלאה
```powershell
.\upload_to_github.ps1 -Username "YOUR_GITHUB_USERNAME"
```

**דוגמה:**
```powershell
.\upload_to_github.ps1 -Username "koperberg"
```

### ג. השלם את השאלות
- **Email:** האימייל שלך ב-GitHub
- **Continue?** הקלד `Y` ואנטר

### ד. ההעלאה תתחיל!
```
✅ Git מותקן
✅ Token: ghp_xxx...xxx
✅ Repository נוצר
✅ קבצים הועלו
```

⏱️ **זה לוקח 30 שניות**

---

## שלב 3️⃣: הורד את המודל דרך GitHub Actions

### א. פתח את ה-Repository
```
https://github.com/YOUR_USERNAME/ollama-downloader
```

או שהסקריפט יפתח אוטומטית

### ב. אפשר Actions
1. לחץ על טאב **Actions** (למעלה)
2. כפתור ירוק: **I understand my workflows, go ahead and enable them**

### ג. הרץ Workflow
1. בצד שמאל: **Download Ollama Models**
2. כפתור ימני: **Run workflow**
3. תפתח תפריט:
   - Model: בחר `mistral` (או אחר)
   - לחץ **Run workflow** (כפתור ירוק למטה)

### ד. המתן להורדה
- ⏱️ **5-15 דקות** (תלוי במודל)
- תראה סטטוס:
  - 🟡 צהוב = מוריד
  - ✅ ירוק = הצליח
  - ❌ אדום = נכשל (לחץ לראות שגיאה)

### ה. הורד את הקבצים
1. לחץ על טאב **Releases** (בצד ימין)
2. לחץ על ה-Release האחרון
3. בקטע **Assets** תראה:
   - `mistral-7b-q4.gguf` (4.1GB) - המודל
   - `mistral-7b-q4.gguf.sha256` - Checksum
   - `ollama-windows.exe` - Ollama
4. **לחץ להוריד** - זה יוריד למחשב שלך!

---

## שלב 4️⃣: הפעל במחשב שלך

### א. הכן תיקייה
```powershell
New-Item -ItemType Directory -Path "$HOME\ollama" -Force
cd "$HOME\ollama"
```

### ב. העבר קבצים
- העתק את 3 הקבצים שהורדת לתיקייה `C:\Users\Koperberg\ollama`

### ג. הפעל Ollama
```powershell
# טרמינל 1: הפעל שרת
.\ollama-windows.exe serve
```

### ד. השתמש במודל
```powershell
# טרמינל 2: הרץ מודל
cd C:\Users\Koperberg\ollama
.\ollama-windows.exe run mistral
```

### ה. נסה!
```powershell
# שאל שאלה:
.\ollama-windows.exe run mistral "מה זה Python?"
```

---

## 🎉 סיימת!

עכשיו יש לך:
- ✅ Ollama רץ על המחשב
- ✅ מודל AI לוקלי
- ✅ ללא צורך באינטרנט (אחרי ההורדה)
- ✅ חינמי לחלוטין
- ✅ פרטי (הכל במחשב שלך)

---

## 💡 שימושים נוספים

### הרצה על שרת (10.0.0.116)
```powershell
# בשרת:
$env:OLLAMA_HOST = "0.0.0.0:11434"
.\ollama-windows.exe serve

# במחשב אחר:
curl http://10.0.0.116:11434/api/generate -d '{"model":"mistral","prompt":"שלום"}'
```

### שילוב עם Python
```python
import requests

response = requests.post('http://localhost:11434/api/generate',
    json={
        'model': 'mistral',
        'prompt': 'מה זה Ollama?',
        'stream': False
    })
print(response.json()['response'])
```

### הורדת מודלים נוספים
- חזור לשלב 3 והרץ Workflow שוב
- בחר מודל אחר (llama3, gemma2, phi3)
- כל מודל יהיה Release נפרד

---

## ❓ שאלות נפוצות

### כמה זה עולה?
**חינמי לגמרי!** GitHub Actions נותן 2000 דקות חינם בחודש.

### GitHub חסום אצלי?
נסה:
1. Hotspot מהטלפון
2. VPN חינמי (ProtonVPN)
3. הורד במחשב אחר והעבר USB

### המודל לא עובד?
```powershell
# בדוק שהקובץ שלם:
Get-FileHash mistral-7b-q4.gguf -Algorithm SHA256
# השווה לקובץ .sha256
```

### רוצה מודל גדול יותר?
- llama3:70b - 40GB (דורש 64GB RAM)
- mixtral:8x7b - 26GB (דורש 32GB RAM)

**השרת שלך (65GB RAM) יכול!**

---

## 📞 עזרה

תקוע? 
1. פתח Issue ב-https://github.com/YOUR_USERNAME/ollama-downloader/issues
2. שאל ב-Discord של Ollama
3. או שאל אותי! 😊

---

**בהצלחה! 🚀**

*עוקף NetFree ומוריד AI בקלות*
