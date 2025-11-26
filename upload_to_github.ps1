#!/usr/bin/env pwsh
<#
.SYNOPSIS
    העלאת הפרויקט ל-GitHub
    
.DESCRIPTION
    סקריפט אוטומטי להעלאת כל הקבצים ל-GitHub
    
.EXAMPLE
    .\upload_to_github.ps1 -Username "YourGitHubUsername"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Username,
    
    [Parameter(Mandatory=$false)]
    [string]$RepoName = "ollama-downloader",
    
    [Parameter(Mandatory=$false)]
    [string]$Email
)

$ErrorActionPreference = "Stop"

# צבעים
function Write-Title { param([string]$Text) Write-Host "`n$Text" -ForegroundColor Cyan }
function Write-Success { param([string]$Text) Write-Host "✅ $Text" -ForegroundColor Green }
function Write-Warning { param([string]$Text) Write-Host "⚠️  $Text" -ForegroundColor Yellow }
function Write-Error-Custom { param([string]$Text) Write-Host "❌ $Text" -ForegroundColor Red }
function Write-Step { param([string]$Text) Write-Host "`n🔹 $Text" -ForegroundColor Yellow }

Write-Host @"

╔═══════════════════════════════════════════════════════════╗
║                                                             ║
║          📤 GitHub Project Uploader 📤                     ║
║                                                             ║
╚═══════════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan

# בדיקת Git
Write-Step "בודק התקנת Git..."
try {
    $gitVersion = git --version
    Write-Success "Git מותקן: $gitVersion"
} catch {
    Write-Error-Custom "Git לא מותקן!"
    Write-Host "`nהתקן Git מכאן: https://git-scm.com/download/win"
    exit 1
}

# בדיקת GitHub Token
Write-Step "בודק GitHub Token..."
$token = $env:GITHUB_TOKEN

if (-not $token) {
    Write-Warning "GITHUB_TOKEN לא מוגדר!"
    Write-Host @"
    
📋 יצירת GitHub Token:

1. לך ל: https://github.com/settings/tokens/new
2. שם: Ollama Downloader
3. תוקף: 90 days
4. הרשאות:
   ✅ repo (כל ה-checkbox)
   ✅ workflow
5. לחץ Generate token
6. העתק את ה-token (ghp_xxxx)

"@
    
    $token = Read-Host "הדבק את ה-Token שלך"
    
    if (-not $token) {
        Write-Error-Custom "Token חובה!"
        exit 1
    }
    
    # שמור לעתיד
    [Environment]::SetEnvironmentVariable("GITHUB_TOKEN", $token, "User")
    Write-Success "Token נשמר!"
}

$tokenPreview = $token.Substring(0, 7) + "..." + $token.Substring($token.Length - 4)
Write-Success "Token: $tokenPreview"

# הגדרות Git
Write-Step "מגדיר Git..."

if (-not $Email) {
    $Email = Read-Host "מה האימייל שלך ב-GitHub?"
}

git config --global user.name $Username
git config --global user.email $Email
Write-Success "Git מוגדר: $Username <$Email>"

# אתחול Repository
Write-Step "מאתחל Git repository..."

if (Test-Path ".git") {
    Write-Warning "Repository כבר קיים, ממשיך..."
} else {
    git init
    Write-Success "Git initialized"
}

# הוספת Remote
Write-Step "מוסיף GitHub remote..."

$remoteUrl = "https://${token}@github.com/${Username}/${RepoName}.git"

try {
    git remote remove origin 2>$null
} catch {}

git remote add origin $remoteUrl
Write-Success "Remote נוסף: ${Username}/${RepoName}"

# בדיקת קבצים
Write-Step "בודק קבצים..."

$requiredFiles = @(
    ".github\workflows\download-ollama.yml",
    "README.md"
)

$missing = @()
foreach ($file in $requiredFiles) {
    if (-not (Test-Path $file)) {
        $missing += $file
    }
}

