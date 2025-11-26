#!/usr/bin/env pwsh
<#
.SYNOPSIS
    בודק סטטוס GitHub Actions ללא לוגים (עובד עם NetFree)

.DESCRIPTION
    NetFree חוסם לוגים, אבל אפשר לבדוק סטטוס דרך GitHub API
#>

param(
    [string]$Username = "sumca1",
    [string]$Repo = "ollama-downloader2"
)

$ErrorActionPreference = "Stop"

Write-Host "`n🔍 בודק סטטוס GitHub Actions..." -ForegroundColor Cyan
Write-Host "Repository: $Username/$Repo`n" -ForegroundColor Gray

try {
    # קבלת הריצות האחרונות
    $url = "https://api.github.com/repos/$Username/$Repo/actions/runs?per_page=5"
    
    $response = Invoke-RestMethod -Uri $url -Method Get -ErrorAction Stop
    
    if ($response.workflow_runs.Count -eq 0) {
        Write-Host "❌ לא נמצאו ריצות" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "📋 5 הריצות האחרונות:`n" -ForegroundColor White
    
    foreach ($run in $response.workflow_runs) {
        $status = $run.status
        $conclusion = $run.conclusion
        $name = $run.name
        $created = [DateTime]::ParseExact($run.created_at, "MM/dd/yyyy HH:mm:ss", $null)
        $updated = [DateTime]::ParseExact($run.updated_at, "MM/dd/yyyy HH:mm:ss", $null)
        $duration = ($updated - $created).TotalMinutes
        
        # צבע לפי סטטוס
        $statusColor = switch ($status) {
            "completed" { 
                if ($conclusion -eq "success") { "Green" }
                elseif ($conclusion -eq "failure") { "Red" }
                else { "Yellow" }
            }
            "in_progress" { "Cyan" }
            "queued" { "Gray" }
            default { "White" }
        }
        
        $icon = switch ($status) {
            "completed" {
                if ($conclusion -eq "success") { "✅" }
                elseif ($conclusion -eq "failure") { "❌" }
                else { "⚠️" }
            }
            "in_progress" { "⏳" }
            "queued" { "⏸️" }
            default { "❓" }
        }
        
        Write-Host "$icon " -NoNewline -ForegroundColor $statusColor
        Write-Host "$name" -ForegroundColor White
        Write-Host "   סטטוס: " -NoNewline -ForegroundColor Gray
        Write-Host "$status" -NoNewline -ForegroundColor $statusColor
        if ($conclusion) {
            Write-Host " ($conclusion)" -NoNewline -ForegroundColor $statusColor
        }
        Write-Host ""
        Write-Host "   התחלה: $($created.ToString('HH:mm:ss'))" -ForegroundColor Gray
        Write-Host "   זמן: $([math]::Round($duration, 1)) דקות" -ForegroundColor Gray
        Write-Host "   🔗 $($run.html_url)" -ForegroundColor DarkGray
        Write-Host ""
    }
    
    # בדיקת ריצה אחרונה
    $lastRun = $response.workflow_runs[0]
    
    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
    Write-Host "📊 סיכום הריצה האחרונה:" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Gray
    
    if ($lastRun.status -eq "completed") {
        if ($lastRun.conclusion -eq "success") {
            Write-Host "🎉 הריצה הסתיימה בהצלחה!" -ForegroundColor Green
            Write-Host "`n📦 בדוק Releases:" -ForegroundColor White
            Write-Host "   https://github.com/$Username/$Repo/releases" -ForegroundColor Cyan
        }
        elseif ($lastRun.conclusion -eq "failure") {
            Write-Host "❌ הריצה נכשלה" -ForegroundColor Red
            Write-Host "`n🔍 לפרטים נוספים:" -ForegroundColor White
            Write-Host "   $($lastRun.html_url)" -ForegroundColor Cyan
        }
        else {
            Write-Host "⚠️  הריצה הסתיימה עם סטטוס: $($lastRun.conclusion)" -ForegroundColor Yellow
        }
    }
    elseif ($lastRun.status -eq "in_progress") {
        Write-Host "⏳ הריצה עדיין רצה..." -ForegroundColor Cyan
        $elapsed = ([DateTime]::UtcNow - [DateTime]::ParseExact($lastRun.created_at, "MM/dd/yyyy HH:mm:ss", $null)).TotalMinutes
        Write-Host "   זמן שעבר: $([math]::Round($elapsed, 1)) דקות" -ForegroundColor Gray
        Write-Host "`n💡 הרץ את הסקריפט שוב בעוד כמה דקות" -ForegroundColor Yellow
    }
    else {
        Write-Host "⏸️  הריצה ממתינה..." -ForegroundColor Gray
    }
    
    Write-Host ""
    
} catch {
    Write-Host "❌ שגיאה בבדיקת סטטוס:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "`n💡 נסה:" -ForegroundColor Yellow
    Write-Host "   https://github.com/$Username/$Repo/actions" -ForegroundColor Cyan
    exit 1
}
