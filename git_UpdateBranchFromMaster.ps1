param([string] $repo, [string] $branch = "AVG-downtime", [string] $remote = "origin", [boolean] $createBranch = $true, [boolean] $push = $false)

function Invoke-Utility {
    $exe, $argsForExe = $Args
    $ErrorActionPreference = 'Stop' # in case $exe isn't found
    & $exe $argsForExe

    if ($LastExitCode) {
        Throw "Full command: $Args. - $exe indicated failure (exit code $LastExitCode)."
    }
}

function Is-In-Locals {
    param([string] $branch)

    $locals = Invoke-Utility git branch
    $trimmedLocals = $locals | foreach {$_.Trim("* ")}
    Return $trimmedLocals.Contains("$branch")
}

function Is-In-Remotes {
    param([string] $branch, [string] $remote)

    $remotes = Invoke-Utility git branch -r
    $trimmedRemotes = $remotes | foreach {$_.Trim()}
    Return $trimmedRemotes.Contains("$remote/$branch")
}

function Update-Branch {
    param([string] $branch, [string] $remote, [boolean] $createBranch)

    Invoke-Utility git fetch $remote

    if (-not (Is-In-Remotes -remote $remote -branch master)) {
        Throw "There is no master branch in remote $remote"
    }
    Invoke-Utility git checkout master
    Invoke-Utility git pull --ff

    $presentInLocals = Is-In-Locals -remote $remote -branch $branch
    $presentInRemotes = Is-In-Remotes -remote $remote -branch $branch

    if ($presentInRemotes) {
        Invoke-Utility git checkout $branch
        Invoke-Utility git branch --set-upstream-to $remote/$branch
        Invoke-Utility git pull --ff
    }
    elseif ($presentInLocals) {
        Invoke-Utility git checkout $branch
    }
    elseif ($createBranch) {
        Invoke-Utility git checkout -b $branch
    }
    else {
        Throw "There is no '$branch' branch in remotes and in locals. And '-createBranch' param is false."
    }
}

function Is-Status-Ok {
    $gitStatus = Invoke-Utility git status --porcelain
    Return $gitStatus.length -eq 0
}

function Update-From-Master {
    param([string] $repo, [string] $branch, [string] $remote, [boolean] $createBranch, [boolean] $push)

    $initialLocation = (Get-Location).ToString()
    $initialBranch

    $changeToInitialLocation = $true
    $checkoutToInitialBranch = $false
    
    try {
        $repoPath = "$initialLocation\$repo"

        if (-not (Test-Path $repoPath -PathType Container)) {
            $changeToInitialLocation = $false
            Throw "There is no directory '$repo' in current directory '$initialLocation'"
        }
        Set-Location $repoPath

        if (-not (Test-Path $repoPath\.git -PathType Container)) {
            Throw "The directory '$repoPath' is not a git directory."
        }
        
         $initialBranch = git rev-parse --abbrev-ref HEAD

        if (-not (Is-Status-Ok)) {
            Throw "The repository '$repo' has uncommited changes."
        }

        $checkoutToInitialBranch = $true # after repo checks and before updating (possible checkouts to other repos)
        Update-Branch -branch $branch -remote $remote -createBranch $createBranch

        Invoke-Utility git merge master

        if (-not (Is-Status-Ok)) {
            Throw "Merging resulted in conflict. Resolve conflicts locally and commit changes."
        }

        if ($push) {
            Invoke-Utility git push $remote $branch -u
        }
    }
    catch {
        Write-Host $PSItem.ToString() -ForegroundColor Red
    }

    if ($checkoutToInitialBranch) {
        Invoke-Utility git checkout $initialBranch
    }

    if ($changeToInitialLocation) {
        Set-Location $initialLocation
    }
}

Update-From-Master $repo $branch $remote $createBranch $push