if ($missing.Count -gt 0) {
    Write-Error-Custom "חסרים קבצים:"
    $missing | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    Write-Host "`nהעתק אותם לתיקייה הנוכחית ונסה שוב"
    exit 1
}

Write-Success "כל הקבצים קיימים!"

# הצגת רשימת קבצים
Write-Host "`n📁 קבצים שיועלו:"
Get-ChildItem -Recurse -File | Where-Object { $_.FullName -notmatch '\.git' } | ForEach-Object {
    Write-Host "  - $($_.FullName.Replace($PWD, '.'))" -ForegroundColor Gray
}

# אישור
Write-Host ""
$confirm = Read-Host "להעלות את הקבצים ל-GitHub? (Y/N)"

if ($confirm -ne 'Y' -and $confirm -ne 'y') {
    Write-Warning "בוטל על ידי המשתמש"
    exit 0
}

# הוספת כל הקבצים
Write-Step "מוסיף קבצים ל-Git..."
git add .
Write-Success "קבצים נוספו"

# Commit
Write-Step "יוצר commit..."
$commitMessage = "Initial commit: Ollama offline downloader"
git commit -m $commitMessage
Write-Success "Commit נוצר"

# בדיקה אם Repository קיים
Write-Step "בודק אם Repository קיים ב-GitHub..."

try {
    $headers = @{
        "Authorization" = "token $token"
        "Accept" = "application/vnd.github.v3+json"
    }
    
    $response = Invoke-RestMethod -Uri "https://api.github.com/repos/${Username}/${RepoName}" -Headers $headers -Method Get
    Write-Success "Repository קיים: ${Username}/${RepoName}"
} catch {
    Write-Warning "Repository לא קיים, יוצר..."
    
    try {
        $body = @{
            name = $RepoName
            description = "Ollama offline downloader via GitHub Actions - עוקף NetFree"
            private = $false
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri "https://api.github.com/user/repos" -Headers $headers -Method Post -Body $body -ContentType "application/json"
        Write-Success "Repository נוצר!"
    } catch {
        Write-Error-Custom "נכשל ביצירת Repository: $($_.Exception.Message)"
        Write-Host "`nצור repository ידנית:"
        Write-Host "1. לך ל: https://github.com/new"
        Write-Host "2. שם: $RepoName"
        Write-Host "3. Public"
        Write-Host "4. אל תוסיף README"
        Write-Host "5. Create repository"
        exit 1
    }
}

# Push
Write-Step "מעלה ל-GitHub..."

try {
    git branch -M main
    git push -u origin main --force
    Write-Success "הועלה בהצלחה!"
} catch {
    Write-Error-Custom "העלאה נכשלה!"
    Write-Host "`nנסה:"
    Write-Host "git push -u origin main --force"
    exit 1
}

# סיכום
Write-Host @"

╔═══════════════════════════════════════════════════════════╗
║                                                             ║
║          ✅ הועלה בהצלחה! ✅                               ║
║                                                             ║
╚═══════════════════════════════════════════════════════════╝

🔗 Repository שלך:
   https://github.com/${Username}/${RepoName}

📋 צעדים הבאים:

1. לך ל-Repository:
   https://github.com/${Username}/${RepoName}

2. לחץ על Actions (טאב עליון)

3. אפשר Actions:
   "I understand my workflows, go ahead and enable them"

4. בחר "Download Ollama Models"

5. לחץ "Run workflow"

6. בחר מודל (mistral/llama3/gemma2/phi3)

7. לחץ "Run workflow" (כפתור ירוק)

8. המתן 5-15 דקות ⏱️

9. לך ל-Releases ותראה את הקבצים להורדה! 📦

"@ -ForegroundColor Green

# פתיחת דפדפן
$openBrowser = Read-Host "`nלפתוח את GitHub בדפדפן? (Y/N)"
if ($openBrowser -eq 'Y' -or $openBrowser -eq 'y') {
    Start-Process "https://github.com/${Username}/${RepoName}"
}

Write-Host "`n✨ בהצלחה! ✨`n" -ForegroundColor Cyan
